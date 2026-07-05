import logging
import time
from contextlib import asynccontextmanager
from typing import Optional

import httpx
import redis.asyncio as aioredis
from fastapi import FastAPI, Request, Response, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from jose import JWTError, jwt

from app.core.config import settings

# Setup logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")
logger = logging.getLogger(__name__)

# Global clients
redis_client: Optional[aioredis.Redis] = None
http_client: Optional[httpx.AsyncClient] = None

# Public paths that do not require JWT authorization
PUBLIC_PATHS = {
    "/api/auth/login",
    "/api/auth/register",
    "/api/auth/forgot-password",
    "/api/auth/refresh",
    "/health",
    "/",
}


def is_public_path(path: str, method: str) -> bool:
    # Normalized path
    normalized = path.rstrip("/")
    if normalized in PUBLIC_PATHS:
        return True
    # GET courses and GET course details are public
    if method == "GET" and (normalized == "/api/courses" or normalized.startswith("/api/courses/")):
        # Ensure we're not hitting enrollment endpoints
        if not normalized.endswith("/enroll") and not normalized.endswith("/enrolled/me"):
            return True
    return False


@asynccontextmanager
async def lifespan(app: FastAPI):
    global redis_client, http_client
    logger.info("Initializing API Gateway clients...")
    redis_client = aioredis.from_url(settings.REDIS_URL, decode_responses=True)
    # Using a pooled AsyncClient for reverse-proxy performance
    http_client = httpx.AsyncClient(timeout=httpx.Timeout(60.0, connect=5.0))
    yield
    logger.info("Closing API Gateway clients...")
    await redis_client.close()
    await http_client.aclose()


app = FastAPI(
    title=settings.PROJECT_NAME,
    version="1.0.0",
    lifespan=lifespan
)

# Enforce CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Rate Limiting Middleware
@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    if request.url.path == "/health" or request.url.path == "/":
        return await call_next(request)

    ip = request.client.host if request.client else "unknown"
    current_minute = int(time.time() / 60)
    key = f"rate_limit:{ip}:{current_minute}"

    try:
        if redis_client:
            count = await redis_client.incr(key)
            if count == 1:
                await redis_client.expire(key, 60)
            if count > settings.RATE_LIMIT_PER_MINUTE:
                logger.warning("Rate limit exceeded for IP: %s on path: %s", ip, request.url.path)
                return Response(
                    content='{"detail": "Rate limit exceeded. Try again in a minute."}',
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    media_type="application/json"
                )
    except Exception as e:
        logger.error("Rate limiter exception: %s", str(e))
        # Fail open in production if Redis is down so availability is not impacted
        pass

    return await call_next(request)


# Health Check
@app.get("/health", tags=["Operations"])
async def health_check():
    redis_healthy = False
    try:
        if redis_client:
            redis_healthy = await redis_client.ping()
    except Exception:
        pass
    
    return {
        "status": "healthy",
        "service": "api-gateway",
        "redis_connected": redis_healthy
    }


@app.get("/")
async def root():
    return {"message": "EduSphere API Gateway is Running"}


# Catch-all Reverse Proxy Route
@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"])
async def gateway_proxy(request: Request, path: str):
    full_path = request.url.path
    method = request.method

    # Auth Middleware check
    user_id = None
    email = None
    role = None

    if not is_public_path(full_path, method):
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authentication credentials were not provided"
            )
        
        token = auth_header.split(" ")[1]
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            user_id = payload.get("user_id")
            email = payload.get("sub")
            role = payload.get("role")
            
            if user_id is None or email is None or role is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token payload"
                )
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )

    if not http_client:
        raise HTTPException(status_code=503, detail="Gateway client not ready")

    # Route mapping
    target_url = None
    forward_path = full_path

    if full_path.startswith("/api/auth"):
        # Replace '/api/auth' with '/auth' for auth-service mapping
        target_url = f"{settings.AUTH_SERVICE_URL}{full_path.replace('/api/auth', '/auth', 1)}"
    elif full_path.startswith("/api/courses"):
        # Course service expects '/api/courses' prefix natively
        target_url = f"{settings.COURSE_SERVICE_URL}{full_path}"
    elif full_path.startswith("/api/content"):
        # Content service expects '/content' prefix
        target_url = f"{settings.CONTENT_SERVICE_URL}{full_path.replace('/api/content', '/content', 1)}"
    elif full_path.startswith("/api/quizzes"):
        # Quiz service expects '/quizzes' prefix
        target_url = f"{settings.QUIZ_SERVICE_URL}{full_path.replace('/api/quizzes', '/quizzes', 1)}"
    elif full_path.startswith("/api/notifications"):
        # Notification service expects '/notifications' prefix
        target_url = f"{settings.NOTIFICATION_SERVICE_URL}{full_path.replace('/api/notifications', '/notifications', 1)}"
    else:
        raise HTTPException(status_code=404, detail="Resource not found")

    # Read original request body
    body = await request.body()

    # Build forward headers
    headers = dict(request.headers)
    
    # Strip Host header to prevent request routing loops
    headers.pop("host", None)
    headers.pop("content-length", None)

    # Inject parsed user details headers if authorized
    if user_id is not None:
        headers["X-User-Id"] = str(user_id)
        headers["X-User-Email"] = str(email)
        headers["X-User-Role"] = str(role)

    # Send proxy request
    try:
        response = await http_client.request(
            method=method,
            url=target_url,
            headers=headers,
            params=dict(request.query_params),
            content=body
        )
        
        # Build gateway response
        return Response(
            content=response.content,
            status_code=response.status_code,
            headers=dict(response.headers),
            media_type=response.headers.get("content-type")
        )
    except httpx.RequestError as e:
        logger.error("Proxy connection failed to %s: %s", target_url, str(e))
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Error communicating with downstream microservice"
        )
