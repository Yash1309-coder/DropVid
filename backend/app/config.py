from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application configuration loaded from environment variables."""

    # Redis
    redis_url: str = "redis://redis:6379/0"

    # Downloads
    download_dir: str = "/app/downloads"
    max_file_age_hours: int = 24

    # Rate Limiting
    rate_limit_per_minute: int = 10

    # Server
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    api_workers: int = 4

    # Worker
    celery_concurrency: int = 4
    max_retries: int = 3

    # Allowed domains for download
    allowed_domains: list[str] = [
        "youtube.com",
        "www.youtube.com",
        "m.youtube.com",
        "youtu.be",
        "music.youtube.com",
        "instagram.com",
        "www.instagram.com",
        "tiktok.com",
        "www.tiktok.com",
        "vm.tiktok.com",
        "twitter.com",
        "www.twitter.com",
        "x.com",
        "www.x.com",
        "facebook.com",
        "www.facebook.com",
        "fb.watch",
        "reddit.com",
        "www.reddit.com",
        "vimeo.com",
        "www.vimeo.com",
        "dailymotion.com",
        "www.dailymotion.com",
        "dai.ly",
    ]

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache
def get_settings() -> Settings:
    """Cached settings instance — loaded once per process."""
    return Settings()
