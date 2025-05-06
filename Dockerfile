# Use a base image (e.g., Debian)
FROM debian:bullseye-slim

# Set environment variables to prevent interaction during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (build tools, curl, unzip, Python 3, etc.)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libwrap0-dev \
    libpam0g-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Clone your socks5-proxy config repo
WORKDIR /opt
RUN git clone https://github.com/Elkafasa/socks5-proxy

# Download and build Dante SOCKS5 proxy from source
RUN wget https://www.inet.no/dante/files/dante-1.4.2.tar.gz && \
    tar xzf dante-1.4.2.tar.gz && \
    cd dante-1.4.2 && \
    ./configure && make && make install

# Copy config
RUN mkdir -p /etc/socks5-proxy && \
    cp /opt/socks5-proxy/sockd.conf /etc/socks5-proxy/

# Copy your keep-alive script into the image
COPY keep_alive.py /opt/socks5-proxy/keep_alive.py

# Install ngrok
RUN curl -s https://bin.equinox.io/c/4VmDzA7iaJ7/ngrok-stable-linux-amd64.zip -o ngrok.zip && \
    unzip ngrok.zip && \
    chmod +x ngrok && \
    mv ngrok /usr/local/bin && \
    rm ngrok.zip

# Expose both SOCKS5 and HTTP keep-alive ports
EXPOSE 1080
EXPOSE 8080

# Set ngrok auth token
ENV NGROK_AUTH_TOKEN=2bwYpX7UTbEJ9XTZJkFJwbMsHK1_6U52YGGsG37bUmGYgQL89

# Authenticate ngrok using the provided token
RUN ngrok authtoken $NGROK_AUTH_TOKEN

# Start Dante and ngrok, along with the keep-alive Python script
CMD bash -c "/usr/local/sbin/sockd -f /etc/socks5-proxy/sockd.conf & \
    python3 /opt/socks5-proxy/keep_alive.py & \
    ngrok tcp 1080 --log=stdout & \
    tail -f /dev/null"
