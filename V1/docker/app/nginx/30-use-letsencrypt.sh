#!/bin/sh
set -eu

domain="${CERTBOT_PRIMARY_DOMAIN:-${TLS_SERVER_NAME:-}}"

if [ -z "$domain" ] || [ "$domain" = "localhost" ] || [ "$domain" = "_" ]; then
  exit 0
fi

cert_path="/etc/letsencrypt/live/$domain/fullchain.pem"
key_path="/etc/letsencrypt/live/$domain/privkey.pem"

if [ -f "$cert_path" ] && [ -f "$key_path" ]; then
  export TLS_SERVER_NAME="$domain"
  export TLS_CERT_PATH="$cert_path"
  export TLS_KEY_PATH="$key_path"
  echo "Using Let's Encrypt certificate for $domain"
fi
