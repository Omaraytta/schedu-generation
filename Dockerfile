FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Remove PORT from build-time ENV
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

# Install gunicorn explicitly
RUN pip install --no-cache-dir gunicorn==21.2.0

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m myuser
USER myuser

# Use fixed port in EXPOSE (documentation only)
EXPOSE 8000

# Start with static port configuration
CMD ["gunicorn", "app:app", \
    "--bind", "0.0.0.0:8000", \
    "--workers", "2", \
    "--threads", "4"]
