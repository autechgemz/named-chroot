FROM alpine:latest AS baseimage

ARG NAMED_VERSION
ARG NAMED_ROOT=/chroot
ARG NAMED_CONFDIR=/etc/named
ARG NAMED_DATADIR=/var/named
ARG NAMED_USER=named

ENV PATH="${NAMED_ROOT}/sbin:${NAMED_ROOT}/bin:${PATH}"

RUN apk update \
 && apk upgrade --update --available \
 && apk add --no-cache \
    xz \
    build-base \
    linux-headers \
    automake \
    autoconf \
    libtool \
    tar \
    curl \
    tzdata \
    tini \
    openssl-dev \
    expat-dev \
    libxml2-dev \
    py3-ply \
    libgcc \
    libuv-dev \
    libcap-dev \
    nghttp2-dev \
    jemalloc-dev \
 && addgroup -S named \
 && adduser -S -D -H -h $NAMED_DATADIR -s /sbin/nologin -G $NAMED_USER $NAMED_USER \
 && mkdir -m 755 -p $NAMED_ROOT \
 && curl https://ftp.isc.org/isc/bind9/${NAMED_VERSION}/bind-${NAMED_VERSION}.tar.xz -o $NAMED_ROOT/bind-${NAMED_VERSION}.tar.xz \
 && cd ${NAMED_ROOT} \
 && tar Jxvf bind-${NAMED_VERSION}.tar.xz \
 && cd ${NAMED_ROOT}/bind-${NAMED_VERSION} \
 && ./configure \
    --prefix=${NAMED_ROOT} \
    --sysconfdir=${NAMED_ROOT}${NAMED_CONFDIR} \
    --with-openssl=/usr \
    --with-libxml2 \
    --enable-shared \
    --disable-static \
    --with-jemalloc \
    CC=gcc \
    CFLAGS='-Os -fomit-frame-pointer -g -D_GNU_SOURCE' \
    CPPFLAGS='-Os -fomit-frame-pointer' \
 && make \
 && make install \
 && cd / \
 && rm -rf ${NAMED_ROOT}/include \
 && rm -rf ${NAMED_ROOT}/share \
 && rm -rf ${NAMED_ROOT}/bind-$NAMED_VERSION \
 && rm -f ${NAMED_ROOT}/bind-$NAMED_VERSION.tar.xz \
 && apk del --no-cache --purge \
    xz \
    build-base \
    linux-headers \
    automake \
    autoconf \
    libtool \
    tar \
    curl \
 && mkdir -m 755 -p ${NAMED_ROOT}/dev \
 && mknod -m 666 ${NAMED_ROOT}/dev/random c 1 8 \
 && mknod -m 666 ${NAMED_ROOT}/dev/null c 1 3

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["$NAMED_ROOT/$NAMED_CONFDIR", "$NAMED_ROOT/$NAMED_DATADIR"]
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]

FROM baseimage
COPY files/etc/named ${NAMED_ROOT}${NAMED_CONFDIR}/
COPY files/var/named ${NAMED_ROOT}${NAMED_DATADIR}/
