#!/bin/bash -x

set -e

source configs/env-config.sh

SSH_ARGS="-o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o User=${SEED_SSH_USER} -o ConnectTimeout=10"

export HEIMDALL_GIT_URL=${HEIMDALL_GIT_URL:-"https://github.com/andreyshestakov/heimdall"}
export HEIMDALL_GIT_BRANCH=${HEIMDALL_GIT_BRANCH:-"master"}

# Clone heimdall
rm -rf heimdall
git clone -b ${HEIMDALL_GIT_BRANCH} ${HEIMDALL_GIT_URL} heimdall

# Verify SSH access
ssh ${SSH_ARGS} ${SEED_SSH_ADDRESS} true

# Copy heimdall to target
rsync -aHS --delete -e "ssh ${SSH_ARGS}" ./heimdall/ ${SEED_SSH_ADDRESS}:heimdall/

# Copy heimdall configs to target
rsync -aHS --delete -e "ssh ${SSH_ARGS}" ./configs/ ${SEED_SSH_ADDRESS}:heimdall/configs/

# Run heimdall
ssh ${SSH_ARGS} ${SEED_SSH_ADDRESS} bash ./heimdall/install.sh
