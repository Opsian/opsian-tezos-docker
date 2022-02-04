#!/bin/sh

set -x

sysctl -w kernel.core_pattern="/data/cores/core.%e.%p"
export DATE=""
DATE=$(date +'%d')
export SNAPSHOT_BLOCK=""
export OPSIAN_OPTS="apiKey=$OPS_KEY,applicationVersion=1,debugLogPath=/data/£{ARGV_0}-£{PID}-debug.log,agentId=£{ARGV_0}-snapshot"
export OCAMLRUNPARAM='v=0x400'

if [ -f /data/block ]
then
  SNAPSHOT_BLOCK=$(cat /data/block)
fi

rm -rf /data/tezos-node-mainnet
./tezos-node config init --data-dir /data/tezos-node-mainnet --network mainnet
time ./tezos-node snapshot --data-dir /data/tezos-node-mainnet import --block "$SNAPSHOT_BLOCK" /data/snapshot
