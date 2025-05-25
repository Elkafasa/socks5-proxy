import socket
import time
import requests
import tempfile
import os
import json

NGROK_API = "http://localhost:4040/api/tunnels"

def get_ngrok_tcp_address():
    try:
        resp = requests.get(NGROK_API, timeout=5)
        tunnels = resp.json().get("tunnels", [])
        for tunnel in tunnels:
            if tunnel.get("proto") == "tcp":
                return tunnel["public_url"].replace("tcp://", "")
    except Exception as e:
        log(f"Could not retrieve Ngrok tunnel: {e}")
    return None

def print_instructions():
    ngrok_address = get_ngrok_tcp_address()
    if not ngrok_address:
        print("⚠️  Ngrok tunnel not found. Check if it's running properly.")
        return

    host, port = ngrok_address.split(":")
    print("\n" + "="*60)
    print("✅ SOCKS5 Proxy is Running via Ngrok!")
    print("\n🔌 Connect using:")
    print(f"  ➤ Host: {host}")
    print(f"  ➤ Port: {port}")
    print("  ➤ Type: SOCKS5")

    print("\n💻 On your MacBook Air:")
    print("  ➤ System Settings > Network > Proxies")
    print(f"  ➤ Enable SOCKS Proxy with {host}:{port}")

    print("\n🌐 Or use Terminal:")
    print(f"  ➤ networksetup -setsocksfirewallproxy Wi-Fi {host} {port}")
    print("  ➤ networksetup -setsocksfirewallproxystate Wi-Fi on")
    print("="*60 + "\n")

def ping_socks5():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect(("127.0.0.1", 1080))
        s.sendall(b"\x05\x01\x00")
        s.close()
        log("SOCKS5 keep-alive successful.")
    except Exception as e:
        log(f"SOCKS5 keep-alive failed: {e}")

def ping_http():
    try:
        r = requests.get("http://localhost", timeout=5)
        log(f"HTTP keep-alive successful (Status: {r.status_code})")
    except Exception as e:
        log(f"HTTP keep-alive failed: {e}")

def log(msg):
    print(f"[+] {msg}")
    with open(temp_log_file.name, "a") as f:
        f.write(msg + "\n")

def keep_alive():
    print("Starting keep-alive and Ngrok monitor...\n")
    # Wait a bit to ensure ngrok tunnel is up
    time.sleep(10)
    print_instructions()
    while True:
        ping_socks5()
        ping_http()
        time.sleep(300)

if __name__ == "__main__":
    with tempfile.NamedTemporaryFile(delete=True) as temp_log_file:
        keep_alive()
