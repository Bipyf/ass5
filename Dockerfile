
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Run unit tests during build-time if you want to fail fast (optional).
# Uncomment if desired:
# RUN pytest -q

# Default command runs the "research" script
CMD ["python", "budget_analyzer.py"]
