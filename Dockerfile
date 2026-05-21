FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gpg \
    git \
    openssh-server \
    sudo \
    bash-completion \
    tmux \
    socat \
    unzip \
    build-essential \
  && rm -rf /var/lib/apt/lists/* \
  && userdel -r ubuntu 2>/dev/null || true \
  && adduser --disabled-password --gecos "" --uid 1000 opencode \
  && mkdir -p /home/opencode/.local/state \
  && mkdir -p /home/opencode/.local/share/mise \
  && mkdir -p /home/opencode/.config/opencode \
  && mkdir -p /home/opencode/.local/share/opencode \
  && mkdir -p /home/opencode/.ssh \
  && mkdir -p /home/opencode/workspace \
  && mkdir -p /run/sshd \
  && echo 'opencode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/opencode \
  && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
  && echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config \
  && passwd -d opencode

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
  && cp /root/.local/bin/mise /usr/local/bin/mise

RUN mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin gh \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY configs/.bashrc /home/opencode/.bashrc
COPY configs/.profile /home/opencode/.profile
COPY configs/.inputrc /home/opencode/.inputrc
COPY configs/.gitconfig /home/opencode/.gitconfig
COPY configs/.config/ /home/opencode/.config/

RUN chown -R opencode:opencode /home/opencode

USER opencode
WORKDIR /home/opencode/workspace

RUN mise install

ENTRYPOINT ["/entrypoint.sh"]
