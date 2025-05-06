import http.server
import socketserver
import time

PORT = 8080

Handler = http.server.SimpleHTTPRequestHandler
httpd = socketserver.TCPServer(("", PORT), Handler)

# Keep the server running indefinitely
while True:
    httpd.handle_request()
    time.sleep(60)  # Keeps the server alive and serves requests
