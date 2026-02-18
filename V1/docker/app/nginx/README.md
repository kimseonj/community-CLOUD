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
  -e BACKEND_HOST=backend \
  -e BACKEND_PORT=8080 \
  -e FRONTEND_HOST=frontend \
  -e FRONTEND_PORT=3000 \
  community-nginx:latest
```

- `/api/*` -> backend container
- `/` -> frontend container
