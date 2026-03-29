FROM python:3.12-slim

# Install wget temporarily + download the latest Pandoc static binary
RUN apt-get update && apt-get install -y wget && \
    wget https://github.com/jgm/pandoc/releases/latest/download/pandoc-3.9.0.2-1-amd64.tar.gz && \
    tar xvzf pandoc-*.tar.gz --strip-components=2 -C /usr/local/bin pandoc-*/bin/pandoc && \
    rm -rf pandoc* && \
    apt-get remove -y wget && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Render provides $PORT environment variable
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "${PORT:-8000}"]
