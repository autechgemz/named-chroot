#!/usr/bin/env sh
set -e

BIND_ROOT=/chroot
BIND_USER=named
BIND_CONF=/etc/named/named.conf

PATH=${BIND_ROOT}/sbin:$PATH
export PATH

BIND_RNDC_KEY=${BIND_ROOT}/etc/named/rndc.key
if [ ! -f $BIND_RNDC_KEY ]; then
  rndc-confgen -b 512 -a -c $BIND_RNDC_KEY > /dev/null 2>&1
  chmod 0440 $BIND_RNDC_KEY
  chown root:${BIND_USER} $BIND_RNDC_KEY
fi

for BIND_DIRS in etc var ; do
  find "${BIND_ROOT}/${BIND_DIRS}" -type d -exec chmod 0750 {} \;
  find "${BIND_ROOT}/${BIND_DIRS}" -type f -exec chmod 0640 {} \;
  find "${BIND_ROOT}/${BIND_DIRS}" -type d -exec chown ${BIND_USER}:${BIND_USER} {} \;
  find "${BIND_ROOT}/${BIND_DIRS}" -type f -exec chown ${BIND_USER}:${BIND_USER} {} \;
done

exec named -u ${BIND_USER} -t ${BIND_ROOT} -c ${BIND_CONF} -f
