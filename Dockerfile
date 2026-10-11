# ==========================================
# RISKORA - Full-Stack Production Container
# Multi-stage Dockerfile (Flutter Web + FastAPI + SQLite + Groq AI)
# ==========================================

# Stage 1: Build Flutter Web application
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS frontend-build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stage 2: Python FastAPI Production Server
FROM python:3.12-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY . .

# Copy compiled Flutter web assets into build/web
COPY --from=frontend-build /app/build/web /app/build/web

EXPOSE 8000
ENV PORT=8000
ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]
