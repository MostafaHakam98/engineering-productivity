ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bash git python3 nodejs shellcheck jq bc ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY . /kit
ENV HOME=/tmp/test-user PYTHONDONTWRITEBYTECODE=1
USER 65534:65534
WORKDIR /kit
CMD ["bash", "/kit/scripts/verify.sh"]
