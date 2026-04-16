# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /build
COPY pyproject.toml .

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --target=/build/deps .

# Stage 2: Runtime
FROM python:3.11-slim

RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /home/appuser/app

COPY --from=builder /build/deps /usr/local/lib/python3.11/site-packages
COPY app/ app/

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
