FROM php:5.6-fpm
MAINTAINER Thierry 'Akarun' Lagasse <thierry@passtech.be>

RUN apt-get update && apt-get install -y mcrypt libmcrypt-dev && \
    docker-php-ext-install mcrypt mysql mysqli pdo pdo_mysql

RUN usermod -u 1000 www-data  
RUN usermod -a -G users www-data

CMD ["php-fpm"]
EXPOSE 9000 