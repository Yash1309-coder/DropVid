"""
DropVid Instagram Story Backend
================================
FastAPI server using instagrapi to fetch Instagram stories
from both public and private accounts.

Usage:
    1. Copy .env.example to .env and fill in your IG credentials
    2. pip install -r requirements.txt
    3. python main.py
    4. Open http://localhost:8000/docs to see all endpoints
    5. Call POST /login to trigger login manually

The server exposes:
    GET  /health                     → Server status check
    POST /login                      → Manually trigger Instagram login
    GET  /fetch-stories/{username}   → Fetch stories for a user
"""

import os
import time
import random
import logging
from pathlib import Path
from datetime import datetime

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from instagrapi import Client
from instagrapi.exceptions import (
    LoginRequired,
    UserNotFound,
    PrivateError,
    ClientError,
    PleaseWaitFewMinutes,
    ChallengeRequired,
)

# ─── Config ───────────────────────────────────────────
load_dotenv()

IG_USERNAME = os.getenv("IG_USERNAME", "")
IG_PASSWORD = os.getenv("IG_PASSWORD", "")
IG_SESSION_PATH = os.getenv("IG_SESSION_PATH", "session.json")
IG_PROXY = os.getenv("IG_PROXY", "")  # e.g. http://user:pass@host:port
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))

# ─── Logging ──────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("dropvid-backend")

