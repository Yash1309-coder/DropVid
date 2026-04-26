"""
Downlo Standalone Backend — No Docker, No Redis, No Celery
==========================================================
A lightweight server for local development and testing.
Runs yt-dlp directly in-process with threaded downloads.

Usage:
    python standalone_server.py

The server starts on http://0.0.0.0:8000
Flutter connects via YTDLP_BACKEND_URL=http://<your-local-ip>:8000
"""

import os
import sys
import json
import uuid
import threading
import time
from pathlib import Path

import yt_dlp
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel
from enum import Enum
import uvicorn

# ─── Configuration ───────────────────────────────────────────
DOWNLOAD_DIR = os.path.join(os.path.dirname(__file__), "downloads")
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

# ─── In-memory job store (replaces Redis) ────────────────────
_jobs: dict[str, dict] = {}
_jobs_lock = threading.Lock()

# ─── Models ──────────────────────────────────────────────────

class Quality(str, Enum):
    LOW = "360"
    MEDIUM = "480"
    HD = "720"
    FHD = "1080"
    BEST = "best"
    MAX = "max"

class Format(str, Enum):
    VIDEO = "video"
    AUDIO = "audio"

class DownloadRequest(BaseModel):
    url: str
    quality: Quality = Quality.FHD
    format: Format = Format.VIDEO

# ─── Allowed domains ────────────────────────────────────────
ALLOWED_DOMAINS = [
    "youtube.com", "www.youtube.com", "m.youtube.com",
    "youtu.be", "music.youtube.com",
    "instagram.com", "www.instagram.com",
    "tiktok.com", "www.tiktok.com", "vm.tiktok.com",
    "twitter.com", "www.twitter.com", "x.com", "www.x.com",
    "facebook.com", "www.facebook.com", "fb.watch",
    "reddit.com", "www.reddit.com",
    "vimeo.com", "www.vimeo.com",
    "dailymotion.com", "www.dailymotion.com", "dai.ly",
]

def validate_domain(url: str) -> bool:
    from urllib.parse import urlparse
    try:
        host = urlparse(url.strip()).hostname
        if not host:
            return False
        host = host.lower()
        return any(host == d or host.endswith(f".{d}") for d in ALLOWED_DOMAINS)
    except Exception:
        return False

# ─── yt-dlp format builder ──────────────────────────────────

def _has_ffmpeg() -> bool:
    """Check if ffmpeg is available on the system."""
    import shutil
    return shutil.which("ffmpeg") is not None

_FFMPEG_AVAILABLE = _has_ffmpeg()

def _get_format_string(quality: str, fmt: str) -> str:
    if fmt == "audio":
        if _FFMPEG_AVAILABLE:
            return "bestaudio[ext=m4a]/bestaudio/best"
        return "bestaudio/best"

    if quality in ("best", "max"):
        if _FFMPEG_AVAILABLE:
            return "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best[ext=mp4]/best"
        # No ffmpeg: prefer pre-merged single-stream formats
        return "best[ext=mp4]/best"

    height = int(quality)
    if _FFMPEG_AVAILABLE:
        return (
            f"bestvideo[height<={height}][ext=mp4]+bestaudio[ext=m4a]/"
            f"bestvideo[height<={height}]+bestaudio/"
            f"best[height<={height}][ext=mp4]/"
            f"best[height<={height}]/"
            f"best"
        )
    # No ffmpeg: prefer pre-merged single-stream formats
    return (
        f"best[height<={height}][ext=mp4]/"
        f"best[height<={height}]/"
        f"best[ext=mp4]/"
        f"best"
    )

# ─── Background download worker ─────────────────────────────

