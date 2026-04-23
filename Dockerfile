FROM vaultwarden/server:latest-alpine
WORKDIR /render

# Instalasi paket dasar
RUN apk add --no-cache ca-certificates wget netcat-openbsd bash bind-tools

# Install GOST (Alternatif ProxyChains yang lebih stabil)
RUN wget -qO- https://github.com/go-gost/gost/releases/download/v3.2.6/gost_3.2.6_linux_amd64.tar.gz | gzip -d > /usr/local/bin/gost \
    && chmod +x /usr/local/bin/gost

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

COPY run-tailscale.sh /render/
COPY install-tailscale.sh /tmp
RUN chmod +x /tmp/install-tailscale.sh && /tmp/install-tailscale.sh && rm -rf /tmp/*

CMD ["./run-tailscale.sh"]
