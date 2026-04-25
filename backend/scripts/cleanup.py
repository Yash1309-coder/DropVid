"""
DropVid File Cleanup Script

Deletes downloaded files and their Redis metadata older than MAX_FILE_AGE_HOURS.
Run via cron: 0 * * * * python /app/scripts/cleanup.py

Can also be run manually: python -m scripts.cleanup
"""

import os
import time
import redis
import json

DOWNLOAD_DIR = os.environ.get("DOWNLOAD_DIR", "/app/downloads")
REDIS_URL = os.environ.get("REDIS_URL", "redis://redis:6379/0")
MAX_AGE_HOURS = int(os.environ.get("MAX_FILE_AGE_HOURS", "24"))


def cleanup():
    """Remove expired files and their Redis keys."""
    r = redis.from_url(REDIS_URL, decode_responses=True)
    now = time.time()
    max_age_seconds = MAX_AGE_HOURS * 3600
    removed = 0

    if not os.path.exists(DOWNLOAD_DIR):
        print(f"Download directory does not exist: {DOWNLOAD_DIR}")
        return

    for filename in os.listdir(DOWNLOAD_DIR):
        filepath = os.path.join(DOWNLOAD_DIR, filename)
        if not os.path.isfile(filepath):
            continue

        file_age = now - os.path.getmtime(filepath)
        if file_age > max_age_seconds:
            # Extract file_id from filename (format: {file_id}.{ext})
            file_id = filename.rsplit(".", 1)[0]

            # Delete Redis metadata
            r.delete(f"file:{file_id}")

            # Delete the file
            try:
                os.remove(filepath)
                removed += 1
                print(f"Removed: {filename} (age: {file_age / 3600:.1f}h)")
            except OSError as e:
                print(f"Failed to remove {filename}: {e}")

    print(f"Cleanup complete. Removed {removed} files.")


if __name__ == "__main__":
    cleanup()
