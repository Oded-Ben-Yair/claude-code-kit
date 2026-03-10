# Frontend Dockerfile Templates

## TEMPLATE C: Next.js Frontend (Static Export + nginx)

```dockerfile
# <PROJECT> - Frontend (Next.js Static Export)
# Two-stage build: node builds, nginx serves

# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# API URL baked in at BUILD TIME (Next.js replaces at compile)
ARG NEXT_PUBLIC_API_URL=https://<backend-domain>
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

RUN npm run build
# Produces /app/out (static export) or /app/.next (SSR)

# Stage 2: Serve with nginx
FROM nginx:alpine AS production
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/out /usr/share/nginx/html

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

**IMPORTANT**: `NEXT_PUBLIC_*` vars are baked in at BUILD TIME, not runtime.
To change the API URL, you must REBUILD the image.

## TEMPLATE D: Vite/React Frontend (+ nginx with API proxy)

```dockerfile
# <PROJECT> - Frontend (Vite/React)
# Two-stage build: node builds, nginx serves + proxies API

# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .

# VITE_ vars are baked in at BUILD TIME
ARG VITE_API_URL=/api
ENV VITE_API_URL=${VITE_API_URL}

RUN npm run build
# Produces /app/dist (Vite output)

# Stage 2: Serve with nginx
FROM nginx:alpine AS production

# Install curl for healthcheck (nginx:alpine has wget via busybox, but curl is more reliable)
RUN apk add --no-cache curl

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Custom nginx config with API proxy
COPY <<'NGINX_CONF' /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/json application/xml;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # API proxy to backend (same Docker network)
    location /api/ {
        proxy_pass http://backend:<BACKEND_PORT>/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # SPA routing — serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 '{"status":"healthy"}';
        add_header Content-Type application/json;
    }
}
NGINX_CONF

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

**Key differences from Next.js template**:
- Build output is `dist/` not `out/`
- Env var prefix is `VITE_` not `NEXT_PUBLIC_`
- Default API URL is `/api` (relative, proxied through nginx) not full domain
- nginx includes API proxy block (no CORS needed)
- Uses port 80 (standard)
- Includes `X-Frame-Options: SAMEORIGIN` (not DENY) — some apps use iframes

## TEMPLATE E: nginx.conf (for Next.js cross-origin frontend)

Only needed when frontend calls backend on a SEPARATE domain (not proxied).

```nginx
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer"';
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;

    server {
        listen 3000;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;

        # Security headers
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            try_files $uri =404;
        }

        location / {
            try_files $uri $uri/ $uri/index.html /index.html;
        }

        location /health {
            access_log off;
            return 200 '{"status":"healthy"}';
            add_header Content-Type application/json;
        }

        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
}
```
