#!/usr/bin/env bash

set -euo pipefail

if [[ "${VALIDATE_VIA_DNS:-true}" != 'true' ]]; then
  echo 'The VALIDATE_VIA_DNS environement variable is set to a value other than true.' >&2
  echo 'Domain validation via Route 53 DNS is forced in this image.' >&2
  echo 'This image does not require the VALIDATE_VIA_DNS environement variable to be set.' >&2

  exit 1
fi

if [[ "${DNS_PROVIDER:-route53}" != 'route53' ]]; then
  echo 'The DNS_PROVIDER environement variable is set to a value other than route53.' >&2
  echo 'Domain validation via Route 53 DNS is forced in this image.' >&2
  echo 'This image does not require the DNS_PROVIDER environement variable to be set.' >&2

  exit 1
fi

export VALIDATE_VIA_DNS=true
export DNS_PROVIDER=route53

error.missing.required.variable() {
  local var=${1}

  echo "The '${var}' environment variable is required" >&2

  exit 1
}

assert.env.var.exists() {
  local var=${1}

  [[ -z "$(eval echo \${${var}:-})" ]] && error.missing.required.variable "${var}" || return 0
}

assert.all.required.env.vars.exists() {
  assert.env.var.exists AWS_ACCESS_KEY
  assert.env.var.exists AWS_SECRET_KEY
}

assert.all.required.env.vars.exists

envsubst < /root/.aws/credentials.template > /root/.aws/credentials

rm /root/.aws/credentials.template

/usr/local/bin/http-proxy-entrypoint.sh "$@"
