#!/bin/sh

set -eu

docker build --build-arg ASAN=ON --build-arg METRICS=ON . -t opsian-tezos-metrics
