FROM ghcr.io/linuxserver/baseimage-alpine:3.17
LABEL maintainer="Julio Gutierrez julio.guti+nordlynx@pm.me"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /

RUN chmod -R 755 /etc/cont-init.d
RUN chmod -R 755 /etc/services.d/wireguard
RUN chmod -R 755 /patch

RUN apk add --no-cache -U wireguard-tools curl jq patch && \
	patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
	rm -rf /tmp/* /patch
