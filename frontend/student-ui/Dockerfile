# syntax=docker/dockerfile:1

# Stage 1: build static assets (Node toolchain stays out of final image)
FROM node:22-alpine AS builder

WORKDIR /app

ENV npm_config_update_notifier=false

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

COPY index.html vite.config.ts tsconfig.json tsconfig.app.json tsconfig.node.json ./
COPY postcss.config.js tailwind.config.js ./
COPY public ./public
COPY src ./src

ENV NODE_ENV=production
RUN npm run build \
    && rm -rf node_modules

# Stage 2: serve static files with minimal nginx
FROM nginx:1.27-alpine AS runtime

RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
