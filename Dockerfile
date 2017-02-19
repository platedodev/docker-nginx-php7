FROM nginx:1.11.10

MAINTAINER Martin "martin@dos-santos.io"

EXPOSE 80 443
# Instalamos librerías requeridas.
RUN apt update && apt install -y curl wget build-essential nano autoconf libfcgi-dev libfcgi0ldbl libjpeg62-turbo-dbg libmcrypt-dev libssl-dev libc-client2007e libc-client2007e-dev libxml2-dev libbz2-dev libcurl4-openssl-dev libjpeg-dev libpng12-dev libfreetype6-dev libkrb5-dev libpq-dev libxml2-dev libxslt1-dev
# Nos vemos a la carpeta temporal.
WORKDIR /tmp
# Bajamos PHP 7.1.2 y lo descomprimimos.
RUN wget -O php.tar.gz http://php.net/get/php-7.1.2.tar.gz/from/this/mirror && tar -zxvf php.tar.gz && ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a
# Entramos a la carpeta del codigo fuente de PHP.
WORKDIR /tmp/php-7.1.2
# Compilamos PHP y lo instalamos.
RUN ./configure --prefix=/opt/php-7.1.2 --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-fpm && make && make install
# Copiamos los archivos de configuración.
RUN cp php.ini-production /opt/php-7.1.2/lib/php.ini && cp /opt/php-7.1.2/etc/php-fpm.conf.default /opt/php-7.1.2/etc/php-fpm.conf && cp /opt/php-7.1.2/etc/php-fpm.d/www.conf.default /opt/php-7.1.2/etc/php-fpm.d/www.conf
COPY ./php7-fpm.service /etc/init.d/php7-fpm
COPY ./php-fpm.conf /opt/php-7.1.2/etc/php-fpm.conf
COPY ./php.ini /opt/php-7.1.2/lib/php.ini
# Creamos el servicio php7-fpm.
RUN chmod 755 /etc/init.d/php7-fpm && insserv php7-fpm && /etc/init.d/php7-fpm start
# Creamos una referencia a php en los binarios.
RUN ln -s /opt/php-7.1.2/bin/php /bin/php
# Limpiamos.
WORKDIR /tmp
RUN rm -rf /tmp/php7.1.2 && rm php.tar.gz
# Nos vamos a la carpeta default de nginx.
WORKDIR /usr/share/nginx/html