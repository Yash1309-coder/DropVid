import os
import json
import uuid
import redis
import yt_dlp
from celery import Task
from .celery_app import celery_app
from ..config import get_settings

settings = get_settings()

# Sync Redis client for worker (Celery workers are sync)
_sync_redis = redis.from_url(settings.redis_url, decode_responses=True)


def _update_progress(job_id: str, data: dict) -> None:
    """Write progress data to Redis for the API to read."""
    key = f"progress:{job_id}"
    _sync_redis.set(key, json.dumps(data), ex=3600)


def _get_format_string(quality: str, fmt: str) -> str:
    """
    Build a yt-dlp format selection string.

    For video: select best video at requested height + best audio, merged to mp4.
    For audio: select best audio only.
    """
    if fmt == "audio":
        return "bestaudio[ext=m4a]/bestaudio/best"

    if quality == "best":
        return "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best"

    height = int(quality)
    return (
        f"bestvideo[height<={height}][ext=mp4]+bestaudio[ext=m4a]/"
        f"bestvideo[height<={height}]+bestaudio/"
        f"best[height<={height}]/"
        f"best"
    )


@celery_app.task(
    bind=True,
    name="download_video",
    max_retries=settings.max_retries,
    default_retry_delay=10,
    acks_late=True,
)
def download_video(self: Task, url: str, quality: str, fmt: str) -> dict:
    """
    Download a video using yt-dlp with progress tracking.

    Steps:
    1. Extract info (title, formats)
    2. Download with parallel fragments
    3. Track progress via Redis
    4. Store file metadata
    5. Cache the result

    Returns dict with file_id, title, size_bytes, file_path.
    """
    job_id = self.request.id
    file_id = uuid.uuid4().hex[:12]
    output_dir = settings.download_dir
    os.makedirs(output_dir, exist_ok=True)

    # Output template — unique filename per download
    output_template = os.path.join(output_dir, f"{file_id}.%(ext)s")

    # Progress hook — called by yt-dlp during download
    def progress_hook(d):
        title = d.get("info_dict", {}).get("title", d.get("filename", "Unknown"))
        
        if d["status"] == "downloading":
            total = d.get("total_bytes") or d.get("total_bytes_estimate") or 0
            downloaded = d.get("downloaded_bytes", 0)
            if total > 0:
                pct = round((downloaded / total) * 100, 1)
            else:
                pct = 0.0

            _update_progress(job_id, {
                "status": "downloading",
                "progress": pct,
                "title": title,
                "speed": d.get("speed"),
                "eta": d.get("eta"),
            })

        elif d["status"] == "finished":
            _update_progress(job_id, {
                "status": "merging",
                "progress": 95.0,
                "title": title,
            })

    # yt-dlp options — MAXIMUM SPEED with aria2c external downloader
    ydl_opts = {
        "format": _get_format_string(quality, fmt),
        "outtmpl": output_template,
        "merge_output_format": "mp4" if fmt == "video" else None,
        "extractor_args": {
            "youtube": ["player_client=ios,web"]
        },

        # ── Speed: aria2c external downloader ──
        # aria2c opens multiple connections per file = massive speed boost
        "external_downloader": "aria2c",
        "external_downloader_args": {
            "default": [
                "--min-split-size=1M",       # Split files into 1MB chunks
                "--max-connection-per-server=16",  # 16 connections per server
                "--split=16",                # Split into 16 parts
                "--max-concurrent-downloads=16",
                "--file-allocation=none",    # Skip pre-allocation (faster start)
                "--optimize-concurrent-downloads=true",
                "--auto-file-renaming=false",
                "--summary-interval=1",      # 1-second summary output for progress hook
            ],
        },

        # ── Fallback: if aria2c fails on some fragments, yt-dlp retries internally
        "concurrent_fragment_downloads": 16,
        "retries": 5,
        "fragment_retries": 10,

        # ── Network tuning ──
        "socket_timeout": 30,
        "http_chunk_size": 10485760,  # 10MB chunks for HTTP downloads
        "buffersize": 1024 * 1024,   # 1MB read buffer

        # ── Callbacks ──
        "progress_hooks": [progress_hook],
        "quiet": False,
        "no_warnings": True,
        "noprogress": False,

        # Postprocessors
        "postprocessors": [],
    }

    # For audio-only, extract audio
    if fmt == "audio":
        ydl_opts["postprocessors"].append({
            "key": "FFmpegExtractAudio",
            "preferredcodec": "m4a",
            "preferredquality": "192",
        })

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # Immediately signal that extraction has started
            # This is read by Flutter's polling loop within 2s
            _update_progress(job_id, {
                "status": "extracting",
                "progress": 0.0,
                "title": "Fetching video info...",
            })

            # Single-pass extraction and download!
            # Using extract_info(download=True) prevents yt-dlp from fetching the 
            # entire video manifest twice, halving the pre-download delay time.
            info = ydl.extract_info(url, download=True)
            title = info.get("title", "Unknown")

        # Find the output file
        ext = "m4a" if fmt == "audio" else "mp4"
        file_path = os.path.join(output_dir, f"{file_id}.{ext}")

        # yt-dlp might use a different extension, find the actual file
        if not os.path.exists(file_path):
            for f in os.listdir(output_dir):
                if f.startswith(file_id):
                    file_path = os.path.join(output_dir, f)
                    break

        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Downloaded file not found for {file_id}")

        size_bytes = os.path.getsize(file_path)

        # Store file metadata in Redis
        metadata = {
            "file_id": file_id,
            "job_id": job_id,
            "url": url,
            "title": title,
            "file_path": file_path,
            "size_bytes": size_bytes,
            "quality": quality,
            "format": fmt,
        }
        _sync_redis.set(
            f"file:{file_id}",
            json.dumps(metadata),
            ex=settings.max_file_age_hours * 3600,
        )

        # Cache the URL→file mapping
        from ..services.cache_service import _cache_key
        cache_key = _cache_key(url, quality, fmt)
        _sync_redis.set(
            cache_key,
            json.dumps(metadata),
            ex=settings.max_file_age_hours * 3600,
        )

        # Final progress update
        _update_progress(job_id, {
            "status": "completed",
            "progress": 100.0,
            "title": title,
        })

        return metadata

    except Exception as exc:
        _update_progress(job_id, {
            "status": "failed",
            "progress": 0.0,
            "error": str(exc),
        })

        # Retry with exponential backoff
        if self.request.retries < settings.max_retries:
            raise self.retry(exc=exc, countdown=10 * (2 ** self.request.retries))

        raise
