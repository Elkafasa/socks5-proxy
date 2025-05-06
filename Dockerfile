FROM debian:bullseye-slim

# Install dante-server (SOCKS5) and Python3
RUN apt-get update && \
    apt-get install -y dante-server python3 && \
    apt-get clean

# Copy configuration file
COPY sockd.conf /etc/sockd.conf

# Expose both the SOCKS5 port and fake web server port
EXPOSE 1080 8080

# Start both the SOCKS5 proxy and fake Python HTTP server
CMD sockd -f /etc/sockd.conf & python3 -m http.server 8080 --bind 0.0.0.0
