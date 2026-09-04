#!/bin/bash

REPOSITORY_OWNER=$REPOSITORY_OWNER
REG_TOKEN=$REG_TOKEN

cd /home/runner/actions-runner || exit
./config.sh --url https://github.com/${REPOSITORY_OWNER} --token ${REG_TOKEN}

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
