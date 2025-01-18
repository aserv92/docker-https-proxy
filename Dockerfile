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
    curl -L -o "/tmp/getssl-${GETSSL_VERSION}.tar.gz" "https://github.com/srvrco/getssl/archive/refs/tags/v${GETSSL_VERSION}.tar.gz"; \
    tar -xzf "/tmp/getssl-${GETSSL_VERSION}.tar.gz" -C "/tmp/"; \
    cp "/tmp/getssl-${GETSSL_VERSION}/getssl" /usr/local/bin/getssl; \
    mkdir -p /usr/share/getssl/dns_scripts/; \
    cp -r "/tmp/getssl-${GETSSL_VERSION}/dns_scripts/" "/usr/share/getssl/"; \
    rm "/tmp/getssl-${GETSSL_VERSION}.tar.gz"; \
    rm -r "/tmp/getssl-${GETSSL_VERSION}"; \
    mkdir -p /var/www/acme-challenge/; \
    mkdir -p /etc/getssl/; \
    mkdir -p /var/getssl/; \
    mkdir -p /etc/nginx/ssl/; \
    chmod 700 /usr/local/bin/getssl;

COPY supervisor/supervisord.conf /etc/supervisord.conf

COPY supervisor/nginx.conf /etc/supervisor.d/nginx.conf

COPY supervisor/get-ssl.conf /etc/supervisor.d/get-ssl.conf

COPY nginx/domain.conf.template /etc/nginx/http.d/domain.conf.template

COPY get-ssl/get-ssld /usr/local/bin/get-ssld

COPY entrypoint.sh /usr/local/bin/http-proxy-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/http-proxy-entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
