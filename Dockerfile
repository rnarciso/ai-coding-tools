# Use the official Node.js 20 slim image as a base
FROM node:20-slim

# -------------------------------
# 1. System Dependencies Installation
# -------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    nano \
    wget \
    gnupg \
    sudo \
    && ( \
        wget -qO - https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
        && apt-get update \
    ) \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# 2. NPM-based CLI Tools Installation
# -------------------------------
RUN mkdir -p /opt/cli-tools \
    && npm config -g set prefix /opt/cli-tools \
    && npm install -g \
        @anthropic-ai/claude-code \
        @musistudio/claude-code-router@latest \
        @qwen-code/qwen-code@latest \
        @google/gemini-cli@latest

# -------------------------------
# 3. User Setup
# -------------------------------
RUN groupadd -g 1001 coder \
    && useradd -u 1001 -g 1001 -ms /bin/bash coder \
    && chown -R coder:coder /opt/cli-tools \
    \
    # Allow 'coder' to use sudo without password
    && echo 'coder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && groupadd -g 990 docker \
    && usermod -aG docker coder

# -------------------------------
# 4. Entrypoint Configuration
# -------------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# -------------------------------
# 5. Final Environment Setup
# -------------------------------
ENV PATH="/opt/cli-tools/bin:${PATH}"

USER coder
WORKDIR /projects
ENTRYPOINT ["entrypoint.sh"]
