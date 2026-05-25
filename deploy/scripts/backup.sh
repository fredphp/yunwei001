#!/bin/bash
#=============================================================================
# 备份脚本 - 导出当前服务器环境、配置、数据库
# 使用方法: sudo bash deploy/scripts/backup.sh
#=============================================================================

set -e

PROJECT_DIR="/var/www/yunwei001"
DEPLOY_DIR="$PROJECT_DIR/deploy"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "========== 开始备份 =========="

# 1. 备份数据库
echo "[1/5] 备份数据库..."
mysqldump -uroot -proot --databases fantan_db --routines --triggers --events \
    --single-transaction --quick --lock-tables=false \
    > "$DEPLOY_DIR/mysql/fantan_db.sql" 2>/dev/null
echo "  数据库已备份: $DEPLOY_DIR/mysql/fantan_db.sql"

# 2. 备份Nginx配置
echo "[2/5] 备份Nginx配置..."
cp /etc/nginx/nginx.conf "$DEPLOY_DIR/nginx/nginx.conf"
cp /etc/nginx/conf.d/www.hjdsaf.com.conf "$DEPLOY_DIR/nginx/www.hjdsaf.com.conf" 2>/dev/null || true
echo "  Nginx配置已备份"

# 3. 备份PHP配置
echo "[3/5] 备份PHP配置..."
cp /etc/php-fpm.conf "$DEPLOY_DIR/php-fpm/php-fpm.conf"
cp /etc/php-fpm.d/www.conf "$DEPLOY_DIR/php-fpm/www.conf"
cp /etc/php.ini "$DEPLOY_DIR/php-fpm/php.ini"
echo "  PHP配置已备份"

# 4. 备份MariaDB配置
echo "[4/5] 备份MariaDB配置..."
cp /etc/my.cnf "$DEPLOY_DIR/mysql/my.cnf"
echo "  MariaDB配置已备份"

# 5. 备份计划任务
echo "[5/5] 备份计划任务..."
crontab -l > "$DEPLOY_DIR/cron/root.crontab" 2>/dev/null || true
echo "  计划任务已备份"

echo ""
echo "========== 备份完成 =========="
echo "备份目录: $DEPLOY_DIR"
echo ""
echo "如需提交到Git:"
echo "  cd $PROJECT_DIR && git add deploy/ && git commit -m 'backup: 更新备份 $TIMESTAMP'"
