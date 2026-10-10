import os
import sys
import importlib.util

current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.join(current_dir, "backend")

# Ensure backend directory is in sys.path so its internal modules (database, models) resolve
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

# Switch working directory to backend so database riskora.db and .env resolve
os.chdir(backend_dir)

# Load backend/main.py directly
backend_main_path = os.path.join(backend_dir, "main.py")
spec = importlib.util.spec_from_file_location("backend_main", backend_main_path)
backend_main = importlib.util.module_from_spec(spec)
sys.modules["backend_main"] = backend_main
spec.loader.exec_module(backend_main)

app = backend_main.app

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    print(f"Starting RISKORA SecOps API from root on http://localhost:{port}")
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
