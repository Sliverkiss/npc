FROM debian:bookworm-slim

ARG CODE_SERVER_VERSION=4.109.2
ARG TARGETARCH

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        cron \
        tzdata \
        ca-certificates \
        git \
        wget \
        python3 \
        python3-pip; \
    CODE_SERVER_ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "${CODE_SERVER_ARCH}" in \
        amd64|arm64) ;; \
        *) echo "Unsupported architecture: ${CODE_SERVER_ARCH}" >&2; exit 1 ;; \
    esac; \
    CODE_SERVER_TARBALL="code-server-${CODE_SERVER_VERSION}-linux-${CODE_SERVER_ARCH}.tar.gz"; \
    wget -O "/tmp/${CODE_SERVER_TARBALL}" "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/${CODE_SERVER_TARBALL}"; \
    tar -xzf "/tmp/${CODE_SERVER_TARBALL}" -C /usr/lib; \
    mv "/usr/lib/code-server-${CODE_SERVER_VERSION}-linux-${CODE_SERVER_ARCH}" /usr/lib/code-server; \
    ln -sf /usr/lib/code-server/bin/code-server /usr/local/bin/code-server; \
    ln -sf /usr/lib/code-server/lib/node /usr/local/bin/node; \
    ln -sf /usr/bin/python3 /usr/local/bin/python; \
    ln -sf /usr/bin/pip3 /usr/local/bin/pip; \
    rm -f "/tmp/${CODE_SERVER_TARBALL}"; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app/ /opt/app-template/

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
