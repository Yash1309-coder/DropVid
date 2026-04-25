import ipaddress
from urllib.parse import urlparse
import socket
from ..config import get_settings

settings = get_settings()


class URLValidationError(Exception):
    """Raised when a URL fails validation."""
    pass


def validate_url(url: str) -> str:
    """
    Validate and sanitize a download URL.

    Checks:
    1. Valid URL format (http/https)
    2. Domain is in the allowed list
    3. Not a private/internal IP (SSRF protection)

    Returns the normalized URL.
    Raises URLValidationError on failure.
    """
    try:
        parsed = urlparse(url.strip())
    except Exception:
        raise URLValidationError("Invalid URL format")

    # Must be http or https
    if parsed.scheme not in ("http", "https"):
        raise URLValidationError("URL must use http or https")

    # Must have a host
    host = parsed.hostname
    if not host:
        raise URLValidationError("URL must have a valid hostname")

    # Check against allowed domains
    host_lower = host.lower()
    domain_allowed = False
    for domain in settings.allowed_domains:
        if host_lower == domain or host_lower.endswith(f".{domain}"):
            domain_allowed = True
            break

    if not domain_allowed:
        raise URLValidationError(
            f"Domain '{host_lower}' is not supported. "
            "Supported: YouTube, Instagram, TikTok, Twitter/X, Facebook, Reddit, Vimeo, Dailymotion"
        )

    # SSRF protection — reject private/internal IPs
    try:
        resolved_ips = socket.getaddrinfo(host, None)
        for _, _, _, _, addr in resolved_ips:
            ip = ipaddress.ip_address(addr[0])
            if ip.is_private or ip.is_loopback or ip.is_reserved:
                raise URLValidationError("URL resolves to a private network address")
    except socket.gaierror:
        raise URLValidationError(f"Cannot resolve hostname: {host}")

    return url.strip()
