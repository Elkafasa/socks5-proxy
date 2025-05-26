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

echo "Starting Dante SOCKS server..."
/usr/local/sbin/sockd -f /etc/socks5-proxy/sockd.conf > /var/log/sockd.log 2>&1 &
SOCKD_PID=$!

echo "Starting ngrok tunnel..."
ngrok start --all --config /opt/socks5-proxy/ngrok.yml --log=stdout > /var/log/ngrok.log 2>&1 &
NGROK_PID=$!

# Function to safely kill a process if it exists
safe_kill() {
  if kill -0 "$1" 2>/dev/null; then
    kill "$1"
  fi
}

trap "echo 'Stopping services...'; safe_kill $SOCKD_PID; safe_kill $NGROK_PID; kill 0; exit" SIGINT SIGTERM

echo "Starting Flask app to keep container alive and bind to PORT=$PORT..."
python3 /opt/socks5-proxy/web_status.py  # <-- Foreground process
