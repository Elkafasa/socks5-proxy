FROM debian:bullseye-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libwrap0-dev \
    libpam0g-dev \
    python3 \
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

# Expose both SOCKS5 and HTTP keep-alive ports
EXPOSE 1080
EXPOSE 8080

# Start Dante and your keep-alive Python script
CMD bash -c "/usr/local/sbin/sockd -f /etc/socks5-proxy/sockd.conf & python3 /opt/socks5-proxy/keep_alive.py"
