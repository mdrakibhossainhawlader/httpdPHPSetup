#!/bin/bash -e
HTTPD_VERSION="2.4.27"
PHP_VERSION="7.1.10"
export LOG="$(pwd)/install.log"
rm -rf install_temp
mkdir install_temp && cd install_temp
echo "Apache httpd & PHP installer"
#dependencies
if type yum > $LOG 2>&1; then
  echo -n "[dependencies] installing..."
  yum -y install libtool autoconf chkconfig libxml2-devel pcre-devel libjpeg-devel libpng-devel freetype-devel mysql-devel openssl-devel curl-devel libxslt-devel >> $LOG 2>&1
elif type apt-get > $LOG 2>&1; then
  echo -n "[libtool] checking..."
  apt-get -y remove libtool >> $LOG 2>&1
  if !(type libtoolize) >> $LOG 2>&1; then
    echo " installing..."
    apt-get source libtool >> $LOG 2>&1
    cd libtool*
    ./configure >> $LOG 2>&1
    make >> $LOG 2>&1
    sudo make install >> $LOG 2>&1
    cd ..
  fi
  echo " done!"
  echo -n "[dependencies] installing..."
  apt-get -y install autoconf libxml2-dev libpcre3-dev libjpeg-dev libpng-dev libfreetype6-dev libmysqlclient-dev libssl-dev libcurl4-openssl-dev libxslt1-dev > $LOG 2>&1
else
	echo "error, yum or apt-get not found"
	exit 1
fi
echo " done!"
#httpd
echo -n "[httpd] downloading $HTTPD_VERSION..."
wget -q -O - "http://mirrors.aliyun.com/apache/httpd/httpd-$HTTPD_VERSION.tar.bz2" | tar -jx >> $LOG 2>&1
mv httpd-$HTTPD_VERSION httpd
echo -n " checkouting apr..."
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
make >> $LOG 2>&1
echo -n " installing..."
sudo make install >> $LOG 2>&1
echo " done!"
#PHP
cd ../php
echo -n "[PHP] checking..."
./configure --prefix=/usr/local/php7 --with-curl --with-freetype-dir --with-gd --with-gettext --with-iconv-dir --with-kerberos --with-libdir=lib64 --with-libxml-dir --with-mysqli --with-openssl --with-pcre-regex --with-pdo-mysql --with-pdo-sqlite --with-pear --with-png-dir --with-xmlrpc --with-xsl --with-zlib --enable-fpm --enable-bcmath --enable-libxml --enable-inline-optimization --enable-gd-native-ttf --enable-mbregex --enable-mbstring --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-xml --enable-zip --with-apxs2=/usr/local/apache2/bin/apxs >> $LOG 2>&1
echo -n " compiling..."
make >> $LOG 2>&1
echo -n " installing..."
sudo make install >> $LOG 2>&1
echo -n " linking..."
sudo ln -s /usr/local/php7/bin/php /usr/bin/php >> $LOG 2>&1
echo " done!"
cd ../..
rm -rf install_temp
echo -n "[httpd] supporting PHP..."
sudo sed -i -e '/DirectoryIndex/s/$/ index.php/g' -e '/AddType application\/x-gzip .gz .tgz/a\    AddType application\/x-httpd-php .php' /usr/local/apache2/conf/httpd.conf >> $LOG 2>&1
echo " done!"
echo -n "[service] adding httpd..."
sudo cp /usr/local/apache2/bin/apachectl /etc/init.d/httpd
echo " done!"
echo -n "[chkconfig] adding httpd..."
if type yum > $LOG 2>&1; then
  sudo sed -i '1a\#chkconfig: - 85 15\n#description: Apache' /etc/init.d/httpd >> $LOG 2>&1
  sudo chkconfig --add httpd >> $LOG 2>&1
elif type apt-get > $LOG 2>&1; then
  sudo sed -i '1a\### BEGIN INIT INFO\n# Provides:\thttpd\n# Required-Start:\t$remote_fs $syslog\n# Required-Stop:\t$remote_fs $syslog\n# Default-Start:\t2 3 4 5\n# Default-Stop:\t0 1 6\n### END INIT INFO' /etc/init.d/httpd >> $LOG 2>&1
  sudo update-rc.d httpd defaults 99 >> $LOG 2>&1
fi
echo " done!"
