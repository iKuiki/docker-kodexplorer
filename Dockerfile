FROM php:7.3-apache-stretch

# 替换源
RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list /etc/apt/sources.list.d/buster.list
RUN sed -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list /etc/apt/sources.list.d/buster.list

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends libfreetype6-dev libjpeg-dev libpng-dev 2>&1 \
    # Clean up
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

COPY --chmod=777 kodexplorer4.46/ /var/www/html
