FROM serjs/go-socks5-proxy

EXPOSE 1080

CMD ["-username", "user", "-password", "pass"]
