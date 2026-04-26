from pydantic import BaseModel, Field, field_validator
from enum import Enum
from datetime import datetime


class VideoQuality(str, Enum):
    """Supported video quality options."""
    Q360 = "360"
    Q480 = "480"
    Q720 = "720"
    Q1080 = "1080"
    BEST = "best"


class DownloadFormat(str, Enum):
    """Download format — video (mp4) or audio only (m4a)."""
    VIDEO = "video"
    AUDIO = "audio"


class JobStatus(str, Enum):
    """Lifecycle states of a download job."""
    QUEUED = "queued"
    EXTRACTING = "extracting"
    DOWNLOADING = "downloading"
    MERGING = "merging"
    COMPLETED = "completed"
    FAILED = "failed"


# ─── Request Models ──────────────────────────────────────────


class DownloadRequest(BaseModel):
    """POST /download request body."""
    url: str = Field(..., min_length=10, max_length=2048, description="Video URL to download")
    quality: VideoQuality = Field(default=VideoQuality.Q1080, description="Desired video quality")
    format: DownloadFormat = Field(default=DownloadFormat.VIDEO, description="Video or audio-only")

    @field_validator("url")
    @classmethod
    def validate_url_format(cls, v: str) -> str:
        v = v.strip()
        if not v.startswith(("http://", "https://")):
            raise ValueError("URL must start with http:// or https://")
        return v


# ─── Response Models ─────────────────────────────────────────


class DownloadResponse(BaseModel):
    """Response after submitting a download job."""
    job_id: str
    status: JobStatus
    message: str


class StatusResponse(BaseModel):
    """Response for job status polling."""
    job_id: str
    status: JobStatus
    progress: float = Field(default=0.0, ge=0.0, le=100.0)
    title: str | None = None
    file_size: int | None = None
    file_id: str | None = None
    download_url: str | None = None
    error: str | None = None


class FileMetadata(BaseModel):
    """Stored metadata for a downloaded file."""
    file_id: str
    url: str
    title: str
    file_path: str
    size_bytes: int
    quality: str
    format: str
    created_at: datetime = Field(default_factory=datetime.utcnow)


class HealthResponse(BaseModel):
    """Health check response."""
    status: str
    redis: str
    version: str = "1.0.0"
