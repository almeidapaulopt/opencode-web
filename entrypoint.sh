#!/bin/sh

if [ -f /run/secrets/opencode_password ]; then
  export OPENCODE_SERVER_PASSWORD="$(cat /run/secrets/opencode_password)"
fi

SSH_DIR="/home/opencode/.ssh"
for keytype in rsa ecdsa ed25519; do
  keyfile="$SSH_DIR/ssh_host_${keytype}_key"
  if [ ! -f "$keyfile" ]; then
    ssh-keygen -t "$keytype" -f "$keyfile" -N "" -q
  fi
  sudo cp "$keyfile" "/etc/ssh/ssh_host_${keytype}_key"
  sudo cp "${keyfile}.pub" "/etc/ssh/ssh_host_${keytype}_key.pub"
done

if [ -n "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

sudo /usr/sbin/sshd

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

exec opencode "$@"
