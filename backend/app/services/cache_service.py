import hashlib
import json
import redis.asyncio as aioredis
from ..config import get_settings

settings = get_settings()


def _cache_key(url: str, quality: str, fmt: str) -> str:
    """Generate a deterministic cache key from URL + options."""
    normalized = url.strip().lower().split("?")[0]  # Strip query params for matching
    raw = f"{normalized}:{quality}:{fmt}"
    return f"cache:{hashlib.sha256(raw.encode()).hexdigest()[:16]}"


async def get_cached_file(
    redis: aioredis.Redis, url: str, quality: str, fmt: str
) -> dict | None:
    """
    Check if a URL+quality+format combo was already downloaded.
    Returns file metadata dict if cached, None otherwise.
    """
    key = _cache_key(url, quality, fmt)
    data = await redis.get(key)
    if data:
        return json.loads(data)
    return None


async def set_cached_file(
    redis: aioredis.Redis, url: str, quality: str, fmt: str, metadata: dict
) -> None:
    """
    Cache a successful download result.
    TTL matches the file retention period.
    """
    key = _cache_key(url, quality, fmt)
    ttl = settings.max_file_age_hours * 3600
    await redis.set(key, json.dumps(metadata), ex=ttl)


async def set_progress(
    redis: aioredis.Redis, job_id: str, data: dict
) -> None:
    """Store progress data for a job (called by worker via sync Redis)."""
    key = f"progress:{job_id}"
    await redis.set(key, json.dumps(data), ex=3600)


async def get_progress(redis: aioredis.Redis, job_id: str) -> dict | None:
    """Get current progress data for a job."""
    key = f"progress:{job_id}"
    data = await redis.get(key)
    if data:
        return json.loads(data)
    return None
