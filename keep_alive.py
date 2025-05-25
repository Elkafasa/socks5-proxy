import socket
import time
import requests

def ping_socks5():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect(("127.0.0.1", 1080))
        s.sendall(b"\x05\x01\x00")  # Minimal valid SOCKS5 handshake
        s.close()
        print("[✓] SOCKS5 keep-alive successful.")
    except Exception as e:
        print("[×] SOCKS5 keep-alive failed:", e)

def ping_http():
    try:
        r = requests.get("http://localhost", timeout=5)
        print(f"[✓] HTTP keep-alive successful. Status: {r.status_code}")
    except Exception as e:
        print("[×] HTTP keep-alive failed:", e)

def keep_alive():
    print("[*] Starting Render keep-alive loop...")
    while True:
        ping_socks5()
        ping_http()
        time.sleep(300)  # Every 5 minutes

if __name__ == "__main__":
    keep_alive()
