You will need to clone https://github.com/Opsian/opsian-ocaml and https://gitlab.com/westprof/westprof.git into this directory (as opsian-ocaml and westprof respectively).

Then "docker build . -t opsian-tezos" should give you a working Tezos build with Opsian integrated.

Afterwards you can do "docker run -e OPSIAN_OPTS=... opsian-tezos" to bring up a node with profiling.
