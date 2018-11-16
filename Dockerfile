# Alpine Image for Nginx and PHP

# NGINX x ALPINE.
FROM nginx:mainline-alpine

# MAINTAINER OF THE PACKAGE.
LABEL maintainer="Li Hao <dokak47@vip.qq.com>"

# INSTALL SOME SYSTEM PACKAGES.

RUN apk --update --no-cache add ca-certificates \
    bash \
    gcc \
    musl-dev \
    make \
    m4 \
    wget \
    autoconf \
    supervisor

# trust this project public key to trust the packages.
ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# IMAGE ARGUMENTS WITH DEFAULTS.
ARG PHP_VERSION=7.2
ARG ALPINE_VERSION=3.7
ARG COMPOSER_HASH=544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061
ARG NGINX_HTTP_PORT=80
ARG NGINX_HTTPS_PORT=443
ARG XDEBUG_PORT=9000

# CONFIGURE ALPINE REPOSITORIES AND PHP BUILD DIR.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "@php https://php.codecasts.rocks/v${ALPINE_VERSION}/php-${PHP_VERSION}" >> /etc/apk/repositories

# INSTALL PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update php-fpm@php \
    php@php \
    php-openssl@php \
    php-pdo@php \
    php-pdo_mysql@php \
    php-mbstring@php \
    php-phar@php \
    php-session@php \
    php-dom@php \
    php-ctype@php \
    php-zlib@php \
    php-json@php \
    php-xml@php \
    php7-pear@php \
    php7-dev@php && \
    ln -s /usr/bin/php7 /usr/bin/php

# CONFIGURE WEB SERVER.
RUN mkdir -p /var/www && \
    mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available && \
    rm /etc/nginx/nginx.conf && \
    rm /etc/php7/php-fpm.d/www.conf && \
    rm /etc/php7/php.ini

# INSTALL COMPOSER.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${COMPOSER_HASH}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# INSTALL XDEBUG
COPY ./config/php/xdebug-2.6.1.tgz /tmp/
RUN pecl install /tmp/xdebug-2.6.1.tgz

# ADD START SCRIPT, SUPERVISOR CONFIG, NGINX CONFIG AND RUN SCRIPTS.
ADD start.sh /start.sh
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx/site.conf /etc/nginx/sites-available/default.conf
ADD config/php/php.ini /etc/php7/php.ini
ADD config/php/xdebug.ini /etc/php7/conf.d/xdebug.ini
ADD config/php-fpm/www.conf /etc/php7/php-fpm.d/www.conf
RUN chmod 755 /start.sh

# EXPOSE PORTS!
EXPOSE ${NGINX_HTTPS_PORT} ${NGINX_HTTP_PORT} ${XDEBUG_PORT}

# SET THE WORK DIRECTORY.
WORKDIR /var/www

# KICKSTART!
CMD ["/start.sh"]
