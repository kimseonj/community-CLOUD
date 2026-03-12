#!/bin/sh
set -eu

CERTBOT_STAGING="${CERTBOT_STAGING:-false}"
DOMAIN_ARGS=""

if [ "${CERTBOT_MODE:-issue}" = "renew" ]; then
  exec certbot renew --webroot -w "${WEBROOT_PATH:-/var/www/certbot}" --keep-until-expiring
fi

if [ -z "${CERTBOT_EMAIL:-}" ] || [ -z "${CERTBOT_DOMAINS:-}" ]; then
  echo "CERTBOT_EMAIL and CERTBOT_DOMAINS must be set"
  exit 1
fi

for domain in $(echo "${CERTBOT_DOMAINS}" | tr ',' ' '); do
  [ -z "$domain" ] && continue
  DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
done

if [ -z "$DOMAIN_ARGS" ]; then
  echo "CERTBOT_DOMAINS is invalid"
  exit 1
fi

STAGING_FLAG=""
if [ "$CERTBOT_STAGING" = "true" ]; then
  STAGING_FLAG="--staging"
fi

exec certbot certonly --webroot -w "${WEBROOT_PATH:-/var/www/certbot}" \
  $STAGING_FLAG \
  --email "$CERTBOT_EMAIL" \
  --agree-tos \
  --non-interactive \
  --keep-until-expiring \
  --expand $DOMAIN_ARGS
