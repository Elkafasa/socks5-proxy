FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    dante-server \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Clone your GitHub repo
RUN mkdir -p /opt/socks5-proxy
RUN git clone https://github.com/Elkafasa/socks5-proxy /opt/socks5-proxy

# Copy sockd.conf into system location
RUN mkdir -p /etc/socks5-proxy
RUN cp /opt/socks5-proxy/sockd.conf /etc/socks5-proxy/

# Expose proxy and keep-alive ports
EXPOSE 1080
EXPOSE 8080

# Start SOCKS5 server and keep-alive script
CMD bash -c "sockd -f /etc/socks5-proxy/sockd.conf & python3 /opt/socks5-proxy/keep_alive.py"
