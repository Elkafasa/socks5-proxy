import socket
import time

def keep_alive():
    while True:
        try:
            # Open a dummy SOCKS5 connection to localhost (which ngrok tunnels)
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)
            s.connect(("127.0.0.1", 1080))
            s.sendall(b"\x05\x01\x00")  # Minimal valid SOCKS5 handshake
            s.close()
        except Exception as e:
            print("Keep-alive failed:", e)
        time.sleep(300)  # Ping every 5 minutes

if __name__ == "__main__":
    keep_alive()
