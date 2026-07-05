import logging
import httpx
from app.core.config import settings

logger = logging.getLogger(__name__)


def send_notification_task(url_path: str, payload: dict):
    url = f"{settings.NOTIFICATION_SERVICE_URL.rstrip('/')}{url_path}"
    headers = {"X-Internal-Key": settings.INTERNAL_API_KEY}
    try:
        with httpx.Client(timeout=5.0) as client:
            response = client.post(url, json=payload, headers=headers)
            if response.status_code != 201:
                logger.error(
                    "Failed to trigger notification. Status: %d, Response: %s",
                    response.status_code,
                    response.text
                )
            else:
                logger.info("Notification successfully triggered: %s", url_path)
    except Exception as e:
        logger.error("Error triggering notification to %s: %s", url, str(e))
