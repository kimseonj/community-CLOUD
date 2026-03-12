# App Nginx Image

## Build

```bash
cd /Users/kimsj/kakao-tech/community/community-CLOUD/V1/docker/app/nginx
docker build -t community-nginx:latest .
```

## Run example

```bash
docker run -d --name community-nginx \
  -p 80:80 \
  -p 443:443 \
  -e BACKEND_HOST=backend \
  -e BACKEND_PORT=8080 \
  -e FRONTEND_HOST=frontend \
  -e FRONTEND_PORT=3000 \
  -e TLS_SERVER_NAME=localhost \
  -e ACME_WEBROOT=/var/www/certbot \
  -e TLS_CERT_PATH=/etc/nginx/selfsigned/fullchain.pem \
  -e TLS_KEY_PATH=/etc/nginx/selfsigned/privkey.pem \
  community-nginx:latest
```

- `/api/*` -> backend container
- `/` -> frontend container
