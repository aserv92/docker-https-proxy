# Docker HTTPS Proxy
A docker image for providing secure HTTPS connections for web servers not using SSL.

[View on Dockerhub](https://hub.docker.com/repository/docker/aserv92/https-proxy/)

## How it Works
The environment variables described below are used to generate configuration files for [get-ssl](https://github.com/srvrco/getssl). This image runs a nginx web server and a get-ssl deamon. The nginx web server listens for HTTP and HTTPS requests on their respective ports. HTTP requests are redirected to HTTPS and HTTPS requests are forwarded to the target webserver. When the image starts and once an hour the get-ssl daemon checks if it is time to request and install new SSL certificate and installs them if necessary. If no SSL certificate exists when the image is started then one will be created.

## Configuration

### SSL Certificate Storage
SSL Certificates and the account key are stored in `/var/ssl/`. This information should be preserved to avoid requesting new SSL certificates everytime the container starts.

### Domain Validation
#### ACL (Acme Challenge Location)
ACL (Acme Challenge Location) is the default domain validation method, but is not compatible with wildcard domains. If you need a SSL certificate for a wildcard domain then use domain validation via DNS.

#### Domain Validation via DNS
To enable domain validation via DNS set the `VALIDATE_VIA_DNS` environment variable to `true`. When `VALIDATE_VIA_DNS` is set to `true` the environemnt variable `DNS_PROVIDER` will be required.

get-ssl provides [DNS scripts](https://github.com/srvrco/getssl/tree/v2.49/dns_scripts) for many DNS providers. The `DNS_PROVIDER` variable should be a provider name from this [list](https://github.com/srvrco/getssl/tree/v2.49/dns_scripts). Any provider that has a script begining with `dns_add_` and `dns_del_` should work.

Some of the DNS scripts may have extra dependencies that are not currently supported.

##### Example (cPanel)
```
  VALIDATE_VIA_DNS=true
  DNS_PROVIDER="cpanel"
  CPANEL_USERNAME=''
  CPANEL_URL='https://www.cpanel.host:2083'
  CPANEL_APITOKEN='1ABC2DEF3GHI4JKL5MNO6PQR7STU8VWX9YZA'
```

#### Domain Validation via AWS Route 53
Image tags containing `route53` are for use with AWS Route 53 domain validation. When using these images it is assumed we are validating the domain via DNS and the DNS provider is AWS Route 53.

The following environment variables are no longer required for route 53 images:
- `VALIDATE_VIA_DNS`
- `DNS_PROVIDER`

The following environment variables are required for route 53 images:
- `AWS_ACCESS_KEY`
- `AWS_SECRET_KEY`

### Environment variables

#### Required variables
- `DOMAIN_NAME` The primary domain (CN) on the SSL certificate (ex: `yourdomain.com`)
- `PROXY_TO` Webserver to redirect requests to (ex: `http://yourwebsite.local`)
- `ACCOUNT_EMAIL` Account email, if you need to be contacted by the CA

#### get-ssl variables
These variables are used to configure get-ssl. See https://github.com/srvrco/getssl/wiki/Config-variables
- `CA`
- `AGREEMENT`
- `ACCOUNT_KEY_LENGTH`
- `ACCOUNT_EMAIL`
- `ACCOUNT_KEY_TYPE`
- `REUSE_PRIVATE_KEY`
- `RENEW_ALLOW`
- `PREFERRED_CHAIN`
- `VALIDATE_VIA_DNS` * See "Domain Validation Via DNS" above

#### Other
- `DNS_PROVIDER` See "Domain Validation Via DNS" above
- `SANS` A list of SANS and proxy to addresses to request the certificate for (ex: `www.yourdomain.com:http://yourwebsite.local,blog.yourwebsite.com:http://yourblog.local`)
- `SSL_PROTOCOLS` List of SSL protocols to pass to nginx (default: `TLSv1.2 TLSv1.3`)
- `SSL_CIPHERS` Ciphers to pass to nginx (default: `HIGH:!aNULL:!MD5`)
- `AWS_ACCESS_KEY` See "AWS Route 53 Domain Validation" above
- `AWS_SECRET_KEY` See "AWS Route 53 Domain Validation" above
