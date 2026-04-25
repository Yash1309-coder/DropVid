from fastapi import APIRouter
from ..dependencies import get_redis
from ..models import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """Check API and Redis connectivity."""
    try:
        redis = await get_redis()
        await redis.ping()
        redis_status = "connected"
    except Exception:
        redis_status = "disconnected"

    return HealthResponse(
        status="ok" if redis_status == "connected" else "degraded",
        redis=redis_status,
    )
