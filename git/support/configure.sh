#!/usr/bin/env bash

test -z "$GIT_USER" && { echo "Must supply GIT_USER" >&2; exit 1; }
test -z "$GIT_EMAIL" && { echo "Must supply GIT_EMAIL" >&2; exit 1; }

git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global push.default simple

if [ -n "$GIT_PRIVATE_KEY" ]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  echo "$GIT_PRIVATE_KEY" > ~/.ssh/id_rsa
  chmod 400 ~/.ssh/id_rsa
fi

sed -i -e '$a\Host *' /etc/ssh/ssh_config
sed -i -e "\$a\    StrictHostKeyChecking ${STRICT_HOST_KEY_CHECKING:-no}" /etc/ssh/ssh_config
