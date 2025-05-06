FROM alpine:latest

# Install dependencies
RUN apk add --no-cache dante-server python3

# Copy config file
COPY sockd.conf /etc/sockd.conf

# Expose ports
EXPOSE 1080 8080

# Start both the Dante SOCKS5 server and a basic HTTP server
CMD python3 -m http.server 8080 & sockd -f /etc/sockd.conf
