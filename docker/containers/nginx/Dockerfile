FROM nginx
MAINTAINER Thierry 'Akarun' Lagasse <thierry@passtech.be>

RUN sed -i -e "/user/s/nginx/www-data/g" /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf
ADD ./default.conf /etc/nginx/conf.d/

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443