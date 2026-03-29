FROM python:3.12-slim

# Install wget + download correct Pandoc 3.9.0.2 static binary for Linux amd64
RUN apt-get update && apt-get install -y wget ca-certificates && \
    wget --tries=5 --timeout=15 --waitretry=5 \
         https://github.com/jgm/pandoc/releases/download/3.9.0.2/pandoc-3.9.0.2-linux-amd64.tar.gz && \
    tar xvzf pandoc-*.tar.gz --strip-components=2 -C /usr/local/bin pandoc-*/bin/pandoc && \
    rm -rf pandoc* && \
    apt-get remove -y wget && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Render free tier uses port 10000 internally
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]
