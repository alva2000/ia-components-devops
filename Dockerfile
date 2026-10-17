# Construir en Debian evita copiar metadatos antiguos de las capas python:slim.
FROM debian:trixie-slim AS builder
ENV DEBIAN_FRONTEND=noninteractive PIP_NO_CACHE_DIR=1
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /build
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements-docker.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements-docker.txt \
    && pip install --no-cache-dir --upgrade \
       'urllib3>=2.8.0' 'msgpack>=1.2.1' \
    && pip check \
    && python -m pip uninstall -y setuptools wheel pip \
    && python -c "import streamlit, fastembed, faiss, msgpack, urllib3; print('Runtime Python validado')"

FROM debian:trixie-slim AS prepared-runtime
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY . .
RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app

# Copiar el filesystem actualizado a una sola capa final. Evita que
# metadatos obsoletos de capas históricas se reporten como paquetes activos.
# Trivy sigue inspeccionando el sistema operativo y las librerías del resultado.
FROM scratch
COPY --from=prepared-runtime / /
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"
WORKDIR /app
USER appuser
EXPOSE 8501
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8501/_stcore/health', timeout=3)" || exit 1
CMD ["python", "-m", "streamlit", "run", "app.py", "--server.address=0.0.0.0", "--server.port=8501", "--server.headless=true"]
