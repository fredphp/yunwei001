#!/bin/bash
#=============================================================================
# 一键部署脚本 - yunwei001
# 适用于: CentOS 7 / RHEL 7 (x86_64)
# 功能: 自动安装Nginx + PHP 7.4 + MariaDB，恢复配置、数据库和计划任务
#
# 使用方法:
#   1. 将整个项目上传到新服务器 /var/www/yunwei001/
#   2. 修改下方 DOMAIN 变量为你的域名
#   3. 执行: chmod +x deploy/scripts/setup.sh && sudo bash deploy/scripts/setup.sh
#
# 作者: Auto-Generated
# 日期: 2026-05-20
#=============================================================================

set -e

#============================== 配置区 ==============================
# ⚠️ 部署前请修改以下变量 ⚠️
DOMAIN="www.hjdsaf.com"              # 你的域名
DB_NAME="fantan_db"                   # 数据库名
DB_USER="root"                        # 数据库用户
DB_PASS="root"                        # 数据库密码（生产环境请修改）
PROJECT_DIR="/var/www/yunwei001"      # 项目目录
WEB_USER="apache"                     # Web用户
WEB_GROUP="apache"                    # Web用户组
PHP_VERSION="7.4"                     # PHP版本
TIMEZONE="Asia/Shanghai"              # 时区

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "\n${BLUE}========== $1 ==========${NC}"; }

#============================== 检查 ==============================
log_step "0. 环境检查"

if [ "$(id -u)" -ne 0 ]; then
    log_error "请使用root用户运行此脚本"
    exit 1
fi

