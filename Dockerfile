FROM alpine:edge AS build

ARG OPENSSL_VERSION=1.1.1s
ARG OPENSSL_URL="https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
ARG LIBEVENT_VERSION=2.1.12-stable
ARG LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz"
ARG ZLIB_VERSION=1.3.1
ARG ZLIB_URL="https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz"
ARG XZ_VERSION=5.2.13
ARG XZ_URL="https://tukaani.org/xz/xz-${XZ_VERSION}.tar.gz"
ARG TOR_VERSION=0.4.8.13
ARG TOR_URL="https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz"

ENV BUILD_DIR=/build
RUN mkdir -p "${BUILD_DIR}"
WORKDIR ${BUILD_DIR}

RUN apk --no-cache add \
        bash \
        curl \
        build-base \
        linux-headers \
        ca-certificates \
        perl

RUN set -eux; \
    \
    curl -LO "${OPENSSL_URL}"; \
    curl -LO "${LIBEVENT_URL}"; \
    curl -LO "${ZLIB_URL}"; \
    curl -LO "${XZ_URL}"; \
    curl -LO "${TOR_URL}"; \
    \
    tar xzf openssl-${OPENSSL_VERSION}.tar.gz; \
    tar xzf libevent-${LIBEVENT_VERSION}.tar.gz; \
    tar xzf zlib-${ZLIB_VERSION}.tar.gz; \
    tar xzf xz-${XZ_VERSION}.tar.gz; \
    tar xzf tor-${TOR_VERSION}.tar.gz; \
    \
    mv openssl-${OPENSSL_VERSION} ${BUILD_DIR}/openssl; \
    mv libevent-${LIBEVENT_VERSION} ${BUILD_DIR}/libevent; \
    mv zlib-${ZLIB_VERSION} ${BUILD_DIR}/zlib; \
    mv xz-${XZ_VERSION} ${BUILD_DIR}/xz; \
    mv tor-${TOR_VERSION} ${BUILD_DIR}/tor;

RUN set -eux; \
    \
    cd ${BUILD_DIR}/openssl; \
    ./config \
      --prefix=${BUILD_DIR}/openssl/dist \
      --openssldir=${BUILD_DIR}/openssl/dist \
      no-shared \
      no-dso \
      no-zlib; \
    make depend; \
    make -j4; \
    make install

RUN set -eux; \
    \
    cd ${BUILD_DIR}/libevent; \
    ./configure \
      --prefix=${BUILD_DIR}/libevent/dist \
      --disable-shared \
      --enable-static \
      --with-pic \
      --disable-samples \
      --disable-libevent-regress \
      CPPFLAGS=-I${BUILD_DIR}/openssl/dist/include \
      LDFLAGS=-L${BUILD_DIR}/openssl/dist/lib; \
    make -j4; \
    make install

RUN set -eux; \
    \
    cd ${BUILD_DIR}/zlib; \
    ./configure \
      --prefix=${BUILD_DIR}/zlib/dist; \
    make -j4; \
    make install

RUN set -eux; \
    \
    cd ${BUILD_DIR}/xz; \
    ./configure \
      --prefix=${BUILD_DIR}/xz/dist \
      --disable-shared \
      --enable-static \
      --disable-doc \
      --disable-scripts \
      --disable-xz \
      --disable-xzdec \
      --disable-lzmadec \
      --disable-lzmainfo \
      --disable-lzma-links; \
    make -j4; \
    make install

RUN set -eux; \
    \
    cd ${BUILD_DIR}/tor; \
    ./configure \
      --prefix=${BUILD_DIR}/tor/dist \
      --disable-gcc-hardening \
      --enable-static-libevent \
      --with-libevent-dir=${BUILD_DIR}/libevent/dist \
      --enable-static-openssl \
      --with-openssl-dir=${BUILD_DIR}/openssl/dist \
      --enable-static-zlib \
      --with-zlib-dir=${BUILD_DIR}/zlib/dist \
      --disable-systemd \
      --disable-lzma \
      --disable-seccomp \
      --enable-static-tor; \
    make -j4; \
    make install; \
    scanelf -R --nobanner -F '%F' ${BUILD_DIR}/tor/dist/bin/ | xargs strip

FROM scratch

LABEL maintainer="Boeboe <boeboe@github.com>" \
    org.label-schema.vcs-url="https://github.com/boeboe/tor-scratch.git"

ENV BUILD_DIR=/build

COPY --from=build ${BUILD_DIR}/tor/dist/bin/tor /usr/bin/tor

CMD ["tor"]
