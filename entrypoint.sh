#!/usr/bin/env bash

set -euo pipefail

GETSSL_DIR=/etc/getssl/

GLOBAL_CONFIG_FILE="${GETSSL_DIR}getssl.cfg"

CONFIG_FILE_PERMISSION=0644

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
  assert.env.var.exists DOMAIN_NAME 
  assert.env.var.exists PROXY_TO
  assert.env.var.exists ACCOUNT_EMAIL
}

config.global.write() {
  local key=${1}
  local val=${2}

  echo "${key}=\"${val}\"" >> "${GLOBAL_CONFIG_FILE}"
}

assert.all.required.env.vars.exists

mkdir -p "${GETSSL_DIR}"
touch "${GLOBAL_CONFIG_FILE}"
chmod ${CONFIG_FILE_PERMISSION} "${GLOBAL_CONFIG_FILE}"

config.global.write CA "${CA:-https://acme-staging-v02.api.letsencrypt.org}"

config.global.write AGREEMENT "${AGREEMENT:-}"

config.global.write ACCOUNT_KEY_LENGTH "${ACCOUNT_KEY_LENGTH:-4096}"

config.global.write ACCOUNT_EMAIL "${ACCOUNT_EMAIL}"

config.global.write ACCOUNT_KEY /var/ssl/account.key

config.global.write ACCOUNT_KEY_TYPE "${ACCOUNT_KEY_TYPE:-rsa}"

config.global.write REUSE_PRIVATE_KEY "${REUSE_PRIVATE_KEY:-true}"

config.global.write FULL_CHAIN_INCLUDE_ROOT "false"

config.global.write RELOAD_CMD 'nginx -s reload -c /etc/nginx/nginx.conf'

config.global.write RENEW_ALLOW "${RENEW_ALLOW:-30}"

config.global.write SERVER_TYPE https

config.global.write CHECK_REMOTE true

DOMAIN_NAME=$(echo "${DOMAIN_NAME}" | awk '{print tolower($0)}')

DOMAIN_CONFIG_FILE="${GETSSL_DIR}${DOMAIN_NAME}/getssl.cfg"

config.domain.write() {
  local key=${1}
  local val=${2}

  echo "${key}=\"${val}\"" >> "${DOMAIN_CONFIG_FILE}"
}

mkdir -p "${GETSSL_DIR}/${DOMAIN_NAME}"
touch ${DOMAIN_CONFIG_FILE}
chmod ${CONFIG_FILE_PERMISSION} ${DOMAIN_CONFIG_FILE}

parser.get.only.domains.from.sans.string() {
  local sans_string="${1}"

  echo ${sans_string} | awk -F, '{for (i=1; i<=NF; i++) {split($i, a, ":"); printf "%s%s", a[1], (i<NF ? "," : "\n")}}'
}

config.domain.write SANS "$(parser.get.only.domains.from.sans.string "${SANS:-}")"

config.domain.write ACL "/var/www/acme-challenge/"

config.domain.write USE_SINGLE_ACL true

config.domain.write PREFERRED_CHAIN ''

config.domain.write DOMAIN_CERT_LOCATION "/var/ssl/${DOMAIN_NAME}.crt"

config.domain.write DOMAIN_KEY_LOCATION "/var/ssl/${DOMAIN_NAME}.key"

config.domain.write CA_CERT_LOCATION "/var/ssl/${DOMAIN_NAME}.ca.crt"

config.domain.write DOMAIN_CHAIN_LOCATION "/var/ssl/${DOMAIN_NAME}.chain.crt"

export CERT_DOMAIN_NAME=${DOMAIN_NAME}

if [ ! -f "/var/ssl/${CERT_DOMAIN_NAME}.chain.crt" ] || [ ! -f "/var/ssl/${CERT_DOMAIN_NAME}.crt" ] || [ ! -f "/var/ssl/${CERT_DOMAIN_NAME}.key" ]; then
  openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:4096 \
    -keyout /var/ssl/${CERT_DOMAIN_NAME}.key \
    -out /var/ssl/${CERT_DOMAIN_NAME}.chain.crt \
    -subj "/C=US/ST=Texas/L=Houston/O=Unknown/OU=Unknown/CN=${CERT_DOMAIN_NAME}"
else
  cp "/var/ssl/${CERT_DOMAIN_NAME}.crt" "${GETSSL_DIR}${CERT_DOMAIN_NAME}/${CERT_DOMAIN_NAME}.crt"
fi

export SSL_PROTOCOLS=${SSL_PROTOCOLS:-'TLSv1.2 TLSv1.3'}

export SSL_CIPHERS=${SSL_CIPHERS:-'HIGH:!aNULL:!MD5'}

export DOLLAR='$'

envsubst < /etc/nginx/http.d/domain.conf.template > "/etc/nginx/http.d/${DOMAIN_NAME}.conf"

IFS=','
for SAN in ${SANS:-}; do
  export DOMAIN_NAME=${SAN%%:*}
  export PROXY_TO=${SAN#*:}

  envsubst < /etc/nginx/http.d/domain.conf.template > "/etc/nginx/http.d/${DOMAIN_NAME}.conf"
done
unset IFS

rm /etc/nginx/http.d/domain.conf.template

unset CONFIG_FILE_PERMISSION
unset SSL_PROTOCOLS
unset SSL_CIPHERS
unset PROXY_TO
unset DOLLAR

bash -c "$@"
