#!/bin/sh
SSH_DIR="/home/opencode/.ssh"
for keytype in rsa ecdsa ed25519; do
  keyfile="$SSH_DIR/ssh_host_${keytype}_key"
  if [ ! -f "$keyfile" ]; then
    ssh-keygen -t "$keytype" -f "$keyfile" -N "" -q
  fi
  sudo cp "$keyfile" "/etc/ssh/ssh_host_${keytype}_key"
  sudo cp "${keyfile}.pub" "/etc/ssh/ssh_host_${keytype}_key.pub"
done
sudo /usr/sbin/sshd
exec opencode "$@"
