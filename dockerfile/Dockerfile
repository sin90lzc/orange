FROM openresty/openresty:latest-xenial
MAINTAINER wenhao.cai@lifesense.com

# Docker Build Arguments, For further upgrade
ENV ORANGE_PATH="/usr/local/orange"
ARG LOR_VERSION="0.3.1"
ARG ORANGE_VERSION="lifesense"

ADD docker-entrypoint.sh docker-entrypoint.sh

#  1) Set the bootstrap scripts
#  2) Install yum dependencies
#  3) Cleanup
#  4) Install lor
#  5) Install orange
#  6) Cleanup
#  7) dnsmasq
#  8) Add User
#  9) Add configuration file & bootstrap file
# 10) Fix file permission
RUN \
    chmod 755 docker-entrypoint.sh \
    && mv docker-entrypoint.sh /usr/local/bin \
    %% apt-get update \
    && apt-get install -y \
        dnsmasq \
        unzip \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /sbin/nginx \
    && ln -s /usr/local/openresty/bin/resty /sbin/resty \
    && cd /tmp \
    && curl -fSL https://github.com/sumory/lor/archive/v${LOR_VERSION}.tar.gz -o lor.tar.gz \
    && tar zxf lor.tar.gz \
    && cd /tmp/lor-${LOR_VERSION} \
    && make install \

    && cd /tmp \
    && curl -fSL https://codeload.github.com/caiwenhao/orange/zip/lifesense -o orange.tar.gz \
    && unzip orange.tar.gz \
    && cd orange-${ORANGE_VERSION} \
    && make install \

    && cd / \
    && rm -rf /tmp/* \

    && echo "user=root" > /etc/dnsmasq.conf \
    && echo 'domain-needed' >> /etc/dnsmasq.conf \
    && echo 'listen-address=127.0.0.1' >> /etc/dnsmasq.conf \
    && echo 'resolv-file=/etc/resolv.dnsmasq.conf' >> /etc/dnsmasq.conf \
    && echo 'conf-dir=/etc/dnsmasq.d' >> /etc/dnsmasq.conf \

    && useradd www \
    && echo "www:www" | chpasswd \
    && echo "www   ALL=(ALL)       ALL" >> /etc/sudoers \
    && mkdir -p ${ORANGE_PATH}/logs \
    && chown -R www:www ${ORANGE_PATH}/*

RUN ln -sf /dev/stdout /usr/local/orange/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/orange/logs/error.log

EXPOSE 7777 8888 9999

# Daemon
CMD ["docker-entrypoint.sh"]
