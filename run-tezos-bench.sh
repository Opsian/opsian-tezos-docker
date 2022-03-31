#!/bin/sh

set -x

export OPS_KEY=$1
export DATA_DIR=$2
export CONT=$3

if [ -z "$OPSIAN_OPTS" ]
then
  docker run -it \
    --cap-add=SYS_PTRACE \
    -v "$DATA_DIR":/data \
    -e OPS_KEY="$OPS_KEY" \
    "$CONT"
else
  docker run -it \
    --cap-add=SYS_PTRACE \
    -p 9100:9100 \
    -v "$DATA_DIR":/data \
    -e OPSIAN_OPTS="$OPSIAN_OPTS" \
    "$CONT"
fi

