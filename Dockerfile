# Use an official Ubuntu base image
FROM ubuntu:20.04

# Install necessary dependencies for cloning the repository and building the proxy
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the proxy setup
RUN mkdir -p /opt/socks5-proxy

# Clone the repository into the /opt/socks5-proxy directory
RUN git clone https://github.com/Elkafasa/socks5-proxy /opt/socks5-proxy

# Copy the sockd.conf file into the proper location
# You can modify the path as necessary
RUN cp /opt/socks5-proxy/sockd.conf /etc/socks5-proxy/

# Expose necessary port for SOCKS5 (default is 1080)
EXPOSE 1080

# Define the default command to start the SOCKS5 proxy
CMD ["sockd", "-f", "/etc/socks5-proxy/sockd.conf"]
