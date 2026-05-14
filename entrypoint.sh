#!/bin/sh
sudo /usr/sbin/sshd
exec opencode "$@"
