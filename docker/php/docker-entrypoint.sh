#!/bin/bash
# Docker入口脚本 - 同时启动php-fpm和cron
# 用于蚁彩系统开奖采集与注单结算

# 注意：不用 set -e！cron启动失败不应阻止php-fpm启动

# 设置Docker环境标识（供cron_service.php自动检测环境）
export DOCKER_CRON=1

# 确保日志文件存在
touch /var/www/html/wwwroot/caches/cron.log 2>/dev/null || true
chmod 666 /var/www/html/wwwroot/caches/cron.log 2>/dev/null || true

# 确保必要目录存在
mkdir -p /var/www/html/wwwroot/caches/caches_template/default 2>/dev/null || true
chmod -R 777 /var/www/html/wwwroot/caches 2>/dev/null || true

# ========== 启动cron守护进程 ==========
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting cron daemon..."

# 清除可能存在的旧PID文件（防止cron认为已在运行）
rm -f /var/run/crond.pid /run/crond.pid 2>/dev/null || true

CRON_STARTED=false

# 方法1: service命令（Debian标准方式）
if command -v service &>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Trying: service cron start"
    service cron start 2>&1 && CRON_STARTED=true || true
fi

# 方法2: /etc/init.d/cron（直接调用init脚本）
if [[ "$CRON_STARTED" != "true" ]] && [[ -x /etc/init.d/cron ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Trying: /etc/init.d/cron start"
    /etc/init.d/cron start 2>&1 && CRON_STARTED=true || true
fi

# 方法3: 直接运行cron命令（最可靠的方式）
if [[ "$CRON_STARTED" != "true" ]] && command -v cron &>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Trying: cron (direct)"
    cron 2>&1 && CRON_STARTED=true || true
fi

# 验证cron是否真的在运行
if ps aux 2>/dev/null | grep -v grep | grep -q '[c]ron'; then
    CRON_STARTED=true
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Cron daemon started successfully"
else
    CRON_STARTED=false
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ All cron start methods failed!"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Lottery service will not run automatically"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Manual fix: docker exec yunwei_php cron"
fi

# 显示crontab配置（调试用）
if [[ "$CRON_STARTED" == "true" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Crontab entries:"
    crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | while read line; do
        echo "  $line"
    done
fi

# 测试cron_service.php能否正常连接到Nginx
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Testing cron_service connectivity..."
timeout 10 /usr/local/bin/php /var/www/html/wwwroot/cron_service.php collect 2>&1 | head -8 || echo "  (connectivity test skipped or timed out)"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting php-fpm..."

# 启动php-fpm（使用exec让php-fpm成为PID 1，接收Docker停止信号）
exec php-fpm
