FROM debian:bullseye

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libwrap0-dev \
    libpam0g-dev \
    python3 \
    python3-pip \
    tar \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python requests
RUN pip3 install requests

# Set working directory
WORKDIR /opt

# Clone repo
RUN git clone https://github.com/Elkafasa/socks5-proxy

# Build Dante from source
RUN wget https://www.inet.no/dante/files/dante-1.4.2.tar.gz && \
    tar xzf dante-1.4.2.tar.gz && \
    cd dante-1.4.2 && \
    ./configure && make && make install

# Fix sockd.conf (deprecation patch)
RUN mkdir -p /etc/socks5-proxy && \
    sed 's/^method:/socksmethod:/g' /opt/socks5-proxy/sockd.conf > /etc/socks5-proxy/sockd.conf

# Add fake website files
RUN mkdir -p /opt/fake_site
COPY index.html /opt/fake_site/index.html

# Copy keep_alive script
COPY keep_alive.py /opt/socks5-proxy/keep_alive.py
RUN chmod +x /opt/socks5-proxy/keep_alive.py

# Copy ngrok config
RUN mkdir -p /root/.config/ngrok
COPY ngrok.yml /root/.config/ngrok/ngrok.yml

# Install ngrok v3
RUN curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o ngrok.tgz && \
    tar -xzf ngrok.tgz && \
    mv ngrok /usr/local/bin/ngrok && \
    chmod +x /usr/local/bin/ngrok && \
    rm ngrok.tgz

EXPOSE 1080
EXPOSE 80

# Final command
CMD bash -c "/usr/local/sbin/sockd -f /etc/socks5-proxy/sockd.conf & \
             python3 -m http.server 80 --directory /opt/fake_site & \
             ngrok start --all & \
             python3 /opt/socks5-proxy/keep_alive.py"

