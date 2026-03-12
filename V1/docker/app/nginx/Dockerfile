FROM nginx:1.27-alpine

# Nginx official image renders templates from /etc/nginx/templates at startup.
COPY default.conf.template /etc/nginx/templates/default.conf.template

RUN apk add --no-cache openssl \
  && mkdir -p /etc/nginx/selfsigned \
  && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/selfsigned/privkey.pem \
    -out /etc/nginx/selfsigned/fullchain.pem \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=community-cLOUD/CN=localhost"
