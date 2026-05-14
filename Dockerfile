FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gpg \
    git \
    openssh-server \
    sudo \
  && rm -rf /var/lib/apt/lists/* \
  && userdel -r ubuntu 2>/dev/null || true \
  && adduser --disabled-password --gecos "" --uid 1000 opencode \
  && mkdir -p /home/opencode/.local/state \
  && mkdir -p /home/opencode/.config/opencode \
  && mkdir -p /home/opencode/.local/share/opencode \
  && mkdir -p /home/opencode/.ssh \
  && mkdir -p /home/opencode/workspace \
  && mkdir -p /run/sshd \
  && echo 'opencode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/opencode \
  && echo 'eval "$(mise activate bash)"' >> /home/opencode/.bashrc \
  && echo 'eval "$(mise activate bash)"' >> /home/opencode/.profile \
  && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
  && echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config \
  && passwd -d opencode \
  && chown -R opencode:opencode /home/opencode

ARG OPENCODE_VERSION=latest
RUN ARCH=$(dpkg --print-architecture) \
  && if [ "$ARCH" = "arm64" ]; then SUFFIX="arm64"; else SUFFIX="x64"; fi \
  && if [ "$OPENCODE_VERSION" = "latest" ]; then \
       URL="https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-${SUFFIX}.tar.gz"; \
     else \
       URL="https://github.com/anomalyco/opencode/releases/download/${OPENCODE_VERSION}/opencode-linux-${SUFFIX}.tar.gz"; \
     fi \
  && curl -fsSL "$URL" | tar -xz -C /usr/local/bin opencode \
  && chmod +x /usr/local/bin/opencode

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://mise.run | bash \
  && cp /root/.local/bin/mise /usr/local/bin/mise \
  && echo 'eval "$(mise activate bash)"' >> /home/opencode/.bashrc \
  && echo 'eval "$(mise activate bash)"' >> /home/opencode/.profile

RUN mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list \
  && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER opencode
WORKDIR /home/opencode/workspace

ENTRYPOINT ["/entrypoint.sh"]
