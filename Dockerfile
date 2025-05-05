FROM serjs/go-socks5-proxy
EXPOSE 1080
CMD ["-username", "proxyuser", "-password", "proxypass"]
