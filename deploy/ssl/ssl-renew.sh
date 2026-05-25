#!/bin/bash
#=============================================================
# SSL证书自动续期脚本 - www.hjdsaf.com
# Let's Encrypt 证书有效期90天，建议每60天自动续期
# 创建时间: 2026-05-19
#=============================================================

LOG_FILE="/var/log/letsencrypt/renew.log"
CERT_DOMAIN="www.hjdsaf.com"
LOCK_FILE="/tmp/certbot-renew.lock"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 防止重复执行
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        log "另一个续期进程正在运行 (PID=$PID)，退出"
        exit 1
    fi
    rm -f "$LOCK_FILE"
fi
echo $$ > "$LOCK_FILE"

log "========== 开始SSL证书续期检查 =========="

# 检查证书剩余天数
EXPIRY_DATE=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/$CERT_DOMAIN/cert.pem 2>/dev/null | cut -d= -f2)
if [ -z "$EXPIRY_DATE" ]; then
    log "错误: 无法读取证书信息"
    rm -f "$LOCK_FILE"
    exit 1
fi

EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null)
CURRENT_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))

log "证书域名: $CERT_DOMAIN"
log "证书到期日: $EXPIRY_DATE"
log "剩余天数: $DAYS_LEFT 天"

# 如果剩余天数大于30天，无需续期
if [ $DAYS_LEFT -gt 30 ]; then
    log "证书有效期充足（>${DAYS_LEFT}天），无需续期"
    rm -f "$LOCK_FILE"
    exit 0
fi

log "证书即将到期（剩余${DAYS_LEFT}天），开始续期..."

# 创建ACME验证目录
mkdir -p /var/www/yunwei001/wwwroot/.well-known/acme-challenge
chown -R apache:apache /var/www/yunwei001/wwwroot/.well-known

# 使用webroot方式续期（不需要停止nginx）
certbot renew --webroot \
    -w /var/www/yunwei001/wwwroot \
    --cert-name $CERT_DOMAIN \
    --non-interactive \
    --quiet \
    --deploy-hook "systemctl reload nginx" \
    2>&1 | tee -a "$LOG_FILE"

RENEW_EXIT=$?

if [ $RENEW_EXIT -eq 0 ]; then
    log "✅ 证书续期成功！"

    # 验证新证书
    NEW_EXPIRY=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/$CERT_DOMAIN/cert.pem 2>/dev/null | cut -d= -f2)
    log "新证书到期日: $NEW_EXPIRY"

    # 重载nginx使新证书生效
    systemctl reload nginx
    log "Nginx已重载，新证书已生效"
else
    log "❌ 证书续期失败！退出码: $RENEW_EXIT"
    log "请手动检查: certbot renew --dry-run"

    # 续期失败时发送告警（如果mail命令可用）
    if command -v mail &>/dev/null; then
        echo "SSL证书续期失败: $CERT_DOMAIN，请手动处理" | mail -s "SSL证书续期告警" root@localhost 2>/dev/null
    fi
fi

log "========== 续期检查结束 =========="
rm -f "$LOCK_FILE"
exit $RENEW_EXIT
