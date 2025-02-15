FROM ubuntu:noble AS named-baseimage

ENV TZ=Asia/Tokyo
ENV LANG=C

ARG NAMED_VERSION

ARG DEBIAN_FRONTEND=noninterractive
ARG NAMED_USER=named
ARG NAMED_ROOT=/chroot
ARG NAMED_CONFDIR=/etc/named
ARG NAMED_DATADIR=/var/named

ENV GOPATH=${NAMED_ROOT}
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
    tar \
    golang \
    fstrm-bin \
    libfstrm0 \
    libfstrm-dev \
    protobuf-c-compiler \
    libprotobuf-dev \
    libprotobuf-c-dev \
    libevent-dev \
    libssl-dev \
    libexpat1-dev \
    libxml2-dev \
    libjson-c-dev \
    python3-minimal \
    python3-ply \
    libgcc1 \
    libuv1-dev \
    libcap-dev \
    libnghttp2-dev \
    libjemalloc-dev \
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
    --localstatedir=/ \
    --with-openssl=/usr \
    --enable-linux-caps \
    --with-libxml2 \
    --enable-shared \
    --disable-static \
    --enable-largefile \
    --enable-dnstap \
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
    perl \
    python3 \
    python3.12 \
    xz-utils \
    bzip2 \
    golang \
    protobuf-c-compiler \
 && apt-get clean -y \
 && apt-get purge -y \
 && apt autopurge -y \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/tmp/* \
 && rm -rf /tmp/* \
 && truncate -s 0 /var/log/*log \
 && mkdir -m 755 -p ${NAMED_ROOT}/dev \
 && mknod -m 666 ${NAMED_ROOT}/dev/random c 1 8 \
 && mknod -m 666 ${NAMED_ROOT}/dev/null c 1 3

COPY files/services /etc/service
RUN chmod +x /etc/service/*/run

VOLUME ["${NAMED_ROOT}${NAMED_CONFDIR}", "${NAMED_ROOT}${NAMED_DATADIR}"]
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["runsvdir", "-P", "/etc/service"]

FROM named-baseimage

COPY files/etc/named ${NAMED_ROOT}${NAMED_CONFDIR}/
COPY files/var/named ${NAMED_ROOT}${NAMED_DATADIR}/

