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

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# 应用根目录为root避免被修改
COPY --chown=root:root kodexplorer4.46/ /kodexplorer

WORKDIR /kodexplorer

# 增加group
RUN groupadd -g 1000 kodexplorer
ENV APACHE_RUN_GROUP kodexplorer

# 增加user
RUN useradd -u 1000 -g 1000 kodexplorer
ENV APACHE_RUN_USER kodexplorer

# 修改data目录所有者
RUN chown kodexplorer:kodexplorer -R /kodexplorer/data

# 替换网站目录配置
RUN sed -i "s/\/var\/www\/html/\/kodexplorer/g" /etc/apache2/sites-enabled/000-default.conf
RUN sed -i "s/\/var\/www/\/kodexplorer/g" /etc/apache2/apache2.conf
RUN sed -i "s/\/var\/www/\/kodexplorer/g" /etc/apache2/conf-enabled/docker-php.conf

# 限制访问范围
RUN sed -i "s/;open_basedir =/open_basedir=\/kodexplorer:\/mnt/g" /usr/local/etc/php/php.ini
