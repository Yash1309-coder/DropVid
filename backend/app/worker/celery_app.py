from celery import Celery
from ..config import get_settings

settings = get_settings()

celery_app = Celery(
    "dropvid",
    broker=settings.redis_url,
    backend=settings.redis_url,
)

celery_app.conf.update(
    # Serialization
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],

    # Result expiry — match file retention
    result_expires=settings.max_file_age_hours * 3600,

    # Worker settings
    worker_concurrency=settings.celery_concurrency,
    worker_prefetch_multiplier=1,  # Fair distribution across workers
    worker_max_tasks_per_child=50,  # Restart after 50 tasks (prevent memory leaks)

    # Task settings
    task_acks_late=True,  # Only ack after task completes (prevents data loss on crash)
    task_reject_on_worker_lost=True,
    task_time_limit=1800,  # 30 min hard limit per task
    task_soft_time_limit=1500,  # 25 min soft limit (raises exception)

    # Retry settings
    task_default_retry_delay=10,
    task_max_retries=settings.max_retries,
)

# Auto-discover tasks
celery_app.autodiscover_tasks(["app.worker"])
