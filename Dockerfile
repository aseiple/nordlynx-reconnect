FROM ghcr.io/linuxserver/baseimage-alpine:3.17
LABEL maintainer="Julio Gutierrez julio.guti+nordlynx@pm.me"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /
RUN touch /tmp/used_servers

RUN chmod -R 755 /tmp/used_servers
RUN chmod -R 755 /etc/cont-init.d
RUN chmod -R 755 /etc/services.d/wireguard
RUN chmod -R 755 /etc/clear_used_servers.sh
RUN chmod -R 755 /patch

RUN apk add --no-cache -U wireguard-tools curl jq patch busybox-suid openrc && \
	patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
	rm -rf /tmp/* /patch

RUN echo "RUN echo "0 12 * * * /etc/clear_used_servers.sh" > /etc/crontabs/root"
CMD ["crond", "-f", "-l", "2"]
