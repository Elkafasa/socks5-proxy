from flask import Flask, render_template_string
import requests

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
    code { background: #222; padding: 0.5em; display: block; white-space: pre; }
  </style>
</head>
<body>
  <h1>🧪 SOCKS5 Proxy is Running</h1>
  <p><strong>Ngrok Address:</strong></p>
  <code>{{ ngrok_url }}</code>
  <p><strong>How to connect from macOS:</strong></p>
  <code>System Settings → Network → Proxies → SOCKS Proxy

Server: {{ ngrok_host }}
Port:   {{ ngrok_port }}

Type:   SOCKS5 (No Auth)</code>
  <p>This page refreshes every 30 seconds to keep the Render service alive.</p>
</body>
</html>
"""

def get_ngrok_tcp():
    try:
        res = requests.get("http://localhost:4040/api/tunnels", timeout=2)
        tunnels = res.json().get("tunnels", [])
        for t in tunnels:
            if t.get("proto") == "tcp":
                return t["public_url"].replace("tcp://", "")
    except Exception as e:
        print(f"[web_status] Could not fetch Ngrok tunnel: {e}")
    return ""

@app.route("/")
def index():
    addr = get_ngrok_tcp()
    if ":" in addr:
        host, port = addr.split(":")
    else:
        host, port = "Not Available", "N/A"
        addr = "Ngrok tunnel not ready"
    return render_template_string(HTML_TEMPLATE, ngrok_url=addr, ngrok_host=host, ngrok_port=port)

if __name__ == "__main__":
    # One-time startup (no infinite loop), Render will keep it alive.
    app.run(host="0.0.0.0", port=8080)
