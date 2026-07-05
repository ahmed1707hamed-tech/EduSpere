# syntax=docker/dockerfile:1

# Stage 1: install Python dependencies into a virtualenv (no runtime build tools needed)
FROM python:3.12-slim AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /build

COPY requirements.txt .
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && grep -Ev '^(pytest==|pytest$)' requirements.txt \
        | sed 's/uvicorn\[standard\]/uvicorn/g' > requirements.prod \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.prod \
    && find /opt/venv -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true \
    && find /opt/venv -type f -name '*.pyc' -delete

# Stage 2: minimal runtime – only venv + application code
FROM python:3.12-slim AS runtime

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN groupadd --system app \
    && useradd --system --gid app --home-dir /app --shell /usr/sbin/nologin app

COPY --from=builder /opt/venv /opt/venv
COPY --chown=app:app app ./app

USER app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
