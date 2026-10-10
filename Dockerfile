FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY requirements-docker.txt .

RUN python -m pip install --upgrade pip

# PyTorch CPU: no necesitamos CUDA/GPU
RUN pip install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cpu \
    torch

RUN pip install --no-cache-dir -r requirements-docker.txt \
    && pip install --no-cache-dir --upgrade \
        'setuptools>=78.1.1' 'wheel>=0.46.2' \
        'urllib3>=2.8.0' 'msgpack>=1.2.1' 'jaraco.context>=6.1.0' \
    && pip check

COPY . .

RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 8501

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=60s \
    --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8501/_stcore/health', timeout=3)" || exit 1

CMD ["python", "-m", "streamlit", "run", "app.py", "--server.address=0.0.0.0", "--server.port=8501", "--server.headless=true"]