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

# inject our custom FIPS module/config. This places it above the override_dh_installchangelogs (the end of override_dh_auto_install-arch)
sed -i '/^override_dh_installchangelogs/i \
\t# install our custom FIPS provider\
\tcp CUSTOMFIPS/providers/fips.so debian/tmp/usr/lib/$(DEB_HOST_MULTIARCH)/ossl-modules/fips.so\
\tcp CUSTOMFIPS/providers/fipsmodule.cnf debian/tmp/usr/lib/ssl/fipsmodule.cnf\n\t$(MAKE) test\n' debian/rules


sed -i '/CONFARGS *=/ s/$/ enable-fips/' debian/rules
echo "usr/lib/ssl/fipsmodule.cnf" >> debian/openssl.install
