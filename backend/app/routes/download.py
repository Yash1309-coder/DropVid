import os
from fastapi import APIRouter, Request
from fastapi.responses import FileResponse, JSONResponse
from slowapi import Limiter

from ..dependencies import get_redis, limiter
from ..models import (
    DownloadRequest,
    DownloadResponse,
    StatusResponse,
    JobStatus,
)
from ..services.url_validator import validate_url, URLValidationError
from ..services.cache_service import get_cached_file, get_progress
from ..worker.tasks import download_video
from ..config import get_settings

settings = get_settings()
router = APIRouter()


@router.post("/download", response_model=DownloadResponse)
@limiter.limit(f"{settings.rate_limit_per_minute}/minute")
async def submit_download(request: Request, body: DownloadRequest):
    """
    Submit a video download job.

    1. Validate the URL (domain whitelist + SSRF check)
    2. Check cache — if already downloaded, return immediately
    3. Enqueue a Celery task and return the job ID
    """
    # Validate URL
    try:
        validated_url = validate_url(body.url)
    except URLValidationError as e:
        return JSONResponse(
            status_code=400,
            content={"job_id": "", "status": "failed", "message": str(e)},
        )

    # Check cache
    redis = await get_redis()
    cached = await get_cached_file(
        redis, validated_url, body.quality.value, body.format.value
    )
    if cached:
        return DownloadResponse(
            job_id=cached.get("job_id", "cached"),
            status=JobStatus.COMPLETED,
            message=f"Already downloaded. File ID: {cached['file_id']}",
        )

    # Enqueue download task
    task = download_video.delay(
        url=validated_url,
        quality=body.quality.value,
        fmt=body.format.value,
    )

    return DownloadResponse(
        job_id=task.id,
        status=JobStatus.QUEUED,
        message="Download queued",
    )


@router.get("/status/{job_id}", response_model=StatusResponse)
async def get_status(job_id: str):
    """
    Poll the status of a download job.

    Reads from:
    - Celery task state (queued/started/success/failure)
    - Redis progress key (percentage, title, etc.)
    """
    from celery.result import AsyncResult
    from ..worker.celery_app import celery_app

    result = AsyncResult(job_id, app=celery_app)
    redis = await get_redis()
    progress_data = await get_progress(redis, job_id)

    # Map Celery states to our JobStatus
    if result.state == "PENDING":
        return StatusResponse(job_id=job_id, status=JobStatus.QUEUED)

    if result.state == "STARTED" or result.state == "PROGRESS":
        progress = 0.0
        title = None
        if progress_data:
            progress = progress_data.get("progress", 0.0)
            title = progress_data.get("title")
            status_str = progress_data.get("status", "downloading")
            status = JobStatus.MERGING if status_str == "merging" else JobStatus.DOWNLOADING
        else:
            status = JobStatus.DOWNLOADING

        return StatusResponse(
            job_id=job_id,
            status=status,
            progress=progress,
            title=title,
        )

    if result.state == "SUCCESS":
        data = result.result or {}
        return StatusResponse(
            job_id=job_id,
            status=JobStatus.COMPLETED,
            progress=100.0,
            title=data.get("title"),
            file_size=data.get("size_bytes"),
            file_id=data.get("file_id"),
            download_url=f"/file/{data.get('file_id')}",
        )

    if result.state == "FAILURE":
        return StatusResponse(
            job_id=job_id,
            status=JobStatus.FAILED,
            error=str(result.result) if result.result else "Download failed",
        )

    # Unknown state
    return StatusResponse(job_id=job_id, status=JobStatus.QUEUED)


@router.get("/file/{file_id}")
async def download_file(file_id: str):
    """
    Serve a downloaded file by its ID.

    Looks up file metadata in Redis, then streams the file
    with proper Content-Disposition headers.
    """
    import json

    redis = await get_redis()
    meta_raw = await redis.get(f"file:{file_id}")

    if not meta_raw:
        return JSONResponse(status_code=404, content={"error": "File not found or expired"})

    meta = json.loads(meta_raw)
    file_path = meta.get("file_path", "")

    if not os.path.exists(file_path):
        return JSONResponse(status_code=404, content={"error": "File has been cleaned up"})

    filename = meta.get("title", "video")
    ext = ".mp4" if meta.get("format") == "video" else ".m4a"
    safe_name = "".join(c for c in filename if c.isalnum() or c in " -_").strip()
    safe_name = safe_name[:100] or "download"

    return FileResponse(
        path=file_path,
        filename=f"{safe_name}{ext}",
        media_type="video/mp4" if meta.get("format") == "video" else "audio/mp4",
    )
