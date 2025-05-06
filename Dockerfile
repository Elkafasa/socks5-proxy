# Use a base image (e.g., Debian)
FROM debian:bullseye-slim

# Set environment variables to prevent interaction during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (build tools, curl, unzip, Python 3, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    unzip \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install ngrok
RUN curl -s https://bin.equinox.io/c/4VmDzA7iaJ7/ngrok-stable-linux-amd64.zip -o ngrok.zip && \
    unzip ngrok.zip && \
    chmod +x ngrok && \
    mv ngrok /usr/local/bin && \
    rm ngrok.zip

# Copy the SOCKS5 proxy files (including your socks.conf)
COPY . /app

# Set the working directory to the app directory
WORKDIR /app

# Install Python dependencies (if any, adjust if needed)
COPY requirements.txt /app/requirements.txt
RUN pip3 install -r /app/requirements.txt

# Expose the port for the SOCKS5 proxy (adjust if needed)
EXPOSE 1080

# Start the SOCKS5 proxy using your configuration and then ngrok for port forwarding.
CMD ./socks5 -c /app/socks.conf & \
    python3 keep_alive.py & \
    ngrok tcp 1080 --log=stdout & \
    tail -f /dev/null