def _download_worker(job_id: str, url: str, quality: str, fmt: str):
    """Run yt-dlp in a background thread."""
    file_id = uuid.uuid4().hex[:12]
    output_template = os.path.join(DOWNLOAD_DIR, f"{file_id}.%(ext)s")

    def progress_hook(d):
        if d["status"] == "downloading":
            total = d.get("total_bytes") or d.get("total_bytes_estimate") or 0
            downloaded = d.get("downloaded_bytes", 0)
            pct = round((downloaded / total) * 100, 1) if total > 0 else 0.0
            with _jobs_lock:
                _jobs[job_id].update({
                    "status": "downloading",
                    "progress": pct,
                    "speed": d.get("speed"),
                    "eta": d.get("eta"),
                })
        elif d["status"] == "finished":
            with _jobs_lock:
                _jobs[job_id].update({
                    "status": "merging",
                    "progress": 95.0,
                })

    ydl_opts = {
        "format": _get_format_string(quality, fmt),
        "outtmpl": output_template,
        "merge_output_format": "mp4" if fmt == "video" else None,
        "extractor_args": {
            "youtube": ["player_client=android"]
        },
        "concurrent_fragment_downloads": 8,
        "retries": 5,
        "fragment_retries": 10,
        "socket_timeout": 30,
        "progress_hooks": [progress_hook],
        "quiet": True,
        "no_warnings": True,
        "noprogress": True,
        "postprocessors": [],
    }

    if fmt == "audio":
        ydl_opts["postprocessors"].append({
            "key": "FFmpegExtractAudio",
            "preferredcodec": "m4a",
            "preferredquality": "192",
        })

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            title = info.get("title", "Unknown")

            with _jobs_lock:
                _jobs[job_id].update({
                    "status": "downloading",
                    "progress": 0.0,
                    "title": title,
                })

            ydl.download([url])

        # Find the output file
        ext = "m4a" if fmt == "audio" else "mp4"
        file_path = os.path.join(DOWNLOAD_DIR, f"{file_id}.{ext}")

        if not os.path.exists(file_path):
            for f in os.listdir(DOWNLOAD_DIR):
                if f.startswith(file_id):
                    file_path = os.path.join(DOWNLOAD_DIR, f)
                    break

        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Downloaded file not found for {file_id}")

        size_bytes = os.path.getsize(file_path)

        with _jobs_lock:
            _jobs[job_id].update({
                "status": "completed",
                "progress": 100.0,
                "title": title,
                "file_id": file_id,
                "file_path": file_path,
                "size_bytes": size_bytes,
            })

        print(f"[OK] Download completed: {title} ({size_bytes / 1024 / 1024:.1f} MB)")

    except Exception as exc:
        print(f"[FAIL] Download failed: {exc}", file=sys.stderr)
        with _jobs_lock:
            _jobs[job_id].update({
                "status": "failed",
                "progress": 0.0,
                "error": str(exc),
            })


# ─── FastAPI App ─────────────────────────────────────────────

app = FastAPI(
    title="Downlo Standalone Backend",
    description="Lightweight yt-dlp server — no Docker required",
    version="1.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return {"status": "ok", "version": yt_dlp.version.__version__}


@app.post("/download")
async def submit_download(body: DownloadRequest):
    # Validate domain
    if not validate_domain(body.url):
        return JSONResponse(
            status_code=400,
            content={"job_id": "", "status": "failed", "message": "Unsupported domain"},
        )

    job_id = uuid.uuid4().hex
    quality = body.quality.value
    fmt = body.format.value

    # Initialize job
    with _jobs_lock:
        _jobs[job_id] = {
            "status": "queued",
            "progress": 0.0,
            "url": body.url,
            "quality": quality,
            "format": fmt,
        }

    # Start background download
    t = threading.Thread(
        target=_download_worker,
        args=(job_id, body.url, quality, fmt),
        daemon=True,
    )
    t.start()

    return {"job_id": job_id, "status": "queued", "message": "Download queued"}


@app.get("/status/{job_id}")
async def get_status(job_id: str):
    with _jobs_lock:
        job = _jobs.get(job_id)

    if not job:
        return JSONResponse(status_code=404, content={"error": "Job not found"})

    return {
        "job_id": job_id,
        "status": job.get("status", "queued"),
        "progress": job.get("progress", 0.0),
        "title": job.get("title"),
        "file_size": job.get("size_bytes"),
        "file_id": job.get("file_id"),
        "download_url": f"/file/{job['file_id']}" if job.get("file_id") else None,
        "error": job.get("error"),
    }


@app.get("/file/{file_id}")
async def download_file(file_id: str):
    # Find the job with this file_id
    file_path = None
    title = "download"
    fmt = "video"

    with _jobs_lock:
        for job in _jobs.values():
            if job.get("file_id") == file_id:
                file_path = job.get("file_path")
                title = job.get("title", "download")
                fmt = job.get("format", "video")
                break

    if not file_path or not os.path.exists(file_path):
        return JSONResponse(status_code=404, content={"error": "File not found"})

    # Sanitize filename
    safe_name = "".join(c for c in title if c.isalnum() or c in " -_").strip()
    safe_name = safe_name[:100] or "download"
    ext = ".m4a" if fmt == "audio" else ".mp4"

    return FileResponse(
        path=file_path,
        filename=f"{safe_name}{ext}",
        media_type="audio/mp4" if fmt == "audio" else "video/mp4",
    )


# ─── Entry point ─────────────────────────────────────────────

if __name__ == "__main__":
    import socket

    # Get the local IP for the user
    hostname = socket.gethostname()
    try:
        local_ip = socket.gethostbyname(hostname)
    except Exception:
        local_ip = "127.0.0.1"

    print("=" * 60)
    print("  Downlo Standalone Backend")
    print("=" * 60)
    print(f"  yt-dlp version : {yt_dlp.version.__version__}")
    print(f"  ffmpeg         : {'Available' if _FFMPEG_AVAILABLE else 'Not found (pre-merged formats only)'}")
    print(f"  Downloads dir  : {DOWNLOAD_DIR}")
    print(f"  Server URL     : http://{local_ip}:8000")
    print()
    print("  Flutter build command:")
    print(f"    flutter run --dart-define=YOUTUBE_ENABLED=true \\")
    print(f"      --dart-define=YTDLP_BACKEND_URL=http://{local_ip}:8000")
    print("=" * 60)

    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
