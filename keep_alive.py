import subprocess
import time
import requests
import re
import os

# Start ngrok TCP tunnel to port 1080
subprocess.Popen(["ngrok", "tcp", "1080"])
time.sleep(5)  # Give ngrok time to initialize

def print_proxy_info():
    try:
        res = requests.get("http://localhost:4040/api/tunnels")
        tunnels = res.json().get("tunnels", [])
        for tunnel in tunnels:
            if tunnel["proto"] == "tcp":
                addr = tunnel["public_url"]
                host, port = re.findall(r"tcp://(.+):(\d+)", addr)[0]
                os.system("clear")
                print("✅ SOCKS5 Proxy is Running!\n")
                print("Use this proxy on your MacBook:\n")
                print(f"Host: {host}")
                print(f"Port: {port}")
                print(f"Protocol: SOCKS5\n")
                print("📘 Set it in System Settings > Network > Proxies")
                print("Or use it in Terminal:\n")
                print(f"curl --socks5-hostname {host}:{port} https://example.com")
    except Exception as e:
        print(f"❌ Error fetching ngrok info: {e}")

while True:
    print_proxy_info()
    time.sleep(30)
