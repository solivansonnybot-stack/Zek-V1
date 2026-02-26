FROM python:3.11-slim

# Instalar dependências do sistema necessárias
RUN apt-get update && apt-get install -y \
    # Para OpenCV
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    # Para Playwright/Chromium
    chromium \
    chromium-driver \
    fonts-liberation \
    libnss3 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    # Utilitários
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /app

# Copiar requirements e instalar dependências Python
# Excluindo pyaudio (hardware de microfone local, não funciona em servidor)
COPY requirements.txt .
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn \
    python-socketio \
    python-multipart \
    google-genai \
    opencv-python-headless \
    pillow \
    mss \
    playwright \
    python-kasa \
    "zeroconf>=0.131.0" \
    "aiohttp>=3.9.0" \
    python-dotenv \
    mediapipe \
    websockets

# Instalar Playwright e o Chromium
RUN playwright install chromium
RUN playwright install-deps chromium

# Copiar os arquivos do backend
COPY backend/ ./backend/

# Copiar arquivo de modelo de face (necessário para mediapipe)
COPY backend/face_landmarker.task ./backend/face_landmarker.task

# Criar pasta de projetos
RUN mkdir -p /app/projects

# Expor porta
EXPOSE 8000

# Variáveis de ambiente para Playwright funcionar em modo headless no servidor
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PYTHONPATH=/app/backend

# Comando para iniciar o servidor
CMD ["python", "backend/server.py"]
