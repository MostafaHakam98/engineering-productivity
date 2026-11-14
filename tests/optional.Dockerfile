FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends git python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY . /kit
ENV HOME=/tmp/optional-home PYTHONDONTWRITEBYTECODE=1
USER node
WORKDIR /kit
CMD ["bash", "/kit/tests/optional-integrations.sh"]
