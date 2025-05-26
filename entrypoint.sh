#!/bin/bash
set -e

# Kill any existing ngrok just in case
pkill ngrok || true

# Clean old ngrok state
rm -rf /root/.ngrok2

# Ensure log directory exists
mkdir -p /var/log

echo "Starting keep_alive.py script..."
python3 /opt/socks5-proxy/keep_alive.py > /var/log/keep_alive.log 2>&1 &

echo "Starting web_status.py Flask app..."
python3 /opt/socks5-proxy/web_status.py > /var/log/web_status.log 2>&1 &

echo "Starting Dante SOCKS server..."
/usr/local/sbin/sockd -f /etc/socks5-proxy/sockd.conf > /var/log/sockd.log 2>&1 &
SOCKD_PID=$!

echo "Starting ngrok tunnel..."
ngrok start --all --config /opt/socks5-proxy/ngrok.yml --log=stdout > /var/log/ngrok.log 2>&1 &
NGROK_PID=$!

# Trap signals to gracefully shutdown all background processes
trap "echo 'Stopping services...'; kill $SOCKD_PID $NGROK_PID; kill 0; exit" SIGINT SIGTERM

# Wait on sockd and ngrok to keep the container running
wait $SOCKD_PID $NGROK_PID
