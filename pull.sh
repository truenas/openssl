#!/bin/bash -ex
PACKAGE="openssl"
PACKAGE_FIRST_CHAR=$(printf "%s" "$PACKAGE" | cut -c1)
VERSION=3.0.11
REVISION=1
DEBIAN_SUFFIX='~deb12u2'


wget http://deb.debian.org/debian/pool/main/$PACKAGE_FIRST_CHAR/$PACKAGE/${PACKAGE}_$VERSION-$REVISION$DEBIAN_SUFFIX.debian.tar.xz
tar xf ${PACKAGE}_$VERSION-$REVISION$DEBIAN_SUFFIX.debian.tar.xz
rm ${PACKAGE}_$VERSION-$REVISION$DEBIAN_SUFFIX.debian.tar.xz

wget http://deb.debian.org/debian/pool/main/$PACKAGE_FIRST_CHAR/$PACKAGE/${PACKAGE}_$VERSION.orig.tar.gz
tar xf ${PACKAGE}_$VERSION.orig.tar.gz --strip 1
rm ${PACKAGE}_$VERSION.orig.tar.gz

sed -i '/CONFARGS *=/ s/$/ enable-fips/' debian/rules
echo "usr/lib/ssl/fipsmodule.cnf" >> debian/openssl.install
