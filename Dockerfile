FROM ghcr.io/anomalyco/opencode:latest

RUN apk add --no-cache bash git mise docker-cli openssh sudo \
 && adduser -D -u 1000 opencode \
 && mkdir -p /home/opencode/.local/state \
 && mkdir -p /home/opencode/.config/opencode \
 && mkdir -p /home/opencode/.local/share/opencode \
 && mkdir -p /home/opencode/.ssh \
 && mkdir -p /home/opencode/workspace \
 && mkdir -p /run/sshd \
 && ssh-keygen -A \
 && echo 'opencode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/opencode \
 && echo 'eval "$(mise activate bash)"' >> /home/opencode/.bashrc \
 && echo 'eval "$(mise activate bash)"' >> /home/opencode/.profile \
 && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
 && echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config \
 && passwd -u opencode \
  && chown -R opencode:opencode /home/opencode \
  && sed -i 's|/home/opencode:.*/bin/sh|/home/opencode:/bin/bash|' /etc/passwd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER opencode
WORKDIR /home/opencode/workspace

ENTRYPOINT ["/entrypoint.sh"]
