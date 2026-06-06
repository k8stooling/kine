FROM debian:testing-slim

MAINTAINER krisek11

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Budapest

WORKDIR /

# -------- Architecture mapping --------
RUN case "${TARGETARCH}" in \
      amd64)  export ARCH=amd64  ;; \
      arm64)  export ARCH=arm64  ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    echo "ARCH=${ARCH}" > /arch.env

ARG TARGETARCH
ARG KINE_VERSION

RUN set -eux; \
    cd /tmp; \
    case "${TARGETARCH}" in \
      amd64) ARCH=amd64 ;; \
      arm64) ARCH=arm64 ;; \
      *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    if [ -n "${KINE_VERSION:-}" ]; then \
      KINE_VER="${KINE_VERSION#v}"; \
    else \
      KINE_VER="$(curl -fsSL https://api.github.com/repos/k3s-io/kine/releases/latest | jq -r '.tag_name' | sed 's/^v//')"; \
    fi; \
    curl -fsSL -o kine \
      "https://github.com/k3s-io/kine/releases/download/v${KINE_VER}/kine-${ARCH}"; \
    install -m 0755 kine /usr/bin/kine; \
    rm -rf kine

# -------- User --------
RUN groupadd -g 1000 kine && \
    useradd -u 1000 -g 1000 -ms /bin/bash kine

RUN mkdir /kine; chown kine:kine /kine

WORKDIR /kine

USER kine

CMD ["kine"]
