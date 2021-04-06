FROM php:7.4.16-apache

#INSTALANDO PACOTES E LIBS
RUN apt update && apt upgrade
RUN apt update && apt install -y \
        autoconf curl libcurl4-openssl-dev libxslt-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev \ 
        libmemcached-dev libpng-dev libwebp-dev libxml2-dev libmagickwand-dev libkrb5-dev libbz2-dev libzip-dev \
        libtidy-dev libc-client-dev libldb-dev libldap2-dev 

#CONFIGURANDO LIBS DO PHP
RUN docker-php-ext-configure ldap --with-ldap=/usr
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install \
    bcmath calendar gd  \
    mysqli pdo_mysql sockets xml xsl

# Instalando o MCrypt
RUN pecl install mcrypt && docker-php-ext-enable mcrypt
# Instalando o XDebug
RUN pecl install xdebug-3.0.3 && docker-php-ext-enable xdebug
# Configurando o XDebug
RUN echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_autostart = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.

#Instalando git - caso precise puxa algum pacote
RUN apt install -y 

RUN apt clean

# Instalando o Composer
RUN php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN chmod -R 777 /var/www/html

#WORKSPACE
WORKDIR /var/www/html

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2



ENTRYPOINT ["docker-php-entrypoint"]
# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

#POSTAS EXPOSTAS
EXPOSE 80
EXPOSE 403

CMD ["/usr/sbin/apachectl","-DFOREGROUND"]