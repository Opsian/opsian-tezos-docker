FROM ubuntu:20.04
ARG METRICS
ARG ASAN
ARG LWT
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"
RUN apt update && apt install -y opam curl ubuntu-dbgsym-keyring lsb-release
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list
RUN apt update && apt install -y libev4-dbgsym
WORKDIR /
RUN opam init --disable-sandboxing -a --yes --bare && opam switch create 4.12.1 --empty
RUN opam install -y dune
RUN apt install -y git pkg-config libgmp-dev libgmp10 libhidapi-dev libhidapi-hidraw0 libhidapi-libusb0 libffi-dev libffi7 zlib1g-dev zlib1g autoconf patch libev-dev
RUN apt install -y wget
RUN wget https://sh.rustup.rs/rustup-init.sh
RUN chmod +x ./rustup-init.sh 
RUN ./rustup-init.sh --profile minimal --default-toolchain 1.44.0 -y
RUN wget https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh
RUN chmod +x fetch-params.sh
RUN ./fetch-params.sh
RUN git clone https://gitlab.com/tezos/tezos
WORKDIR tezos
COPY ./tezos.patch .
COPY ./metrics.patch .
ENV PATH="/root/.cargo/bin:${PATH}"
RUN if [ "$METRICS" = "ON" ]; \
      then git apply ./metrics.patch; \
    fi #
RUN make build-deps
RUN git apply ./tezos.patch
WORKDIR /
# make git happy
RUN mkdir ~/.ssh
RUN touch ~/.ssh
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
RUN apt install -y autoconf libc6-dev libpthread-stubs0-dev libtool liblzma-dev
# removed --depth 1 for lwt
RUN git clone --shallow-submodules --recurse-submodules https://github.com/Opsian/opsian-ocaml # Nope 8
RUN if [ "$ASAN" = "ON" ]; \
      then git apply ./enable-asan.patch; \
           export ASAN_OPTIONS='handle_segv=0,log_path=/data/asan.log,detect_stack_use_after_return=1,detect_invalid_pointer_pairs=1,strict_string_checks=1,check_initialization_order=1,strict_init_order=1'; \
    fi
# Don't currently support asan + lwt
RUN if [ "$LWT" = "ON" ]; \
      then cd /opsian-ocaml; \
           git checkout lwt-sampling-experiment; \
           cd /tezos; \
           opam pin -y --debug -vv add lwt https://github.com/RichardWarburton/lwt.git#sampling-experiment; \
           opam pin -y --debug -vv add opsian git+file:///opsian-ocaml#lwt-sampling-experiment  ; \
      else cd /tezos; \
           opam pin -y --debug -vv add opsian git+file:///opsian-ocaml#main; \
    fi
WORKDIR /tezos
RUN eval $(opam env) && opam install -y --debug -vv opsian
RUN opam reinstall -y --debug -vv lwt 
RUN eval $(opam env) && opam exec -- make
RUN apt install -y time
COPY ./bench.sh ./bench.sh
COPY ./bench-one.sh ./bench-one.sh
CMD ./bench.sh
