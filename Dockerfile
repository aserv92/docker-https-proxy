# aserv92/https-proxy:latest
# aserv92/https-proxy:$GETSSL_VERSION
# aserv92/https-proxy:$GETSSL_VERSION-$(date +%Y-%m-%d-%H-%M-%S)
FROM alpine:3.21.2

ARG GETSSL_VERSION='2.49'

ENV GETSSL_VERSION=${GETSSL_VERSION}

RUN set -eux; \
    apk update; \
    apk upgrade; \
    apk add --no-cache bash; \
    apk add --no-cache openssl; \
    apk add --no-cache curl; \
    apk add --no-cache envsubst; \
    apk add --no-cache supervisor; \
    apk add --no-cache nginx; \
    rm -rf /var/cache/apk/*; \
    curl --silent https://raw.githubusercontent.com/srvrco/getssl/v${GETSSL_VERSION}/getssl > /usr/local/bin/getssl; \
    mkdir -p /var/www/acme-challenge/; \
    mkdir -p /etc/getssl/; \
    mkdir -p /var/getssl/; \
    mkdir -p /etc/nginx/ssl/; \
    chmod 700 /usr/local/bin/getssl;

COPY supervisor/supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
