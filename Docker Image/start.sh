#!/bin/bash

REPO=$REPO
REG_TOKEN=$REG_TOKEN
NAME=$NAME
CLOUD_IP=$CLOUD_IP
CLOUD_USER=$CLOUD_USER
CLUSTER_PORT=$CLUSTER_PORT

cd /home/runner/actions-runner || exit

# sudo service docker start

mkdir -p ~/.ssh/
ssh-keyscan -H ${CLOUD_IP}  >> ~/.ssh/known_hosts
autossh -fnNT -L ${CLUSTER_PORT}:localhost:${CLUSTER_PORT} ubuntu@${CLOUD_IP} -i ~/ssh-key

./config.sh --url https://github.com/${REPO} --token ${REG_TOKEN} --name ${NAME}

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!

