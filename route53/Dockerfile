# aserv92/https-proxy:$GETSSL_VERSION-route53
# aserv92/https-proxy:$GETSSL_VERSION-route53-$(date +%Y-%m-%d-%H-%M-%S)
ARG FROM_TAG=latest

FROM aserv92/https-proxy:${FROM_TAG}

RUN set -eux; \
    apk update; \
    apk add --no-cache py3-boto3; \
    apk add --no-cache py3-dnspython; \
    rm -rf /var/cache/apk/*; \
    ln -s /usr/share/getssl/dns_scripts/dns_route53.py /usr/share/getssl/dns_scripts/dns_add_route53; \
    ln -s /usr/share/getssl/dns_scripts/dns_route53.py /usr/share/getssl/dns_scripts/dns_del_route53; \
    sed 's/except dns\.resolver\.NXDOMAIN:/except dns\.resolver\.NoAnswer:/g' /usr/share/getssl/dns_scripts/dns_route53.py > /tmp/dns_route53.py; \
    mv /tmp/dns_route53.py /usr/share/getssl/dns_scripts/dns_route53.py; \
    chmod 0755 /usr/share/getssl/dns_scripts/dns_route53.py;

COPY route53/credentials.template /root/.aws/credentials.template

COPY route53/entrypoint.sh /usr/local/bin/http-proxy-route53-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/http-proxy-route53-entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
