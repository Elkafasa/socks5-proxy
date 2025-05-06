import time
import requests
import subprocess
import re

def get_ngrok_tcp_address():
    try:
        result = subprocess.run(
            ["curl", "-s", "http://localhost:4040/api/tunnels"],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            data = result.stdout
            match = re.search(r'"public_url":"tcp://(.+?)"', data)
            if match:
                return match.group(1)
    except Exception as e:
        return None
    return None

def show_instructions(address):
    host, port = address.split(":")
    print("\n==================== SOCKS5 PROXY READY ====================")
    print(f"🔗 Proxy address: {host}:{port}")
    print("📌 macOS setup:")
    print("    - System Settings > Network > Advanced > Proxies")
    print("    - Enable SOCKS Proxy and enter:")
    print(f"        Server: {host}")
    print(f"        Port:   {port}")
    print("===========================================================\n")

def keep_alive():
    while True:
        address = get_ngrok_tcp_address()
        if address:
            show_instructions(address)
        else:
            print("🔄 Waiting for ngrok tunnel to come online...")
        time.sleep(60)

if __name__ == "__main__":
    keep_alive()
