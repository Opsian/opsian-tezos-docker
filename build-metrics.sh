#!/bin/sh

set -eu

docker build --build-arg METRICS=ON . -t opsian-tezos-metrics
