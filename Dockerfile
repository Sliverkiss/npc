FROM python:3.13.12-alpine AS python-builder
RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel

FROM node:22.22-alpine AS node-builder

FROM alpine:3.22

COPY --from=python-builder /usr/local /usr/local

COPY --from=node-builder /usr/local /usr/local

RUN apk add --no-cache \
        bash \
        dcron \
        tzdata \
        libstdc++ \
        ca-certificates \
        libffi \
        openssl \
        readline \
        zlib \
        expat \
        bzip2 \
        sqlite-libs \
        git \
        wget \
        curl \
    && ln -sf /usr/local/bin/python3 /usr/local/bin/python \
    && ln -sf /usr/local/bin/pip3 /usr/local/bin/pip \
    && rm -rf /var/cache/apk/*

WORKDIR /app

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
