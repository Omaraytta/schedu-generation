FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    LARAVEL_URL=https://your-laravel-app.up.railway.app \
    API_KEY=your_shared_secret

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m myuser
USER myuser

# Expose port
EXPOSE $PORT

# Start the application
CMD ["gunicorn", "app:app", \
    "--bind", "0.0.0.0:$PORT", \
    "--workers", "2", \
    "--threads", "4"]
