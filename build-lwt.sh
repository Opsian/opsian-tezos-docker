#!/bin/sh

set -eu

docker build --build-arg LWT=ON . -t opsian-tezos-lwt
