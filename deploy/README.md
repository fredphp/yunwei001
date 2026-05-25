# yunwei001 一键部署指南

## 环境要求

| 组件 | 版本 |
|------|------|
| 操作系统 | CentOS 7 / RHEL 7 (x86_64) |
| Nginx | 1.20+ |
| PHP | 7.4 |
| MariaDB | 5.5+ |
| 内存 | ≥ 2GB |
| 磁盘 | ≥ 10GB |

## 快速部署

### 1. 上传项目到新服务器

```bash
# 方式一: Git克隆
git clone https://github.com/fredphp/yunwei001.git /var/www/yunwei001

# 方式二: SCP上传
scp -r yunwei001/ root@新服务器IP:/var/www/yunwei001/
```

### 2. 修改配置

编辑 `deploy/scripts/setup.sh` 顶部的配置变量：

```bash
DOMAIN="你的域名"           # 改为你的域名
DB_PASS="你的数据库密码"    # 改为安全的密码
TIMEZONE="Asia/Shanghai"   # 改为你的时区
```

### 3. 执行一键部署

```bash
cd /var/www/yunwei001
chmod +x deploy/scripts/setup.sh
sudo bash deploy/scripts/setup.sh
```

### 4. 部署后必做

- [ ] 修改数据库密码
- [ ] 更新 `wwwroot/configs/database.php` 中的数据库密码
- [ ] 修改管理员默认密码
- [ ] 修改代理默认密码
- [ ] 申请正式SSL证书（如需要）
- [ ] 检查计划任务是否正常运行: `crontab -l`

## 目录结构

```
deploy/
├── nginx/                    # Nginx配置文件
│   ├── nginx.conf            # 主配置
│   └── www.hjdsaf.com.conf   # 站点配置
├── php-fpm/                  # PHP-FPM配置文件
│   ├── php-fpm.conf          # 主配置
│   ├── www.conf              # 进程池配置
│   └── php.ini               # PHP配置
├── mysql/                    # MySQL配置和数据
│   ├── my.cnf                # MariaDB配置
│   └── fantan_db.sql         # 数据库备份
├── cron/                     # 计划任务
│   └── root.crontab          # Root用户计划任务
├── ssl/                      # SSL证书相关
│   ├── ssl-renew.sh          # 证书续期脚本
│   └── renewal.conf          # 续期配置
├── scripts/                  # 部署脚本
│   ├── setup.sh              # 一键部署脚本
│   └── backup.sh             # 备份脚本
└── README.md                 # 本文档
```

## 计划任务说明

系统配置了以下计划任务：

| 任务 | 频率 | 说明 |
|------|------|------|
| 开奖采集与注单结算 | 每30秒 | cron_service.php 自动开奖和结算 |
| 日志清理 | 每天凌晨3点 | 清理error_log和cron日志 |
| SSL证书续期 | 每周一凌晨2:30 | 自动检查并续期Let's Encrypt证书 |

## 备份与恢复

### 手动备份

```bash
sudo bash /var/www/yunwei001/deploy/scripts/backup.sh
```

### 恢复数据库

```bash
mysql -uroot -p < /var/www/yunwei001/deploy/mysql/fantan_db.sql
```

### 恢复配置

```bash
# Nginx
cp /var/www/yunwei001/deploy/nginx/nginx.conf /etc/nginx/nginx.conf
cp /var/www/yunwei001/deploy/nginx/www.hjdsaf.com.conf /etc/nginx/conf.d/

# PHP-FPM
cp /var/www/yunwei001/deploy/php-fpm/php-fpm.conf /etc/php-fpm.conf
cp /var/www/yunwei001/deploy/php-fpm/www.conf /etc/php-fpm.d/www.conf
cp /var/www/yunwei001/deploy/php-fpm/php.ini /etc/php.ini

# MariaDB
cp /var/www/yunwei001/deploy/mysql/my.cnf /etc/my.cnf
```

## 安全令牌

以下文件包含安全令牌，部署到新服务器后**必须重新生成**：

- `wwwroot/service.php` - SERVICE_TOKEN
- `wwwroot/api/game_service.php` - SERVICE_TOKEN
- `wwwroot/cron_service.php` - SERVICE_TOKEN

生成新令牌：
```bash
openssl rand -base64 32
```

替换三个文件中的令牌值，确保三者一致。

## 常见问题

### Q: 部署后访问502 Bad Gateway
A: 检查PHP-FPM是否运行: `systemctl status php-fpm`，确认socket文件存在: `ls /run/php/php-fpm.sock`

### Q: 数据库连接失败
A: 检查 `wwwroot/configs/database.php` 中的数据库密码是否与实际密码一致

### Q: SSL证书申请失败
A: 确保域名DNS已指向新服务器IP，且80端口可从外网访问

### Q: 计划任务不执行
A: 检查cron服务: `systemctl status crond`，查看日志: `tail -f /var/www/yunwei001/wwwroot/caches/cron.log`