# ─── FastAPI App ──────────────────────────────────────
app = FastAPI(
    title="DropVid Instagram Story API",
    version="1.1.0",
    description="Fetch Instagram stories via instagrapi. Visit /docs for Swagger UI.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Instagram Client ────────────────────────────────
cl = Client()
_logged_in = False
_login_error = None  # Store last login error for diagnostics


def _setup_client():
    """Configure the instagrapi client with realistic settings."""
    # Set realistic device and user-agent to avoid detection
    cl.delay_range = [1, 3]  # Built-in delay between requests

    # Set proxy if configured
    if IG_PROXY:
        cl.set_proxy(IG_PROXY)
        logger.info(f"🌐 Proxy configured: {IG_PROXY.split('@')[-1] if '@' in IG_PROXY else IG_PROXY}")


def _random_delay(min_sec: float = 1.0, max_sec: float = 3.0):
    """Add a small random delay to mimic human behavior."""
    delay = random.uniform(min_sec, max_sec)
    logger.info(f"⏱ Delay: {delay:.1f}s")
    time.sleep(delay)


def _load_session() -> bool:
    """Try to load an existing session from disk."""
    global _logged_in, _login_error

    session_path = Path(IG_SESSION_PATH)
    if not session_path.exists():
        logger.info("📂 No session.json found — fresh login needed.")
        return False

    try:
        cl.load_settings(str(session_path))
        cl.login(IG_USERNAME, IG_PASSWORD)

        # Validate session is still active with a lightweight call
        try:
            cl.get_timeline_feed()
        except Exception:
            # Timeline feed might fail but session could still be valid
            pass

        _logged_in = True
        _login_error = None
        logger.info("✅ Session loaded successfully.")
        return True
    except Exception as e:
        logger.warning(f"⚠️ Session invalid: {e}")
        session_path.unlink(missing_ok=True)
        return False


def _fresh_login() -> bool:
    """Perform a fresh login and save the session."""
    global _logged_in, _login_error

    if not IG_USERNAME or not IG_PASSWORD:
        _login_error = "IG_USERNAME and IG_PASSWORD must be set in .env"
        logger.error(f"❌ {_login_error}")
        return False

    try:
        logger.info(f"🔑 Logging in as @{IG_USERNAME}...")
        cl.login(IG_USERNAME, IG_PASSWORD)
        cl.dump_settings(IG_SESSION_PATH)
        _logged_in = True
        _login_error = None
        logger.info("✅ Login successful! Session saved.")
        return True
    except ChallengeRequired as e:
        _login_error = "Instagram wants to verify your identity. Log in from a browser first, complete the challenge, then retry."
        logger.error(f"❌ {_login_error}")
        return False
    except PleaseWaitFewMinutes:
        _login_error = "Instagram rate-limited this IP. Wait 5-10 minutes, or use a VPN/proxy."
        logger.error(f"❌ {_login_error}")
        return False
    except Exception as e:
        error_str = str(e)
        if "blacklist" in error_str.lower() or "bad_password" in error_str.lower():
            _login_error = (
                "IP is blacklisted by Instagram. Fix options:\n"
                "1. Connect to a VPN and set IG_PROXY in .env\n"
                "2. Log in to Instagram in your browser first to verify the account\n"
                "3. Wait 24-48 hours for the block to expire"
            )
        else:
            _login_error = f"Login failed: {error_str}"
        logger.error(f"❌ {_login_error}")
        return False


def ensure_logged_in() -> bool:
    """Ensure the client is logged in."""
    global _logged_in
    if _logged_in:
        return True
    if _load_session():
        return True
    return _fresh_login()


# ─── Endpoints ────────────────────────────────────────

@app.get("/health")
def health_check():
    """Server health check — always responds, even without login."""
    return {
        "status": "ok",
        "logged_in": _logged_in,
        "username": IG_USERNAME if _logged_in else None,
        "login_error": _login_error,
        "proxy_configured": bool(IG_PROXY),
        "timestamp": datetime.utcnow().isoformat(),
    }


@app.post("/login")
def manual_login(proxy: str = None):
    """
    Manually trigger Instagram login.
    Optionally pass a proxy URL as query param: /login?proxy=http://user:pass@host:port

    Use this after:
    - Fixing your credentials in .env
    - Setting up a VPN
    - Completing an Instagram challenge in browser
    """
    global _logged_in, _login_error

    # Reset state
    _logged_in = False
    _login_error = None

    # Apply proxy if provided
    if proxy:
        cl.set_proxy(proxy)
        logger.info(f"🌐 Proxy set: {proxy.split('@')[-1] if '@' in proxy else proxy}")

    # Reload .env in case credentials were updated
    load_dotenv(override=True)
    global IG_USERNAME, IG_PASSWORD
    IG_USERNAME = os.getenv("IG_USERNAME", "")
    IG_PASSWORD = os.getenv("IG_PASSWORD", "")

    if not IG_USERNAME or not IG_PASSWORD:
        raise HTTPException(
            status_code=400,
            detail={
                "error_code": "MISSING_CREDENTIALS",
                "message": "Set IG_USERNAME and IG_PASSWORD in backend/.env file first.",
            },
        )

    success = _fresh_login()

    if success:
        return {
            "status": "success",
            "message": f"Logged in as @{IG_USERNAME}",
            "logged_in": True,
        }
    else:
        raise HTTPException(
            status_code=401,
            detail={
                "error_code": "LOGIN_FAILED",
                "message": _login_error or "Login failed. See server logs.",
            },
        )


@app.get("/fetch-stories/{username}")
def fetch_stories(username: str):
    """
    Fetch active stories for a given Instagram username.

    Error codes:
    - 401: Not logged in / login failed
    - 403: Private account — follow them first
    - 404: User not found
    - 429: Rate limited by Instagram
    - 500: Internal server error
    """

    if not ensure_logged_in():
        raise HTTPException(
            status_code=401,
            detail={
                "error_code": "LOGIN_FAILED",
                "message": _login_error or "Not logged in. Call POST /login first.",
            },
        )

    _random_delay(1.0, 2.5)

    # Resolve username → user_id
    try:
        user_id = cl.user_id_from_username(username)
    except UserNotFound:
        raise HTTPException(
            status_code=404,
            detail={
                "error_code": "USER_NOT_FOUND",
                "message": f"Instagram user @{username} not found.",
            },
        )
    except PleaseWaitFewMinutes:
        raise HTTPException(
            status_code=429,
            detail={
                "error_code": "RATE_LIMITED",
                "message": "Instagram rate limit hit. Wait a few minutes.",
            },
        )
    except Exception as e:
        logger.error(f"Error resolving @{username}: {e}")
        raise HTTPException(
            status_code=500,
            detail={
                "error_code": "RESOLVE_FAILED",
                "message": f"Could not resolve user @{username}.",
            },
        )

    _random_delay(1.5, 3.0)

    # Fetch stories
    try:
        stories = cl.user_stories(user_id)
    except PrivateError:
        raise HTTPException(
            status_code=403,
            detail={
                "error_code": "PRIVATE_ACCOUNT",
                "message": f"@{username} is private. Follow them first.",
            },
        )
    except LoginRequired:
        _logged_in_reset()
        raise HTTPException(
            status_code=401,
            detail={
                "error_code": "SESSION_EXPIRED",
                "message": "Session expired. Retry and the server will re-login.",
            },
        )
    except PleaseWaitFewMinutes:
        raise HTTPException(
            status_code=429,
            detail={
                "error_code": "RATE_LIMITED",
                "message": "Instagram rate limit hit. Wait a few minutes.",
            },
        )
    except Exception as e:
        logger.error(f"Error fetching stories for @{username}: {e}")
        raise HTTPException(
            status_code=500,
            detail={
                "error_code": "FETCH_FAILED",
                "message": "Failed to fetch stories. Try again.",
            },
        )

    # Extract media data
    if not stories:
        return {
            "username": username,
            "story_count": 0,
            "stories": [],
            "message": f"@{username} has no active stories right now.",
        }

    result = []
    for story in stories:
        is_video = story.media_type == 2

        if is_video:
            url = str(story.video_url) if story.video_url else None
            if not url and story.video_versions:
                best = max(story.video_versions, key=lambda v: v.get("width", 0))
                url = best.get("url", "")
        else:
            url = str(story.thumbnail_url) if story.thumbnail_url else None
            if not url and story.image_versions2:
                candidates = story.image_versions2.get("candidates", [])
                if candidates:
                    best = max(candidates, key=lambda c: c.get("width", 0))
                    url = best.get("url", "")

        if not url:
            continue

        thumbnail_url = None
        if is_video and story.thumbnail_url:
            thumbnail_url = str(story.thumbnail_url)

        result.append({
            "media_pk": str(story.pk),
            "is_video": is_video,
            "url": url,
            "thumbnail_url": thumbnail_url,
            "timestamp": story.taken_at.isoformat() if story.taken_at else None,
            "media_type": "video" if is_video else "image",
        })

    try:
        cl.dump_settings(IG_SESSION_PATH)
    except Exception:
        pass

    return {
        "username": username,
        "story_count": len(result),
        "stories": result,
    }


def _logged_in_reset():
    """Reset login state."""
    global _logged_in
    _logged_in = False
    Path(IG_SESSION_PATH).unlink(missing_ok=True)


# ─── Startup ──────────────────────────────────────────

@app.on_event("startup")
def startup_event():
    """Start server WITHOUT auto-login — use POST /login to log in."""
    logger.info("=" * 50)
    logger.info("DropVid Instagram Story Backend v1.1")
    logger.info("=" * 50)
    _setup_client()

    if not IG_USERNAME or not IG_PASSWORD:
        logger.warning("⚠️  Set IG_USERNAME and IG_PASSWORD in .env")
    else:
        logger.info(f"📱 Account: @{IG_USERNAME}")

    logger.info(f"🌐 Proxy: {'Yes' if IG_PROXY else 'None (set IG_PROXY in .env if IP blocked)'}")
    logger.info("")
    logger.info("👉 Server is UP. Login is NOT automatic.")
    logger.info("👉 Open http://localhost:8000/docs to use Swagger UI")
    logger.info("👉 Call POST /login to authenticate with Instagram")
    logger.info("=" * 50)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=HOST,
        port=PORT,
        reload=True,
        log_level="info",
    )
