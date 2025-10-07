# Use lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy script into container
COPY listmonk_to_sheets.py /app/listmonk_to_sheets.py
COPY ../credentials.json /app/credentials.json

# Run the script by default
CMD ["python", "listmonk_to_sheets.py"]
