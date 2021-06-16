FROM ubuntu:20.04
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"
RUN apt-get update && apt-get install -y opam curl wget cmake libunwind-dev libdw-dev ubuntu-dbgsym-keyring lsb-release
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN apt-get update && apt-get install -y libev4-dbgsym
# Do westprof
WORKDIR /
COPY ./westprof ./westprof
WORKDIR westprof/third_party
RUN ./download_and_build.sh
WORKDIR /
RUN opam init --disable-sandboxing -a --yes --bare && opam switch create 4.12.0
RUN opam install dune
RUN apt-get update && apt-get install -y git pkg-config libgmp-dev libgmp10 libhidapi-dev libhidapi-hidraw0 libhidapi-libusb0 libffi-dev libffi7 zlib1g-dev zlib1g autoconf patch
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
COPY ./opsian-ocaml/ ./opsian-ocaml
ENV THIRD_PARTY=/westprof/third_party
WORKDIR /opsian-ocaml/protobuf
RUN ./generate
RUN ln -s /opsian-ocaml/lib /tezos/src/lib_opsian
WORKDIR /westprof/third_party
RUN cp ./protobuf/lib/libprotobuf.a ./protobuf/lib/libprotobuf-lite.a ./protobuf/lib/libprotoc.a ./boost/lib/libboost_thread.a ./boost/lib/libboost_timer.a ./boost/lib/libboost_chrono.a ./boost/lib/libboost_serialization.a ./boost/lib/libboost_system.a ./boost/lib/libboost_date_time.a ./boost/lib/libboost_wserialization.a ./boost/lib/libboost_regex.a ./openssl/lib/libcrypto.a ./openssl/lib/libssl.a ./junction/lib/libjunction.a ./junction/lib/libturf.a /tezos/src/lib_opsian/deps/
WORKDIR /tezos
RUN opam exec -- make
CMD ./tezos-node run
