#!/bin/bash -e
HTTPD_VERSION="2.4.27"
PHP_VERSION="7.1.10"
export LOG="$(pwd)/install.log"
rm -rf install_temp
mkdir install_temp && cd install_temp
echo "Apache httpd & PHP updater"
#httpd
echo -n "[httpd] downloading $HTTPD_VERSION..."
wget -q -O - "http://mirrors.aliyun.com/apache/httpd/httpd-$HTTPD_VERSION.tar.bz2" | tar -jx >> $LOG 2>&1
mv httpd-$HTTPD_VERSION httpd
echo -n " checking out apr..."
svn co http://svn.apache.org/repos/asf/apr/apr/trunk httpd/srclib/apr >> $LOG 2>&1
echo " done!"
#PHP
echo -n "[PHP] downloading $PHP_VERSION..."
wget -q -O - "http://mirrors.sohu.com/php/php-$PHP_VERSION.tar.bz2" | tar -jx >> $LOG 2>&1
echo " done!"
mv php-$PHP_VERSION php
#httpd
cd httpd
echo -n "[httpd] building..."
./buildconf >> $LOG 2>&1
echo -n " checking..."
./configure --with-libxml2 >> $LOG 2>&1
echo -n " compiling..."
make -j 4 >> $LOG 2>&1
echo -n " stopping..."
sudo service httpd stop >> $LOG 2>&1
echo -n " updating..."
sudo make install >> $LOG 2>&1
echo " done!"
#PHP
cd ../php
echo -n "[PHP] checking..."
./configure --prefix=/usr/local/php7 --with-curl --with-freetype-dir --with-gd --with-gettext --with-iconv-dir --with-kerberos --with-libdir=lib64 --with-libxml-dir --with-mysqli --with-openssl --with-pcre-regex --with-pdo-mysql --with-pdo-sqlite --with-pear --with-png-dir --with-xmlrpc --with-xsl --with-zlib --enable-fpm --enable-bcmath --enable-libxml --enable-inline-optimization --enable-gd-native-ttf --enable-mbregex --enable-mbstring --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-xml --enable-zip --with-apxs2=/usr/local/apache2/bin/apxs >> $LOG 2>&1
echo -n " compiling..."
make -j 4 >> $LOG 2>&1
echo -n " updating..."
sudo make install >> $LOG 2>&1
echo " done!"
cd ../..
rm -rf install_temp
echo "Done!"