FROM vaultwarden/server:latest-alpine
WORKDIR /render

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

# Instalasi paket via apk
# proxychains-ng adalah padanan proxychains4 di Alpine
RUN apk add --no-cache \
    ca-certificates \
    netcat-openbsd \
    proxychains-ng \
    wget \
    bind-tools \
    bash

RUN echo "+search +short" > /root/.digrc
COPY run-tailscale.sh /render/

COPY install-tailscale.sh /tmp
RUN chmod +x /tmp/install-tailscale.sh && /tmp/install-tailscale.sh && rm -rf /tmp/*

CMD ["./run-tailscale.sh"]
