# Vercel Function entry: serves every /api/* route from the FastAPI app in main.py
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from main import app  # noqa: E402,F401
