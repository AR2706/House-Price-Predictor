# --- Stage 1: Build Stage ---
# Use an official Python runtime as a parent image
FROM python:3.11-slim as builder

# Set the working directory in the container
WORKDIR /app

# Install build-essential for compiling some Python packages
RUN apt-get update && apt-get install -y build-essential --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Use pip wheel to pre-compile dependencies, which can speed up the final build
RUN pip wheel --no-cache-dir --wheel-dir /app/wheels -r requirements.txt

# --- Stage 2: Final Production Stage ---
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the pre-compiled wheels from the builder stage
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Install the dependencies from the wheels
RUN pip install --no-cache /wheels/*

# Copy all your application files into the container
# This includes app.py, the .pickle model, .json columns, and the templates/ folder
COPY . .

# Expose the port that Flask will run on
EXPOSE 5000

# Use Gunicorn, a production-ready web server, to run the Flask app
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
