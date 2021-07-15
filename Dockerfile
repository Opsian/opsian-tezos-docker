FROM ubuntu:20.04
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"
RUN apt update && apt install -y opam curl ubuntu-dbgsym-keyring lsb-release
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN apt update && apt install -y libev4-dbgsym
WORKDIR /
RUN opam init --disable-sandboxing -a --yes --bare && opam switch create 4.12.0
RUN opam install dune
RUN apt install -y git pkg-config libgmp-dev libgmp10 libhidapi-dev libhidapi-hidraw0 libhidapi-libusb0 libffi-dev libffi7 zlib1g-dev zlib1g autoconf patch
RUN apt install -y wget
RUN wget https://sh.rustup.rs/rustup-init.sh
RUN chmod +x ./rustup-init.sh 
RUN ./rustup-init.sh --profile minimal --default-toolchain 1.44.0 -y
RUN wget https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh
RUN chmod +x fetch-params.sh
RUN ./fetch-params.sh
RUN git clone https://gitlab.com/tezos/tezos
WORKDIR tezos
RUN git fetch origin merge-requests/2671/head:tezos-4.12 && git checkout tezos-4.12
COPY ./tezos.patch .
ENV PATH="/root/.cargo/bin:/westprof/third_party/protobuf/bin:${PATH}"
RUN make build-deps
RUN opam exec -- make
RUN git apply ./tezos.patch
WORKDIR /
# make git happy
RUN mkdir ~/.ssh
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
COPY ./opsian-ocaml/ ./opsian-ocaml
RUN apt install -y autoconf libc6-dev libpthread-stubs0-dev libtool
WORKDIR /opsian-ocaml
RUN opam install -y .
WORKDIR /tezos
RUN opam exec -- make
CMD ./tezos-node run
