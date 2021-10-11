#!/bin/sh

set -eu

export DATE="-1"
export SNAPSHOT_BLOCK=""
export OPSIAN_OPTS="apiKey=$OPS_KEY,applicationVersion=1,debugLogPath=/data/£{ARGV_0}-£{PID}-debug.log,agentId=£{ARGV_0}-snapshot"

while true
do
  echo "Benchmark run @ $(date)"

  # Download a new snapshot once per day
  NEW_DATE=$(date +'%d')
  if [ "$DATE" -ne "$NEW_DATE" ]
  then
    SNAPSHOT_LINE=$(curl -s https://snapshots-tezos.giganode.io | grep 'href="https://snapshots-tezos.giganode.io/snapshots/mainnet' | head -n 1)
    SNAPSHOT_URL=$(echo "$SNAPSHOT_LINE" | sed 's/.*href="//;s/".*//')
    SNAPSHOT_BLOCK=$(echo "$SNAPSHOT_LINE" | sed 's/.*_//;s/\.rolling.*//')

    rm -f /data/snapshot
    wget "$SNAPSHOT_URL" -O /data/snapshot || true
  fi
  DATE=$NEW_DATE


  rm -rf /data/tezos-node-mainnet
  ./tezos-node config init --data-dir /data/tezos-node-mainnet --network mainnet
  time ./tezos-node snapshot --data-dir /data/tezos-node-mainnet import --block "$SNAPSHOT_BLOCK" /data/snapshot

done

