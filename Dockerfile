# ==========================================
# RISKORA - Full-Stack Production Container
# (Pre-compiled Flutter Web + FastAPI + SQLite + Groq AI)
# ==========================================
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all application code including pre-built web_dist
COPY . .

EXPOSE 8000
ENV PORT=8000
ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]
