FROM alpine:latest

ARG LOCALTIME="Asia/Tokyo"

ARG NAMED_VERSION="9.16.23"
ARG NAMED_ROOT=/chroot
ARG NAMED_CONFDIR=/etc/named
ARG NAMED_DATADIR=/var/named
ARG NAMED_USER=named

ENV PATH="${NAMED_ROOT}/sbin:${NAMED_ROOT}/bin:${PATH}"

RUN apk update \
 && apk upgrade --update --available \
 && apk add --no-cache --virtual .builddeps \
    xz \
    build-base \
    linux-headers \
    automake \
    autoconf \
    libtool \
    git \
    tar \
    go \
    curl \
 && apk add --no-cache \
    tzdata \
    runit \
    su-exec \
    libevent-dev \
    fstrm-dev \
    protobuf-c-dev \
    openssl-dev \
    expat-dev \
    libxml2-dev \
    py3-ply \
    libgcc \
    libuv-dev \
    libcap-dev \
 && addgroup -S named \
 && adduser -S -D -H -h $NAMED_DATADIR -s /sbin/nologin -G $NAMED_USER $NAMED_USER \
 && mkdir -p $NAMED_ROOT \
 && curl https://ftp.isc.org/isc/bind9/${NAMED_VERSION}/bind-${NAMED_VERSION}.tar.xz -o $NAMED_ROOT/bind-${NAMED_VERSION}.tar.xz \
 && cd ${NAMED_ROOT} \
 && tar Jxvf bind-${NAMED_VERSION}.tar.xz \
 && cd ${NAMED_ROOT}/bind-${NAMED_VERSION} \
 && ./configure \
    --prefix=${NAMED_ROOT} \
    --sysconfdir=${NAMED_CONFDIR} \
    --localstatedir=/var \
    --with-openssl=/usr \
    --enable-linux-caps \
    --with-libxml2 \
    --enable-threads \
    --enable-filter-aaaa \
    --enable-ipv6 \
    --enable-shared \
    --enable-static \
    --with-libtool \
    --with-randomdev=/dev/random \
    --enable-dnstap \
    --with-tuning=large \
 && make \
 && make install \
 && cd ${NAMED_ROOT} \
 && go get -u -v github.com/dnstap/golang-dnstap \
 && go get -u -v github.com/dnstap/golang-dnstap/dnstap \
 && go get -u -v github.com/farsightsec/golang-framestream \
 && cd / \
 && rm -rf ${NAMED_ROOT}/bind-$NAMED_VERSION \
 && rm -f ${NAMED_ROOT}/bind-$NAMED_VERSION.tar.xz \
 && rm -rf ${NAMED_ROOT}/src \
 && rm -rf ${NAMED_ROOT}/pkg \
 && apk del --purge --no-cache .builddeps \
 && mkdir -p ${NAMED_ROOT}/dev \
 && mknod ${NAMED_ROOT}/dev/random c 1 8 \
 && mknod ${NAMED_ROOT}/dev/null c 1 3 \
 && ln -sf ${NAMED_ROOT}/${NAMED_CONFDIR}/named.conf ${NAMED_CONFDIR}/named.conf \
 && ln -sf ${NAMED_ROOT}/${NAMED_CONFDIR}/rndc.key ${NAMED_CONFDIR}/rndc.key \
 && ln -sf ${NAMED_ROOT}/${NAMED_CONFDIR}/conf.d ${NAMED_CONFDIR}/conf.d \
 && ln -sf /usr/share/zoneinfo/${LOCALTIME} /etc/localtime

COPY files${NAMED_CONFDIR} ${NAMED_ROOT}${NAMED_CONFDIR}/
COPY files${NAMED_DATADIR} ${NAMED_ROOT}${NAMED_DATADIR}/
COPY files/services /services
RUN chmod +x /services/*/run

VOLUME ["$NAMED_ROOT/$NAMED_CONFDIR", "$NAMED_ROOT/$NAMED_DATADIR"]

EXPOSE 53/tcp 53/udp

CMD ["/sbin/runsvdir", "-P", "/services/"]
