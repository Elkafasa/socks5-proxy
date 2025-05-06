FROM debian:bullseye-slim

# Install necessary packages (Dante + Python and utilities)
RUN apt-get update && apt-get install -y \
    dante-server \
    python3 \
    python3-pip \
    ca-certificates \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install any required Python packages (if you need any)
# RUN pip3 install -r requirements.txt

# Expose the ports needed for SOCKS5 and HTTP (if using web service)
EXPOSE 1080 8080

# Copy the sockd.conf file into the container
COPY sockd.conf /etc/sockd.conf

# Create a simple keep-alive service (e.g., Python HTTP server)
COPY keep_alive.py /keep_alive.py
RUN chmod +x /keep_alive.py

# Start Dante SOCKS server (sockd) and the keep-alive service
CMD ["sh", "-c", "sockd & python3 /keep_alive.py"]
