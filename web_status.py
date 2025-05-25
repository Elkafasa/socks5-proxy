from flask import Flask, render_template_string
import requests
import time

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
  <title>SOCKS5 Proxy Status</title>
  <meta http-equiv="refresh" content="30">
  <style>
    body { font-family: monospace; background: #111; color: #0f0; padding: 2em; }
    h1 { color: #0ff; }
    code { background: #222; padding: 0.5em; display: block; }
  </style>
</head>
<body>
  <h1>🧪 SOCKS5 Proxy is Running</h1>
  <p><strong>Ngrok Address:</strong></p>
  <code>{{ ngrok_url }}</code>
  <p><strong>How to connect from macOS:</strong></p>
  <code>System Preferences → Network → Proxies → SOCKS Proxy<br>
  Server: {{ ngrok_host }}<br>
  Port: {{ ngrok_port }}</code>
  <p>This page refreshes every 30 seconds to keep the Render service alive.</p>
</body>
</html>
"""

def get_ngrok_tcp():
    try:
        res = requests.get("http://localhost:4040/api/tunnels")
        tunnels = res.json().get("tunnels", [])
        for t in tunnels:
            if t["proto"] == "tcp":
                return t["public_url"].replace("tcp://", "")
    except Exception:
        return "Fetching ngrok address..."

@app.route("/")
def index():
    addr = get_ngrok_tcp()
    if ":" in addr:
        host, port = addr.split(":")
    else:
        host, port = ("...", "...")
    return render_template_string(HTML_TEMPLATE, ngrok_url=addr, ngrok_host=host, ngrok_port=port)

if __name__ == "__main__":
    while True:
        try:
            app.run(host="0.0.0.0", port=8080)
        except Exception as e:
            print("Web server failed, restarting:", e)
            time.sleep(2)
