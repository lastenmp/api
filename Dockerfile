FROM python:3.12-slim

# Install wget + download latest Pandoc static binary (update version if needed)
RUN apt-get update && apt-get install -y wget && \
    wget https://github.com/jgm/pandoc/releases/latest/download/pandoc-3.6.3-1-amd64.tar.gz && \
    tar xvzf pandoc-*.tar.gz --strip-components=2 -C /usr/local/bin pandoc-*/bin/pandoc && \
    rm -rf pandoc* && \
    apt-get remove -y wget && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Use $PORT from Render
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "${PORT:-8000}"]
