FROM php:7.4-fpm

# 使用国内 Debian 镜像源（加速 apt-get）
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖（含cron用于计划任务）
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libcurl4-openssl-dev \
    libzip-dev \
    libonig-dev \
    unzip \
    curl \
    cron \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 安装 PHP 扩展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        gd \
        curl \
        mbstring \
        bcmath \
        json \
        session \
        pdo_mysql \
        zip

# PHP 配置（支持 UTF-8 / utf8mb4 多语言）
# 注意: mbstring.http_input, mbstring.http_output, mbstring.internal_encoding, mbstring.func_overload
# 在 PHP 7.4 中已废弃，不可使用，否则会导致启动警告输出到页面造成乱码
RUN echo "upload_max_filesize = 10M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size = 20M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "date.timezone = Asia/Shanghai" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "display_startup_errors = Off" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "short_open_tag = On" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "default_charset = \"UTF-8\"" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "mbstring.encoding_translation = Off" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "mbstring.detect_order = UTF-8,ASCII" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "mbstring.substitute_character = none" >> /usr/local/etc/php/conf.d/custom.ini

# 创建必要目录并设置权限
RUN mkdir -p /var/www/html/wwwroot/caches/caches_template/default \
    && mkdir -p /var/www/html/wwwroot/caches/sessions \
    && mkdir -p /var/www/html/wwwroot/uppic/user \
    && mkdir -p /var/www/html/wwwroot/uppic/ewm \
    && mkdir -p /var/www/html/wwwroot/uppic/banner \
    && chmod -R 777 /var/www/html/wwwroot/caches \
    && chmod -R 777 /var/www/html/wwwroot/uppic

# ★ 清除旧的模板缓存（修复 preg_replace /e 后必须重新编译模板）
RUN rm -rf /var/www/html/wwwroot/caches/caches_template/* \
    && rm -f /var/www/html/wwwroot/caches/*.php \
    && mkdir -p /var/www/html/wwwroot/caches/caches_template/default \
    && chmod -R 777 /var/www/html/wwwroot/caches

# 设置Docker环境标识（供cron_service.php自动检测）
ENV DOCKER_CRON=1

# 复制crontab配置文件
COPY cron-lottery /etc/cron.d/lottery

# 复制启动脚本
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 设置crontab权限
RUN chmod 0644 /etc/cron.d/lottery \
    && crontab /etc/cron.d/lottery \
    && touch /var/log/cron.log

# 清空旧的cron日志（避免显示历史错误信息）
RUN echo "" > /var/www/html/wwwroot/caches/cron.log 2>/dev/null || true

WORKDIR /var/www/html

# 使用自定义entrypoint同时启动php-fpm和cron
ENTRYPOINT ["/docker-entrypoint.sh"]
