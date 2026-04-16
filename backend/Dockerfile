FROM python:3.11-slim AS builder

WORKDIR /build
COPY pyproject.toml .
RUN pip install --no-cache-dir --target=/build/deps .

FROM python:3.11-slim

RUN useradd --create-home appuser
WORKDIR /home/appuser/app

COPY --from=builder /build/deps /usr/local/lib/python3.11/site-packages
COPY app/ app/

USER appuser
EXPOSE 8000

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
