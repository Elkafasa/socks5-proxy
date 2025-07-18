FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libwrap0-dev \
    libpam0g-dev \
    python3 \
    python3-pip \
    procps \
    tar \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir flask requests

# Set working directory
WORKDIR /opt

# Clone your repo
RUN git clone https://github.com/Elkafasa/socks5-proxy

# Build Dante SOCKS server
RUN wget https://www.inet.no/dante/files/dante-1.4.2.tar.gz && \
    tar xzf dante-1.4.2.tar.gz && \
    cd dante-1.4.2 && \
    ./configure && make && make install && \
    cd .. && rm -rf dante-1.4.2*

# Prepare config directory
RUN mkdir -p /etc/socks5-proxy

# Fix Dante config name if needed
RUN sed 's/^method:/socksmethod:/g' /opt/socks5-proxy/sockd.conf > /etc/socks5-proxy/sockd.conf

# Copy Python scripts
COPY keep_alive.py /opt/socks5-proxy/keep_alive.py
COPY web_status.py /opt/socks5-proxy/web_status.py
RUN chmod +x /opt/socks5-proxy/*.py

# Copy ngrok config
COPY ngrok.yml /opt/socks5-proxy/ngrok.yml

# Install ngrok (v3+)
RUN curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o ngrok.tgz && \
    tar -xzf ngrok.tgz && \
    mv ngrok /usr/local/bin/ngrok && \
    chmod +x /usr/local/bin/ngrok && \
    rm ngrok.tgz

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports (even though Render auto-detects Flask via $PORT)
EXPOSE 1080 8080

# Run everything via entrypoint
ENTRYPOINT ["/entrypoint.sh"]
