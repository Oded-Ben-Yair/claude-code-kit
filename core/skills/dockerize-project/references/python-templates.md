# Python Backend Dockerfile Templates

## TEMPLATE A: Python FastAPI/Flask Backend (Multi-Stage, Non-Root)

```dockerfile
# <PROJECT> - Backend API
# Multi-stage build: builder installs deps, runtime is lean

# === Stage 1: Builder ===
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies (ONLY in builder stage)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    # ADD PROJECT-SPECIFIC BUILD DEPS HERE:
    # libpq-dev       # If using PostgreSQL (psycopg2)
    # build-essential  # If using numpy/pandas/scikit
    && rm -rf /var/lib/apt/lists/*

# Install Python deps into user directory for easy copy
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# === Stage 2: Production ===
FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Install RUNTIME dependencies only (no gcc, no -dev packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    # ADD PROJECT-SPECIFIC RUNTIME DEPS HERE:
    # libpq5    # If using PostgreSQL (runtime lib, not -dev)
    # ffmpeg    # If doing audio/video processing
    && rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copy application code — ONLY directories needed at runtime
# VERIFY each COPY by tracing imports from entry point
COPY <app-dirs> .

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

EXPOSE <PORT>

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:<PORT>/health || exit 1

# For production: consider gunicorn with uvicorn workers
# CMD ["gunicorn", "<module>:app", "--workers", "2", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:<PORT>"]
CMD ["uvicorn", "<module>:app", "--host", "0.0.0.0", "--port", "<PORT>"]
```

**When to use gunicorn**: If the backend handles concurrent requests and needs multiple workers.
Add `gunicorn` to requirements.txt if using.

## TEMPLATE B: Azure Functions Backend

```dockerfile
# <PROJECT> - Azure Functions Backend
# Uses official Azure Functions Python base image

FROM mcr.microsoft.com/azure-functions/python:4-python3.11

# REQUIRED environment variables for Azure Functions runtime
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FUNCTIONS_WORKER_RUNTIME=python \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /home/site/wwwroot

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Azure Functions configuration
COPY host.json .
# WARNING: NEVER copy local.settings.json — it contains development secrets
# Use environment variables or Azure Secret Manager instead

# Copy shared modules
COPY shared/ ./shared/

# Copy EACH function directory individually
# DO NOT use "COPY . ." — it copies secrets, tests, docs, etc.
# List every function directory explicitly:
# COPY function_name_1/ ./function_name_1/
# COPY function_name_2/ ./function_name_2/
# ... (list them all)

# To generate the list automatically:
# ls -d */ | grep -v __pycache__ | grep -v .git | grep -v shared | grep -v tests | grep -v node_modules | grep -v .venv

EXPOSE 80

# Azure Functions cold start can take 30-60s — use generous start_period
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:80/api/health_check || exit 1

# Azure Functions runtime handles startup automatically (no CMD needed)
```

**IMPORTANT for Azure Functions**:
- Port is ALWAYS 80 (the Azure Functions base image configures this)
- `FUNCTIONS_WORKER_RUNTIME=python` is REQUIRED — without it, the runtime won't start
- `start_period=60s` because cold start is slow
- NEVER `COPY . .` — selectively copy each function directory
- NEVER copy `local.settings.json` into the image (secrets!)
- Health endpoint is typically `/api/health_check` (with the /api/ prefix)
