FROM node:20-slim

RUN userdel -r node || true

# 1. Install System Dependencies & Docker Tools
# We use 'slim' base, so we need to ensure we have curl/gnupg/git/gosu
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    ca-certificates \
    curl \
    gnupg \
    gosu \
    procps \
    jq \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Docker CLI (No Engine)
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# 4. Setup
WORKDIR /workspace

# 5. Git Safety (Fix "Dubious Ownership" for mounted volumes)
RUN git config --system --add safe.directory '*'

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]