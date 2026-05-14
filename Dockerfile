FROM ghcr.io/anomalyco/opencode:latest

RUN adduser -D -u 1000 opencode \
 && mkdir -p /home/opencode/.local/state \
 && mkdir -p /home/opencode/.config/opencode \
 && mkdir -p /home/opencode/.local/share/opencode \
 && mkdir -p /home/opencode/workspace \
 && apk add --no-cache mise \
 && echo 'eval "$(mise activate bash)"' >> /home/opencode/.bashrc \
 && chown -R opencode:opencode /home/opencode

USER opencode
WORKDIR /home/opencode/workspace

ENTRYPOINT ["opencode"]
