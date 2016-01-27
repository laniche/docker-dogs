FROM elasticsearch:1.7

MAINTAINER Nicolas Collard <beauceron@dogstudio.be>

RUN usermod -u 1000 elasticsearch
RUN usermod -a -G users elasticsearch

RUN /usr/share/elasticsearch/bin/plugin install "elasticsearch/elasticsearch-analysis-icu/2.7.0"
