#!/bin/sh

set -eu

export DATE="$(date +'%d')"
export OPSIAN_OPTS="apiKey=$OPS_KEY,applicationVersion=1,debugLogPath=/data/£{ARGV_0}-£{PID}-debug.log,agentId=£{ARGV_0}-snapshot"

while true
do
  echo "Benchmark run @ $(date)"

  # Download a new snapshot once per day
  NEW_DATE=$(date +'%d')
  if [ "$DATE" -ne "$NEW_DATE" ]
    then rm -f /data/snapshot
  fi
  DATE=$NEW_DATE

  SNAPSHOT_URL=$(curl -s https://snapshots-tezos.giganode.io | grep 'href="https://snapshots-tezos.giganode.io/snapshot-mainnet' | head -n 1 | sed 's/.*href="//;s/".*//')
  wget -nc "$SNAPSHOT_URL"  -O /data/snapshot || true

  rm -rf /data/tezos-node-mainnet
  ./tezos-node config init --data-dir /data/tezos-node-mainnet --network mainnet
  time ./tezos-node snapshot --data-dir /data/tezos-node-mainnet import --block BLzFs2hjX8YuoWkFL2VqLT4vHH2N3CruHcZ7gZG4ejbp2zCVPbE /data/snapshot

done

