FROM php:5.6-fpm
MAINTAINER Thierry 'Akarun' Lagasse <thierry@passtech.be>

RUN apt-get update && apt-get install -y \
      ssmtp \
      mcrypt \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      libpng12-dev \
    && docker-php-ext-install iconv mbstring mcrypt mysql mysqli pdo pdo_mysql \ 
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

ADD ./php.ini /usr/local/etc/php/

RUN usermod -u 1000 www-data  
RUN usermod -a -G users www-data

CMD ["php-fpm"]
EXPOSE 9000 
