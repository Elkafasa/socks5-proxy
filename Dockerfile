# Use a base image with build tools
FROM debian:bullseye

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libwrap0-dev \
    libpam0g-dev \
    python3 \
    tar \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Clone your socks5-proxy config repo
WORKDIR /opt
RUN git clone https://github.com/Elkafasa/socks5-proxy

# Download and build Dante SOCKS5 proxy from source
RUN wget https://www.inet.no/dante/files/dante-1.4.2.tar.gz && \
    tar xzf dante-1.4.2.tar.gz && \
    cd dante-1.4.2 && \
    ./configure && make && make install

# Copy Dante config
RUN mkdir -p /etc/socks5-proxy && \
    cp /opt/socks5-proxy/sockd.conf /etc/socks5-proxy/

# Copy keep-alive script
COPY keep_alive.py /opt/socks5-proxy/keep_alive.py

# Install ngrok (v3)
RUN curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o ngrok.tgz && \
    tar -xzf ngrok.tgz && \
    mv ngrok /usr/local/bin/ngrok && \
    chmod +x /usr/local/bin/ngrok && \
    rm ngrok.tgz

# Add ngrok auth token
RUN ngrok config add-authtoken 2bwYpX7UTbEJ9XTZJkFJwbMsHK1_6U52YGGsG37bUmGYgQL89

# Expose SOCKS5 port
EXPOSE 1080

# Start Dante, then ngrok for that port, then run the keep-alive
CMD bash -c "/usr/local/sbin/sockd -f /etc/socks5-proxy/sockd.conf & \
             sleep 2 && \
             ngrok tcp 1080 > /opt/socks5-proxy/ngrok.log & \
             python3 /opt/socks5-proxy/keep_alive.py"
