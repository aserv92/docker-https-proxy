# Docker HTTPS Proxy
A docker image for providing secure HTTPS connections for web servers not using SSL.

[View on Dockerhub](https://hub.docker.com/repository/docker/aserv92/https-proxy/)

## How it Works
The environment variables described below are used to generate configuration files for [get-ssl](https://github.com/srvrco/getssl). This image runs a nginx web server and a get-ssl deamon. The nginx web server and listens for HTTP and HTTPS requests on their respective ports. HTTP requests are redirected to HTTPS and HTTPS requests are forwarded to the target webserver. When the image starts and once an hour the get-ssl daemon checks if it is time to request and install new SSL certificate and installs them when it is time. If no SSL cert exists when the image is sstarted then one will be created.

## Environment variables

### Required variables
- `DOMAIN_NAME` The primary domain (CN) on the SSL certificate (ex: `yourdomain.com`)
- `PROXY_TO` Webserver to redirect requests to (ex: `http://yourwebsite.local`)
- `ACCOUNT_EMAIL` Account email, if you need to be contacted by the CA

### get-ssl variables
These variables are used to configure get-ssl. See https://github.com/srvrco/getssl/wiki/Config-variables
- `CA`
- `AGREEMENT`
- `ACCOUNT_KEY_LENGTH`
- `ACCOUNT_EMAIL`
- `ACCOUNT_KEY_TYPE`
- `REUSE_PRIVATE_KEY`
- `RENEW_ALLOW`

### Other
- `SANS` A list of SANS and proxy to addresses to request the certificate for (ex: `www.yourdomain.com:http://yourwebsite.local,blog.yourwebsite.com:http://yourblog.local`)
- `SSL_PROTOCOLS` List of SSL protocols to pass to nginx (ex: `TLSv1.2 TLSv1.3`)
- `SSL_CIPHERS` Ciphers to pass to nginx (ex: `HIGH:!aNULL:!MD5`)

## Pitfalls
This does not work out of the box with wildcard subdomains as they can not be verified using http-01. Wildcard subdomains require DNS verification which meaning a DNS record needs to be added using an API depending on which DNS service you are using.

get-ssl does support domain verification via DNS, the problem is every service has a script to add and remove DNS records. See: [get-ssl DNS scripts](https://github.com/srvrco/getssl/tree/v2.49/dns_scripts)