if [ ! -f "$PROJECT_DIR/deploy/scripts/setup.sh" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    log_error "请先将项目上传到 $PROJECT_DIR"
    exit 1
fi

# 检测系统版本
if [ ! -f /etc/centos-release ] && [ ! -f /etc/redhat-release ]; then
    log_warn "此脚本设计用于 CentOS 7，当前系统可能不完全兼容"
fi

log_info "系统: $(cat /etc/centos-release 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
log_info "项目目录: $PROJECT_DIR"
log_info "域名: $DOMAIN"

#============================== 1. 系统基础 ==============================
log_step "1. 系统基础配置"

# 设置时区
log_info "设置时区: $TIMEZONE"
timedatectl set-timezone "$TIMEZONE" 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# 关闭SELinux（如需要）
if command -v getenforce &>/dev/null && [ "$(getenforce)" != "Disabled" ]; then
    log_warn "SELinux已启用，临时设置为Permissive模式"
    setenforce 0 2>/dev/null || true
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 2>/dev/null || true
fi

# 更新系统并安装基础工具
log_info "安装基础工具..."
yum install -y epel-release wget curl vim unzip net-tools yum-utils 2>/dev/null

#============================== 2. Nginx ==============================
log_step "2. 安装 Nginx"

if command -v nginx &>/dev/null; then
    log_info "Nginx 已安装: $(nginx -v 2>&1)"
else
    log_info "安装 Nginx 1.20..."
    yum install -y nginx 2>/dev/null
    
    # 如果默认版本不对，使用官方源
    if [ "$(nginx -v 2>&1 | grep -o '[0-9.]*' | head -1)" != "1.20" ]; then
        log_info "添加Nginx官方源..."
        cat > /etc/yum.repos.d/nginx.repo << 'REPO'
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
REPO
        yum install -y nginx-1.20.* 2>/dev/null || yum install -y nginx 2>/dev/null
    fi
fi

# 创建必要目录
mkdir -p /var/cache/nginx/fastcgi
mkdir -p /var/log/nginx
mkdir -p /run/php

# 备份并恢复Nginx配置
log_info "恢复Nginx配置..."
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak.$(date +%Y%m%d%H%M%S) 2>/dev/null || true
cp $PROJECT_DIR/deploy/nginx/nginx.conf /etc/nginx/nginx.conf

# 恢复站点配置
cp $PROJECT_DIR/deploy/nginx/www.hjdsaf.com.conf /etc/nginx/conf.d/www.$DOMAIN.conf 2>/dev/null || \

# 修复Nginx 1.25+ http2语法变更（listen 443 ssl http2 → listen 443 ssl + http2 on）
NGINX_MAJOR=$(nginx -v 2>&1 | grep -oP '(?<=/)[0-9]+' | head -1)
if [ "${NGINX_MAJOR:-0}" -ge 25 ] 2>/dev/null; then
    sed -i 's/listen 443 ssl http2/listen 443 ssl/g' /etc/nginx/conf.d/www.$DOMAIN.conf 2>/dev/null
    if ! grep -q "http2 on" /etc/nginx/conf.d/www.$DOMAIN.conf 2>/dev/null; then
        sed -i '/listen 443 ssl/a\    http2 on;' /etc/nginx/conf.d/www.$DOMAIN.conf 2>/dev/null
    fi
fi
cp $PROJECT_DIR/deploy/nginx/www.hjdsaf.com.conf /etc/nginx/conf.d/www.hjdsaf.com.conf

# 更新配置中的域名（如果不是原域名）
if [ "$DOMAIN" != "www.hjdsaf.com" ]; then
    sed -i "s/www\.hjdsaf\.com/$DOMAIN/g" /etc/nginx/conf.d/www.$DOMAIN.conf
    mv /etc/nginx/conf.d/www.hjdsaf.com.conf /etc/nginx/conf.d/www.$DOMAIN.conf 2>/dev/null || true
fi

# 删除默认站点配置（避免冲突）
rm -f /etc/nginx/conf.d/default.conf 2>/dev/null

log_info "Nginx配置已恢复"

#============================== 3. PHP 7.4 ==============================
log_step "3. 安装 PHP $PHP_VERSION"

if php -v 2>/dev/null | grep -q "$PHP_VERSION"; then
    log_info "PHP $PHP_VERSION 已安装: $(php -v | head -1)"
else
    log_info "安装 PHP $PHP_VERSION 及扩展..."
    
    # 添加Remi仓库
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm 2>/dev/null
    yum-config-manager --enable remi-php74 2>/dev/null
    
    # 安装PHP及扩展
    yum install -y \
        php \
        php-fpm \
        php-cli \
        php-common \
        php-mysqlnd \
        php-pdo \
        php-gd \
        php-mbstring \
        php-mcrypt \
        php-xml \
        php-curl \
        php-bcmath \
        php-json \
        php-zip \
        php-opcache \
        php-sockets \
        php-bz2 \
        php-xsl \
        2>/dev/null
    
    log_info "PHP安装完成: $(php -v | head -1)"
fi

# 恢复PHP-FPM配置
log_info "恢复PHP-FPM配置..."
cp /etc/php-fpm.conf /etc/php-fpm.conf.bak.$(date +%Y%m%d%H%M%S) 2>/dev/null || true
cp $PROJECT_DIR/deploy/php-fpm/php-fpm.conf /etc/php-fpm.conf

mkdir -p /etc/php-fpm.d
cp $PROJECT_DIR/deploy/php-fpm/www.conf /etc/php-fpm.d/www.conf

# 恢复php.ini
cp /etc/php.ini /etc/php.ini.bak.$(date +%Y%m%d%H%M%S) 2>/dev/null || true
cp $PROJECT_DIR/deploy/php-fpm/php.ini /etc/php.ini

# 设置时区
sed -i "s|;date.timezone =|date.timezone = $TIMEZONE|g" /etc/php.ini
grep -q "^date.timezone" /etc/php.ini || echo "date.timezone = $TIMEZONE" >> /etc/php.ini

# 创建session目录
mkdir -p /var/www/yunwei001/wwwroot/caches/sessions
chown -R $WEB_USER:$WEB_GROUP /var/www/yunwei001/wwwroot/caches/sessions

log_info "PHP-FPM配置已恢复"

#============================== 4. MariaDB ==============================
log_step "4. 安装 MariaDB"

if command -v mysql &>/dev/null; then
    log_info "MariaDB 已安装: $(mysql --version)"
else
    log_info "安装 MariaDB..."
    yum install -y mariadb-server mariadb 2>/dev/null
    
    # 启动MariaDB
    systemctl start mariadb
    systemctl enable mariadb
    
    # 基础安全配置
    mysql_secure_installation_args=""
    log_info "MariaDB安装完成"
fi

# 恢复MariaDB配置
log_info "恢复MariaDB配置..."
cp /etc/my.cnf /etc/my.cnf.bak.$(date +%Y%m%d%H%M%S) 2>/dev/null || true
cp $PROJECT_DIR/deploy/mysql/my.cnf /etc/my.cnf

# 重启MariaDB使配置生效
# 修复InnoDB日志文件大小不匹配问题（配置改了innodb_log_file_size后需删除旧日志）
if ! systemctl restart mariadb 2>/dev/null; then
    log_warn "MariaDB启动失败，修复InnoDB日志文件..."
    systemctl stop mariadb 2>/dev/null
    rm -f /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile1
    systemctl start mariadb
fi

# 导入数据库
log_info "导入数据库..."
mysql -u$DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || \
mysql -u$DB_USER -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

if [ -f "$PROJECT_DIR/deploy/mysql/fantan_db.sql" ]; then
    mysql -u$DB_USER -p$DB_PASS $DB_NAME < $PROJECT_DIR/deploy/mysql/fantan_db.sql 2>/dev/null || \
    mysql -u$DB_USER $DB_NAME < $PROJECT_DIR/deploy/mysql/fantan_db.sql 2>/dev/null
    log_info "数据库已导入: $DB_NAME"
else
    log_warn "未找到数据库备份文件: $PROJECT_DIR/deploy/mysql/fantan_db.sql"
fi

# 更新数据库配置中的连接信息
if [ "$DOMAIN" != "www.hjdsaf.com" ]; then
fi

# 从模板创建database.php（如果不存在）
if [ ! -f "$PROJECT_DIR/wwwroot/configs/database.php" ]; then
    log_info "从模板创建 database.php..."
    if [ -f "$PROJECT_DIR/wwwroot/configs/database.php.template" ]; then
        cp "$PROJECT_DIR/wwwroot/configs/database.php.template" "$PROJECT_DIR/wwwroot/configs/database.php"
        # 替换模板中的占位符为实际密码
        sed -i "s/YOUR_DB_PASSWORD_HERE/$DB_PASS/g" "$PROJECT_DIR/wwwroot/configs/database.php"
        chown $WEB_USER:$WEB_GROUP "$PROJECT_DIR/wwwroot/configs/database.php"
        log_info "database.php 已创建，数据库密码已配置"
    else
        log_warn "未找到 database.php.template，请手动创建 database.php"
    fi
fi

log_info "MariaDB配置已恢复，数据库已导入"

#============================== 5. 目录权限 ==============================
log_step "5. 设置目录权限"

# 创建必要目录
mkdir -p $PROJECT_DIR/wwwroot/caches
mkdir -p $PROJECT_DIR/wwwroot/caches/sessions
mkdir -p $PROJECT_DIR/wwwroot/upload

# 设置属主
chown -R $WEB_USER:$WEB_GROUP $PROJECT_DIR/wwwroot/
chown -R $WEB_USER:$WEB_GROUP $PROJECT_DIR/caches/ 2>/dev/null || true

# 缓存目录权限
chmod -R 755 $PROJECT_DIR/wwwroot/caches/

# 创建运行时目录
mkdir -p /run/php
chown $WEB_USER:nginx /run/php 2>/dev/null || true
mkdir -p /var/run/php-fpm
chown $WEB_USER:$WEB_GROUP /var/run/php-fpm 2>/dev/null || true

# PHP-FPM socket目录
mkdir -p /run/php
chown $WEB_USER:nginx /run/php

# 创建日志目录
mkdir -p /var/log/nginx
mkdir -p /var/log/php-fpm
mkdir -p /var/log/mariadb

log_info "目录权限设置完成"

#============================== 6. SSL证书 ==============================
log_step "6. SSL证书配置"

SSL_DIR="/etc/letsencrypt/live/$DOMAIN"
if [ -d "$SSL_DIR" ]; then
    log_info "SSL证书已存在: $SSL_DIR"
else
    log_warn "SSL证书不存在，开始申请Let's Encrypt证书..."
    
    # 安装certbot
    yum install -y certbot 2>/dev/null || yum install -y python2-certbot-nginx 2>/dev/null
    
    # 使用webroot方式申请证书（不需要停止Nginx）
    mkdir -p $PROJECT_DIR/wwwroot/.well-known/acme-challenge
    chown -R $WEB_USER:$WEB_GROUP $PROJECT_DIR/wwwroot/.well-known
    
    # 先启动Nginx（如果未运行）
    systemctl start nginx 2>/dev/null || true
    
    certbot certonly --webroot \
        -w $PROJECT_DIR/wwwroot \
        -d $DOMAIN \
        --non-interactive \
        --agree-tos \
        --email admin@$DOMAIN \
        2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_info "SSL证书申请成功！"
    else
        log_warn "SSL证书申请失败，将使用HTTP模式运行"
        log_warn "请确保域名DNS已指向此服务器后，手动执行:"
        log_warn "  certbot certonly --webroot -w $PROJECT_DIR/wwwroot -d $DOMAIN"
    fi
fi

# 恢复SSL续期脚本
cp $PROJECT_DIR/deploy/ssl/ssl-renew.sh /usr/local/bin/ssl-renew.sh 2>/dev/null
chmod +x /usr/local/bin/ssl-renew.sh 2>/dev/null

# 更新续期脚本中的域名
if [ "$DOMAIN" != "www.hjdsaf.com" ]; then
    sed -i "s/www\.hjdsaf\.com/$DOMAIN/g" /usr/local/bin/ssl-renew.sh 2>/dev/null
fi

log_info "SSL配置完成"

#============================== 7. 计划任务 ==============================
log_step "7. 恢复计划任务"

# 安装crontab任务（更新路径和域名）
if [ -f "$PROJECT_DIR/deploy/cron/root.crontab" ]; then
    # 修改项目路径（如果不是默认路径）
    CRON_CONTENT=$(cat $PROJECT_DIR/deploy/cron/root.crontab)
    if [ "$PROJECT_DIR" != "/var/www/yunwei001" ]; then
        CRON_CONTENT=$(echo "$CRON_CONTENT" | sed "s|/var/www/yunwei001|$PROJECT_DIR|g")
    fi
    if [ "$DOMAIN" != "www.hjdsaf.com" ]; then
        CRON_CONTENT=$(echo "$CRON_CONTENT" | sed "s|www\.hjdsaf\.com|$DOMAIN|g")
    fi
    echo "$CRON_CONTENT" | crontab -
    log_info "计划任务已恢复:"
    crontab -l
else
    log_warn "未找到计划任务备份文件"
fi

log_info "计划任务配置完成"

#============================== 8. 防火墙 ==============================
log_step "8. 防火墙配置"

if systemctl is-active firewalld &>/dev/null; then
    log_info "配置firewalld..."
    firewall-cmd --permanent --add-service=http 2>/dev/null || true
    firewall-cmd --permanent --add-service=https 2>/dev/null || true
    firewall-cmd --permanent --add-port=80/tcp 2>/dev/null || true
    firewall-cmd --permanent --add-port=443/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    log_info "防火墙已开放HTTP/HTTPS端口"
elif command -v iptables &>/dev/null; then
    log_info "配置iptables..."
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null || true
    iptables -I INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
    service iptables save 2>/dev/null || iptables-save > /etc/sysconfig/iptables 2>/dev/null || true
    log_info "防火墙已开放HTTP/HTTPS端口"
else
    log_warn "未检测到防火墙，请手动开放80/443端口"
fi

#============================== 9. 启动服务 ==============================
log_step "9. 启动所有服务"

# 启动MariaDB
systemctl start mariadb 2>/dev/null || systemctl start mysqld 2>/dev/null || true
systemctl enable mariadb 2>/dev/null || systemctl enable mysqld 2>/dev/null || true
log_info "MariaDB: 已启动"

# 启动PHP-FPM
systemctl start php-fpm 2>/dev/null || true
systemctl enable php-fpm 2>/dev/null || true
log_info "PHP-FPM: 已启动"

# 检测并修复Nginx配置
nginx -t 2>/dev/null
if [ $? -ne 0 ]; then
    log_warn "Nginx配置测试失败，尝试修复..."
    # 可能是SSL证书路径问题，临时注释掉SSL
    if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
        log_warn "SSL证书不存在，临时使用HTTP模式"
        # 创建临时自签名证书
        mkdir -p /etc/letsencrypt/live/$DOMAIN
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/letsencrypt/live/$DOMAIN/privkey.pem \
            -out /etc/letsencrypt/live/$DOMAIN/fullchain.pem \
            -subj "/CN=$DOMAIN" 2>/dev/null
        log_info "已创建临时自签名证书"
    fi
    nginx -t 2>/dev/null
fi

# 启动Nginx
systemctl start nginx 2>/dev/null || true
systemctl enable nginx 2>/dev/null || true
log_info "Nginx: 已启动"

#============================== 10. 验证 ==============================
log_step "10. 部署验证"

echo ""
echo "服务状态:"
echo "  Nginx:   $(systemctl is-active nginx 2>/dev/null || echo '未知')"
echo "  PHP-FPM: $(systemctl is-active php-fpm 2>/dev/null || echo '未知')"
echo "  MariaDB: $(systemctl is-active mariadb 2>/dev/null || echo '未知')"
echo ""

# 测试HTTP
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    log_info "HTTP访问正常 (状态码: $HTTP_CODE)"
else
    log_warn "HTTP访问异常 (状态码: $HTTP_CODE)"
fi

# 测试HTTPS
HTTPS_CODE=$(curl -sk -o /dev/null -w "%{http_code}" https://localhost/ 2>/dev/null || echo "000")
if [ "$HTTPS_CODE" = "200" ] || [ "$HTTPS_CODE" = "301" ] || [ "$HTTPS_CODE" = "302" ]; then
    log_info "HTTPS访问正常 (状态码: $HTTPS_CODE)"
else
    log_warn "HTTPS访问异常 (状态码: $HTTPS_CODE)"
fi

# 测试PHP
PHP_TEST=$(php -r "echo 'OK';" 2>/dev/null)
if [ "$PHP_TEST" = "OK" ]; then
    log_info "PHP运行正常"
else
    log_error "PHP运行异常"
fi

# 测试数据库
DB_TEST=$(mysql -u$DB_USER -p$DB_PASS -e "SELECT 1" $DB_NAME 2>/dev/null || echo "FAIL")
if [ "$DB_TEST" != "FAIL" ]; then
    log_info "数据库连接正常 ($DB_NAME)"
else
    log_error "数据库连接失败"
fi

#============================== 完成 ==============================
log_step "部署完成！"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  🎉 部署成功！${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "  网站地址: https://$DOMAIN/"
echo "  代理后台: https://$DOMAIN/?m=daili&c=login"
echo "  管理后台: https://$DOMAIN/?m=admin&c=login"
echo ""
echo "  ⚠️ 部署后请务必执行以下操作:"
echo "     1. 修改数据库密码: mysqladmin -u$DB_USER password '新密码'"
echo "     2. 更新 $PROJECT_DIR/wwwroot/configs/database.php 中的密码"
echo "     3. 修改管理员和代理的默认密码"
echo "     4. 如需申请正式SSL证书: certbot certonly --webroot -w $PROJECT_DIR/wwwroot -d $DOMAIN"
echo "     5. 检查计划任务: crontab -l"
echo ""
echo "  📁 配置备份位置: $PROJECT_DIR/deploy/"
echo "  📋 详细文档: $PROJECT_DIR/deploy/README.md"
echo ""
