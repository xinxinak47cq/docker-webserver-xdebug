# Alpine Image for Nginx and PHP

# NGINX x ALPINE.
FROM creativitykills/nginx-php-server

# MAINTAINER OF THE PACKAGE.
LABEL maintainer="Li Hao <dokak47@vip.qq.com>"

# INSTALL SOME SYSTEM PACKAGES.

RUN apk --update --no-cache add ca-certificates \
    musl-dev \
    make \
    m4 \
    autoconf

ARG PHP_VERSION=7.2
ARG ALPINE_VERSION=3.7
ARG COMPOSER_HASH=544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061
ARG NGINX_HTTP_PORT=80
ARG NGINX_HTTPS_PORT=443
ARG XDEBUG_PORT=9000

# INSTALL PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update \
    php7-pear@php \
    php7-dev@php

# INSTALL XDEBUG
COPY ./config/php/xdebug-2.6.1.tgz /tmp
RUN cd /tmp
RUN ls
RUN pecl install xdebug-2.6.1.tgz

ADD config/php/xdebug.ini /etc/php7/conf.d/xdebug.ini

# EXPOSE PORTS!
EXPOSE ${NGINX_HTTPS_PORT} ${NGINX_HTTP_PORT} ${XDEBUG_PORT}

# SET THE WORK DIRECTORY.
WORKDIR /var/www

# KICKSTART!
CMD ["ls"]
