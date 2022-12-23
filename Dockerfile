FROM ubuntu:jammy

ENV TZ Asia/Tokyo
ENV LANG C

ARG NAMED_VERSION=9.18.10
ARG DEBIAN_FRONTEND=noninterractive
ARG NAMED_USER=named
ARG NAMED_ROOT=/chroot
ARG NAMED_CONFDIR=/etc/named
ARG NAMED_DATADIR=/var/named

ARG GOPATH=$NAMED_ROOT
ENV PATH=${NAMED_ROOT}/sbin:${NAMED_ROOT}/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

COPY files/etc/apt/sources.list /etc/apt/sources.list

RUN apt-get update -y \
 && apt-get install --no-install-recommends -y \
    tzdata \
    ca-certificates \
    runit \
    curl \
    gosu \
    build-essential \
    automake \
    autoconf \
    libtool \
    git \
    tar \
    golang \
    libfstrm0 \
    libfstrm-dev \
    protobuf-c-compiler \
    libprotobuf-dev \
    libprotobuf-c-dev \
    libssl-dev \
    libexpat1-dev \
    libxml2-dev \
    python3-ply \
    python3-dev \
    libgcc1 \
    libuv1-dev \
    libcap-dev \
    libjson-c-dev \
    libevent-dev \
    libnghttp2-dev \
 && useradd -r -d ${NAMED_ROOT}${NAMED_DATADIR} -s /sbin/nologin -M $NAMED_USER \
 && mkdir -p $NAMED_ROOT \
 && chown $NAMED_USER.$NAMED_USER $NAMED_ROOT \
 && cd $NAMED_ROOT \
 && curl https://ftp.isc.org/isc/bind9/${NAMED_VERSION}/bind-${NAMED_VERSION}.tar.xz -o $NAMED_ROOT/bind-${NAMED_VERSION}.tar.xz \
 && tar Jxf bind-${NAMED_VERSION}.tar.xz \
 && cd ${NAMED_ROOT}/bind-${NAMED_VERSION}/ \
 && ./configure \
    --prefix=${NAMED_ROOT} \
    --sysconfdir=${NAMED_ROOT}${NAMED_CONFDIR} \
    --with-openssl=/usr \
    --enable-linux-caps \
    --with-libxml2 \
    --with-libjson \
    --enable-shared \
    --with-libtool \
    --with-tuning=large \
    --with-randomdev=/dev/random \
    --enable-dnstap \
    --with-libfstrm \
    --with-protobuf-c \
 && make \
 && make install \
 && cd ${NAMED_ROOT} \
 && go install -v github.com/dnstap/golang-dnstap/dnstap@latest \
 && cd / \
 && rm -rf ${NAMED_ROOT}/include \
 && rm -rf ${NAMED_ROOT}/share \
 && rm -f ${NAMED_ROOT}/bind-${NAMED_VERSION}.tar.xz \
 && rm -rf ${NAMED_ROOT}/bind-${NAMED_VERSION} \
 && rm -rf ${NAMED_ROOT}/src \
 && rm -rf ${NAMED_ROOT}/pkg \
 && apt-get purge -y \
    build-essential \
    automake \
    autoconf \
    libtool \
    git \
    golang \
    xz-utils \
    bzip2 \
    protobuf-c-compiler \
 && apt-get clean -y \
 && apt-get purge -y \
 && apt autopurge -y \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/tmp/* \
 && rm -rf /tmp/* \
 && truncate -s 0 /var/log/*log \
 && mkdir -p ${NAMED_ROOT}/dev \
 && mknod ${NAMED_ROOT}/dev/random c 1 8 \
 && mknod ${NAMED_ROOT}/dev/null c 1 3 \
 && chmod 666 ${NAMED_ROOT}/dev/*

COPY files/etc/named ${NAMED_ROOT}${NAMED_CONFDIR}/
COPY files/var/named ${NAMED_ROOT}${NAMED_DATADIR}/
COPY files/services /etc/service
RUN chmod +x /etc/service/*/run

VOLUME ["${NAMED_ROOT}${NAMED_CONFDIR}", "${NAMED_ROOT}${NAMED_DATADIR}"]

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["runsvdir", "-P", "/etc/service"]
