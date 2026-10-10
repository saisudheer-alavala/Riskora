# RISKORA SecOps - Backend & Deployment Guide

This backend powers the **RISKORA Intelligent Digital Risk Protection Platform**, providing real-time threat intelligence, user authentication, persistent scan history, and brand profiles.

---

## 🚀 Quick Start (Local Run)

### 1. Requirements
- Python 3.10+ (Python 3.13 supported)
- FastAPI & Uvicorn

### 2. Launching the Backend Server
You can launch the backend with either:
- **Windows 1-Click**: Double-click `run_backend.bat`
- **Command Line**:
  ```bash
  cd backend
  python -m pip install -r requirements.txt
  python main.py
  ```

Server will start on `http://localhost:8000`.

- **Interactive API Documentation (Swagger)**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **Alternative Docs (ReDoc)**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

---

## 🗄️ Database & Persistent History

The backend automatically creates and manages an embedded SQLite database (`riskora.db`) with automatic table migration:
- **`users`**: Secure account registration and authentication.
- **`scan_records`**: Persistent scan history (all scans saved and reloaded per user).
- **`threats`**: Real-time threats, impersonator profiles, APK detections, review statuses, and investigation notes.
- **`brand_profiles`**: Monitored company entities, official handles, packages, and domains.

### Pre-Seeded Demo Account
- **Email**: `admin@riskora.ai`
- **Password**: `RiskoraSecOps#2026`

---

## 🚢 Deployment Options

### Option 1: Docker & Docker Compose (Recommended)
Deploy both the backend API and the Flutter Web frontend simultaneously:

```bash
docker-compose up --build -d
```
- Frontend Web App: `http://localhost:8080`
- Backend API: `http://localhost:8000`

### Option 2: Render / Railway / Fly.io (Cloud)
1. Push this repository to GitHub.
2. In **Render** or **Railway**:
   - Create a **New Web Service**.
   - Root directory: `backend`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `python main.py`
   - Set environment variable `PORT=8000`

### Option 3: Android APK Deployment
To build the Android APK for mobile devices:
```bash
flutter build apk --release
```
The output APK will be available at `build/app/outputs/flutter-apk/app-release.apk`.
