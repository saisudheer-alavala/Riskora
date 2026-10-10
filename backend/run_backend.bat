@echo off
echo ===================================================
echo   RISKORA - SecOps Platform Backend API Server
echo ===================================================
echo Starting FastAPI & SQLite on http://localhost:8000
echo Interactive API Documentation: http://localhost:8000/docs
echo.
cd /d "%~dp0"
python main.py
pause
