#!/bin/bash -ex
PACKAGE="openssl"
PACKAGE_FIRST_CHAR=$(printf "%s" "$PACKAGE" | cut -c1)
VERSION=3.0.14
REVISION=1
DEBIAN_SUFFIX='~deb12u2'
FIPS_VERSION=3.0.9


wget http://deb.debian.org/debian/pool/main/$PACKAGE_FIRST_CHAR/$PACKAGE/${PACKAGE}_$VERSION-$REVISION$DEBIAN_SUFFIX.debian.tar.xz
tar xf ${PACKAGE}_$VERSION-$REVISION$DEBIAN_SUFFIX.debian.tar.xz
rm ${PACKAGE}_$VERSION-$REVISION$DEBIAN_SUFFIX.debian.tar.xz

wget http://deb.debian.org/debian/pool/main/$PACKAGE_FIRST_CHAR/$PACKAGE/${PACKAGE}_$VERSION.orig.tar.gz
tar xf ${PACKAGE}_$VERSION.orig.tar.gz --strip 1
rm ${PACKAGE}_$VERSION.orig.tar.gz

mkdir CUSTOMFIPS
cd CUSTOMFIPS
wget https://www.openssl.org/source/openssl-${FIPS_VERSION}.tar.gz
tar xf openssl-${FIPS_VERSION}.tar.gz
rm openssl-${FIPS_VERSION}.tar.gz
mv openssl-${FIPS_VERSION}/* .
rm -rf openssl-${FIPS_VERSION}
./Configure enable-fips
make -j$(nproc)

cd ..

sed -i '/$(MAKE) -C build_shared all/a\
\t# Install our custom FIPS provider\
\tcp CUSTOMFIPS/providers/fips.so providers/\
\tcp CUSTOMFIPS/providers/fipsmodule.cnf providers/\
\tfor build_dir in build_* ; do \\\
\t\t[ -d "$$build_dir" ] && cp providers/fips.so providers/fipsmodule.cnf "$$build_dir/providers/" ; \\\
\tdone' debian/rules


sed -i 's/Configure shared/Configure shared --with-fips-provider=.\/providers\/fips.so/' debian/rules


sed -i '/CONFARGS *=/ s/$/ enable-fips/' debian/rules
echo "usr/lib/ssl/fipsmodule.cnf" >> debian/openssl.install
