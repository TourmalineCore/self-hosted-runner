#!/bin/bash

REPOSITORY_OWNER=$REPOSITORY_OWNER
REG_TOKEN=$REG_TOKEN
INNER_CIRCLE_CLOUD_VM_IP=$INNER_CIRCLE_CLOUD_VM_IP
INNER_CIRCLE_CLOUD_VM_USER=$INNER_CIRCLE_CLOUD_USER
INNER_CIRCLE_CLOUD_CLUSTER_PORT=$INNER_CIRCLE_CLOUD_CLUSTER_PORT
INNER_CIRCLE_CLOUD_VM_PASSWORD=$INNER_CIRCLE_CLOUD_VM_PASSWORD
INNER_CIRCLE_CLOUD_PATH_TO_SSH=$INNER_CIRCLE_CLOUD_PATH_TO_SSH
cd /home/runner/actions-runner || exit

# sudo service docker start

mkdir -p ~/.ssh/
ssh-keyscan -H ${INNER_CIRCLE_CLOUD_VM_IP} >> ~/.ssh/known_hosts

eval `ssh-agent -s`
expect << EOF
spawn ssh-add $INNER_CIRCLE_CLOUD_PATH_TO_SSH
expect "Enter passphrase for $INNER_CIRCLE_CLOUD_PATH_TO_SSH:"
send "$INNER_CIRCLE_CLOUD_VM_PASSWORD\n";
expect "Identity added: $INNER_CIRCLE_CLOUD_PATH_TO_SSH *"
interact
EOF

autossh -fnNT -L ${INNER_CIRCLE_CLOUD_CLUSTER_PORT}:localhost:${INNER_CIRCLE_CLOUD_CLUSTER_PORT} ubuntu@${INNER_CIRCLE_CLOUD_VM_IP} -i ${INNER_CIRCLE_CLOUD_PATH_TO_SSH}

./config.sh --url https://github.com/${REPOSITORY_OWNER} --token ${REG_TOKEN} 

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!

