# RISKORA Full-Stack Cloud Deployment Guide

This guide walks you through deploying the complete **RISKORA** full-stack platform (Flutter Web + FastAPI Backend + SQLite + Groq AI Chat Agents).

---

## 🚀 Option 1: Render.com (Recommended – 100% Free Tier)

Render can build and run both the **Flutter Web frontend** and **FastAPI backend** together in a single container with zero CORS configuration needed.

### Steps:
1. Go to [https://dashboard.render.com/](https://dashboard.render.com/) and sign in with your GitHub account.
2. Click **New +** in the top navigation bar and select **Web Service** (or **Blueprint**).
3. Connect your GitHub repository:
   - Repository: `saisudheer-alavala/Riskora`
4. Render will automatically detect the root `Dockerfile` and `render.yaml`.
5. Configure the following:
   - **Name**: `riskora-secops` (or any name you prefer)
   - **Region**: Choose the closest region (e.g., Singapore or Oregon)
   - **Instance Type**: **Free**
   - **Environment Variables**:
     - `GROQ_API_KEY`: `your_groq_api_key_here` (from your `.env` file)
     - `PORT`: `8000`
6. Click **Deploy Web Service**.
7. Once deployment finishes (typically 3–5 minutes):
   - **Your live URL**: `https://riskora-secops.onrender.com`
   - Root `/` serves the complete Flutter Web command center.
   - `/api/health` reports system & SQLite status.
   - `/api/chat` communicates with the 3 Groq AI Agents.
   - `/docs` provides interactive Swagger API documentation.

---

## 🚆 Option 2: Railway.app (Fast Cloud Deployment)

1. Go to [https://railway.app/](https://railway.app/) and login with GitHub.
2. Click **New Project** -> **Deploy from GitHub repo**.
3. Select `saisudheer-alavala/Riskora`.
4. Railway will automatically detect `railway.json` and build the `Dockerfile`.
5. Under **Variables**, add:
   - `GROQ_API_KEY`: `your_groq_api_key_here` (from your `.env` file)
   - `PORT`: `8000`
6. Go to **Settings** -> **Networking** -> click **Generate Domain**.
7. Your app is live with SSL (`https://riskora-production.up.railway.app`).

---

## ▲ Option 3: Vercel (Fastest Frontend Web Deployment)

Since the production-ready Flutter Web build is pre-compiled in `web_dist/` and configured via `vercel.json`, you can deploy to Vercel in less than 30 seconds:

### Method A: Through Vercel Web Dashboard (1-Click)
1. Go to [https://vercel.com/](https://vercel.com/) and sign in with GitHub.
2. Click **Add New...** -> **Project**.
3. Import your GitHub repository: `saisudheer-alavala/Riskora`.
4. In **Project Configuration**:
   - Framework Preset: **Other**
   - Output Directory: `web_dist` (automatically detected from `vercel.json`)
5. Click **Deploy**.
6. Your Flutter Web app goes live instantly at `https://riskora-*.vercel.app`!

### Method B: Through Vercel CLI
```bash
npm install -g vercel
vercel --prod
```

---

## 🔥 Option 4: Firebase Hosting (Frontend Only)

Firebase CLI (`15.10.1`) is already installed on your system. To deploy the frontend to Firebase Hosting:

1. Build the Flutter Web release bundle:
   ```bash
   flutter build web --release
   ```
2. Login to Firebase:
   ```bash
   firebase login
   ```
3. Initialize hosting:
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project.
   - Specify public directory: `build/web`
   - Configure as single-page app: `Yes`
   - Overwrite index.html: `No`
4. Deploy:
   ```bash
   firebase deploy --only hosting
   ```

---

## 🐳 Option 4: Self-Hosted Docker Compose

To run the entire platform locally or on a VPS (AWS EC2, DigitalOcean, Hetzner):

```bash
docker compose up --build -d
```
- Frontend: `http://localhost:8080` (or `http://localhost:8000`)
- Backend API: `http://localhost:8000`
- API Docs: `http://localhost:8000/docs`
