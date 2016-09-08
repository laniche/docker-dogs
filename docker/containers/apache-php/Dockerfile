FROM php:5.6-apache
MAINTAINER Nicolas Collard <beauceron@dogstudio.be>

RUN apt-get update && apt-get install -y \
        ssmtp \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install iconv mbstring mcrypt mysql mysqli pdo pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

ADD ./php.ini /usr/local/etc/php/
ADD ./000-default.conf /etc/apache2/sites-available/
RUN a2enmod rewrite

RUN ln -sf /dev/stdout /var/log/apache2/access.log
RUN ln -sf /dev/stderr /var/log/apache2/error.log

RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data

EXPOSE 80 443
