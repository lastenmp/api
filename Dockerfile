FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Render injects the $PORT variable — we read it properly in Python
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]
