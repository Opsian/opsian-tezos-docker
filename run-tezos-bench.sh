#!/bin/sh

set -eux

export OPS_KEY=$1
export DATA_DIR=$2
export CONT=$3

docker run -it \
  --cap-add=SYS_PTRACE \
  -v "$DATA_DIR":/data \
  -e OPS_KEY="$OPS_KEY" \
  --add-host snapshots-tezos.giganode.io:20.79.209.6 "$CONT"

