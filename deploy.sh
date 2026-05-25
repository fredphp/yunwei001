#!/bin/bash
#=============================================================================
# 蚁彩（蚂蚁彩票）系统一键部署脚本
# 版本: v2.0
# 日期: 2026-03-05
# 兼容: Ubuntu 18.04/20.04/22.04/24.04, CentOS 7/8, Debian 10/11/12
# 用法:
#   sudo bash deploy.sh                                    # 交互式
#   sudo bash deploy.sh --db-pass MyP@ssw0rd --domain example.com -y  # 非交互式
#   sudo bash deploy.sh --check-only                       # 仅环境检查
#   sudo bash deploy.sh --help                             # 帮助
#=============================================================================

set -eo pipefail

#=============================
# 颜色定义
#=============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'  # No Color

#=============================
# 默认配置
#=============================
DB_HOST="127.0.0.1"
DB_USER="root"
DB_PASS="root"
DB_NAME="fantan_db"
DOMAIN="localhost"
WEB_ROOT="/var/www/yunwei"
PHP_VERSION=""
SKIP_CONFIRM=false
CHECK_ONLY=false
REPO_URL="https://github.com/fredphp/yunwei001.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#=============================
# 工具函数
#=============================
log_info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()    { echo -e "\n${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${CYAN}${BOLD}  ▶ $*${NC}"; echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
log_success() { echo -e "${GREEN}${BOLD}  ✅ $*${NC}"; }
log_fail()    { echo -e "${RED}${BOLD}  ❌ $*${NC}"; }

separator()   { echo -e "${BLUE}─────────────────────────────────────────────────${NC}"; }

#=============================
# 参数解析
#=============================
show_help() {
    cat << 'EOF'
蚁彩（蚂蚁彩票）系统一键部署脚本 v2.0

用法: sudo bash deploy.sh [选项]

选项:
  --db-host HOST       MySQL 主机地址         (默认: 127.0.0.1)
  --db-user USER       MySQL 用户名           (默认: root)
  --db-pass PASS       MySQL 密码             (默认: root)
  --db-name NAME       数据库名               (默认: fantan_db)
  --domain DOMAIN      绑定域名               (默认: localhost)
  --web-root PATH      Web 根目录             (默认: /var/www/yunwei)
  --php-version VER    PHP 版本               (默认: 自动检测，优先7.4)
  -y                   跳过确认，自动继续
  --check-only         仅执行环境检查，不部署
  --help               显示帮助信息

示例:
  # 交互式部署
  sudo bash deploy.sh

  # 指定数据库密码和域名
  sudo bash deploy.sh --db-pass MyP@ssw0rd --domain example.com -y

  # 一键远程部署（在服务器上执行）
  bash <(curl -sL https://raw.githubusercontent.com/fredphp/yunwei001/main/deploy.sh) --db-pass root --domain www.hjdsaf.com -y
EOF
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --db-host)    DB_HOST="$2"; shift 2 ;;
            --db-user)    DB_USER="$2"; shift 2 ;;
            --db-pass)    DB_PASS="$2"; shift 2 ;;
            --db-name)    DB_NAME="$2"; shift 2 ;;
            --domain)     DOMAIN="$2"; shift 2 ;;
            --web-root)   WEB_ROOT="$2"; shift 2 ;;
            --php-version) PHP_VERSION="$2"; shift 2 ;;
            -y)           SKIP_CONFIRM=true; shift ;;
            --check-only) CHECK_ONLY=true; shift ;;
            --help|-h)    show_help ;;
            *)            log_error "未知参数: $1"; show_help ;;
        esac
    done
}

#=============================
# 系统检测
#=============================
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="${ID:-unknown}"
        OS_VERSION="${VERSION_ID:-unknown}"
        OS_NAME="${PRETTY_NAME:-Unknown}"
    elif [ -f /etc/redhat-release ]; then
        OS_ID="centos"
        OS_VERSION=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | head -1)
        OS_NAME=$(cat /etc/redhat-release)
    else
        OS_ID="unknown"
        OS_VERSION="unknown"
        OS_NAME="Unknown"
    fi
    
    # 判断包管理器
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
    else
        PKG_MANAGER="unknown"
    fi
}

# 自动检测可用的 PHP 版本
detect_php_version() {
    if [[ -n "$PHP_VERSION" ]]; then
        return
    fi
    
    log_info "自动检测可用的 PHP 版本..."
    
    # 优先级: 7.4 > 7.3 > 7.2 > 7.1 > 7.0 > 8.x（兼容）
    local -a preferred_versions=("7.4" "7.3" "7.2" "7.1" "7.0" "8.3" "8.2" "8.1" "8.0")
    
    for ver in "${preferred_versions[@]}"; do
        if command -v "php${ver}" &>/dev/null; then
            PHP_VERSION="$ver"
            log_success "检测到 PHP ${ver}"
            return
        fi
    done
    
    # 检查默认 php 命令
    if command -v php &>/dev/null; then
        local ver=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;" 2>/dev/null)
        if [[ -n "$ver" ]]; then
            PHP_VERSION="$ver"
            log_success "检测到 PHP ${ver} (默认)"
            return
        fi
    fi
    
    # 根据操作系统选择默认版本
    case "$OS_ID" in
        ubuntu|debian)
            if [[ "$OS_VERSION" == "18.04" || "$OS_VERSION" == "10" ]]; then
                PHP_VERSION="7.2"
            elif [[ "$OS_VERSION" == "20.04" || "$OS_VERSION" == "11" ]]; then
                PHP_VERSION="7.4"
            else
                # Ubuntu 22.04+ 默认没有 PHP 7.4，使用 8.x
                PHP_VERSION="8.1"
            fi
            ;;
        centos|rhel|rocky|almalinux)
            PHP_VERSION="7.4"
            ;;
        *)
            PHP_VERSION="7.4"
            ;;
    esac
    log_info "使用默认 PHP 版本: ${PHP_VERSION}"
}

#=============================
# 阶段 1: 环境检查
#=============================
PHASE1_ERRORS=0
PHASE1_WARNINGS=0

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要 root 权限运行"
        log_info  "请使用: sudo bash $0"
        exit 1
    fi
    log_success "root 权限检查通过"
}

check_os() {
    detect_os
    log_info "操作系统: ${OS_NAME}"
    log_info "包管理器: ${PKG_MANAGER}"
    
    case "$OS_ID" in
        ubuntu|debian)
            log_success "操作系统兼容"
            ;;
        centos|rhel|rocky|almalinux)
            log_success "操作系统兼容"
            ;;
        *)
            log_warn "未经测试的操作系统: ${OS_ID}，部署可能需要手动调整"
            ((PHASE1_WARNINGS++))
            ;;
    esac
}

check_nginx() {
    if command -v nginx &>/dev/null; then
        local ver=$(nginx -v 2>&1)
        log_success "Nginx 已安装: ${ver}"
    else
        log_warn "Nginx 未安装 — 将在部署阶段自动安装"
        ((PHASE1_WARNINGS++))
    fi
}

check_php() {
    detect_php_version
    
    local php_bin=""
    if command -v "php${PHP_VERSION}" &>/dev/null; then
        php_bin="php${PHP_VERSION}"
    elif command -v php &>/dev/null; then
        php_bin="php"
    fi
    
    if [[ -n "$php_bin" ]]; then
        local ver=$($php_bin -v 2>/dev/null | head -1)
        log_info "PHP 版本: ${ver}"
        
        local major=$($php_bin -r 'echo PHP_MAJOR_VERSION;' 2>/dev/null)
        local minor=$($php_bin -r 'echo PHP_MINOR_VERSION;' 2>/dev/null)
        
        if [[ "$major" == "7" ]] && [[ "$minor" -ge 0 ]] && [[ "$minor" -le 4 ]]; then
            log_success "PHP 版本兼容 (7.x)"
        elif [[ "$major" -ge 8 ]]; then
            log_warn "PHP ${major}.${minor} — 可以运行，但推荐 PHP 7.4"
            log_info "  注意: PHP 8.x 中部分旧语法可能产生 Warning，不影响核心功能"
            ((PHASE1_WARNINGS++))
        elif [[ "$major" == "5" ]]; then
            log_warn "PHP 5.x 已弃用，建议升级到 PHP 7.4"
            ((PHASE1_WARNINGS++))
        else
            log_warn "PHP 版本未确认: ${ver}"
            ((PHASE1_WARNINGS++))
        fi
        
        check_php_extensions "$php_bin"
    else
        log_warn "PHP 未安装 — 将在部署阶段自动安装 PHP ${PHP_VERSION}"
        ((PHASE1_WARNINGS++))
    fi
}

check_php_extensions() {
    local php_bin="$1"
    local -a required=("mysqli" "gd" "curl" "session" "mbstring" "bcmath")
    local -a missing=()
    
    local major=$($php_bin -r 'echo PHP_MAJOR_VERSION;' 2>/dev/null)
    if [[ "$major" -lt 8 ]]; then
        required+=("json")
    fi
    
    for ext in "${required[@]}"; do
        if $php_bin -m 2>/dev/null | grep -qi "^${ext}$"; then
            log_info "  PHP 扩展 ${ext}: ✅ 已安装"
        else
            log_warn "  PHP 扩展 ${ext}: ❌ 未安装"
            missing+=("$ext")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "缺失 PHP 扩展: ${missing[*]} — 将在部署阶段自动安装"
        ((PHASE1_WARNINGS++))
    else
        log_success "所有必需 PHP 扩展已安装"
    fi
}

check_mysql() {
    if command -v mysql &>/dev/null; then
        local ver=$(mysql --version 2>/dev/null)
        log_success "MySQL/MariaDB 已安装: ${ver}"
        
        if mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" -e "SELECT 1;" &>/dev/null; then
            log_success "MySQL 连接成功 (${DB_USER}@${DB_HOST})"
        elif mysql -u"${DB_USER}" -h"${DB_HOST}" -e "SELECT 1;" &>/dev/null; then
            log_success "MySQL 连接成功 (无密码)"
            DB_PASS=""
        else
            log_warn "MySQL 连接失败 — 部署时会尝试初始化"
            ((PHASE1_WARNINGS++))
        fi
    else
        log_warn "MySQL 未安装 — 将在部署阶段自动安装"
        ((PHASE1_WARNINGS++))
    fi
}

check_ports() {
    local -a ports=(80 443 3306)
    for port in "${ports[@]}"; do
        if ss -tlnp 2>/dev/null | grep -q ":${port} "; then
            local proc=$(ss -tlnp 2>/dev/null | grep ":${port} " | awk '{print $NF}' | head -1)
            log_info "端口 ${port}: 已被占用 (${proc})"
        else
            log_info "端口 ${port}: 可用"
        fi
    done
}

check_disk_space() {
    local avail=$(df -BG "${WEB_ROOT%/*}" 2>/dev/null | awk 'NR==2{print $4}' | tr -d 'G')
    if [[ -n "$avail" ]] && [[ "$avail" -lt 1 ]]; then
        log_error "磁盘空间不足: 仅剩 ${avail}GB，至少需要 1GB"
        ((PHASE1_ERRORS++))
    else
        log_success "磁盘空间充足: ${avail:-?}GB 可用"
    fi
}

phase1_environment_check() {
    log_step "阶段 1/6: 环境检查"
    
    check_root
    check_os
    check_nginx
    check_php
    check_mysql
    check_ports
    check_disk_space
    
    separator
    if [[ $PHASE1_ERRORS -gt 0 ]]; then
        log_error "环境检查发现 ${PHASE1_ERRORS} 个严重问题，${PHASE1_WARNINGS} 个警告"
        log_error "请先解决严重问题后再继续"
        exit 1
    elif [[ $PHASE1_WARNINGS -gt 0 ]]; then
        log_warn "环境检查发现 ${PHASE1_WARNINGS} 个警告，部署时将尝试自动解决"
    else
        log_success "环境检查全部通过！"
    fi
    
    if [[ "$CHECK_ONLY" == true ]]; then
        log_info "--check-only 模式，仅检查环境，退出"
        exit 0
    fi
}

#=============================
# 阶段 2: 安装依赖
#=============================
install_nginx_apt() {
    log_info "使用 apt 安装 Nginx..."
    apt-get update -qq
    apt-get install -y -qq nginx
    systemctl enable nginx
    log_success "Nginx 安装完成"
}

install_nginx_yum() {
    log_info "使用 ${PKG_MANAGER} 安装 Nginx..."
    ${PKG_MANAGER} install -y epel-release 2>/dev/null || true
    ${PKG_MANAGER} install -y nginx
    systemctl enable nginx
    log_success "Nginx 安装完成"
}

install_php_apt() {
    log_info "使用 apt 安装 PHP ${PHP_VERSION} + 扩展..."
    
    apt-get update -qq
    
    # 添加 PHP PPA（Ubuntu）
    if [[ "$OS_ID" == "ubuntu" ]]; then
        apt-get install -y -qq software-properties-common 2>/dev/null || true
        add-apt-repository -y ppa:ondrej/php 2>/dev/null || true
        apt-get update -qq
    elif [[ "$OS_ID" == "debian" ]]; then
        apt-get install -y -qq software-properties-common gnupg2 lsb-release curl 2>/dev/null || true
        local codename=$(lsb_release -sc 2>/dev/null || echo "bullseye")
        curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg 2>/dev/null || true
        echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php ${codename} main" > /etc/apt/sources.list.d/sury-php.list 2>/dev/null || true
        apt-get update -qq 2>/dev/null || true
    fi
    
    local php_fpm="php${PHP_VERSION}-fpm"
    local -a php_exts=(
        "php${PHP_VERSION}-mysql"
        "php${PHP_VERSION}-gd"
        "php${PHP_VERSION}-curl"
        "php${PHP_VERSION}-mbstring"
        "php${PHP_VERSION}-bcmath"
        "php${PHP_VERSION}-xml"
        "php${PHP_VERSION}-zip"
    )
    
    local major="${PHP_VERSION%%.*}"
    if [[ "$major" -lt 8 ]]; then
        php_exts+=("php${PHP_VERSION}-json")
    fi
    
    log_info "安装: ${php_fpm} ${php_exts[*]}"
    apt-get install -y -qq "${php_fpm}" "${php_exts[@]}" 2>&1 | tail -5
    
    systemctl enable "php${PHP_VERSION}-fpm"
    log_success "PHP ${PHP_VERSION} + 扩展安装完成"
}

install_php_yum() {
    log_info "使用 ${PKG_MANAGER} 安装 PHP ${PHP_VERSION} + 扩展..."
    
    ${PKG_MANAGER} install -y epel-release 2>/dev/null || true
    ${PKG_MANAGER} install -y "https://rpms.remirepo.net/enterprise/remi-release-${OS_VERSION%%.*}.rpm" 2>/dev/null || true
    ${PKG_MANAGER} install -y yum-utils 2>/dev/null || true
    yum-config-manager --enable "remi-php${PHP_VERSION}" 2>/dev/null || true
    
    local ver_nodots="${PHP_VERSION//./}"
    ${PKG_MANAGER} install -y \
        "php${ver_nodots}-php-fpm" \
        "php${ver_nodots}-php-mysqlnd" \
        "php${ver_nodots}-php-gd" \
        "php${ver_nodots}-php-curl" \
        "php${ver_nodots}-php-mbstring" \
        "php${ver_nodots}-php-bcmath" \
        "php${ver_nodots}-php-json" \
        "php${ver_nodots}-php-xml" \
        "php${ver_nodots}-php-zip" 2>/dev/null || {
            log_warn "Remi 仓库安装失败，尝试默认 PHP..."
            ${PKG_MANAGER} install -y php-fpm php-mysqlnd php-gd php-curl php-mbstring php-bcmath php-json php-xml php-zip
        }
    
    systemctl enable php-fpm 2>/dev/null || systemctl enable "php${ver_nodots}-php-fpm" 2>/dev/null || true
    log_success "PHP + 扩展安装完成"
}

install_mysql_apt() {
    log_info "使用 apt 安装 MySQL..."
    apt-get update -qq
    
    if apt-cache show mysql-server &>/dev/null; then
        apt-get install -y -qq mysql-server
        systemctl enable mysql
        systemctl start mysql
    else
        log_info "MySQL 不可用，安装 MariaDB..."
        apt-get install -y -qq mariadb-server
        systemctl enable mariadb
        systemctl start mariadb
    fi
    log_success "MySQL/MariaDB 安装完成"
}

install_mysql_yum() {
    log_info "使用 ${PKG_MANAGER} 安装 MySQL/MariaDB..."
    ${PKG_MANAGER} install -y mariadb-server 2>/dev/null || ${PKG_MANAGER} install -y mysql-server
    systemctl enable mariadb 2>/dev/null || systemctl enable mysqld 2>/dev/null || true
    systemctl start mariadb 2>/dev/null || systemctl start mysqld 2>/dev/null || true
    log_success "MySQL/MariaDB 安装完成"
}

phase2_install_dependencies() {
    log_step "阶段 2/6: 安装依赖"
    
    case "$PKG_MANAGER" in
        apt) apt-get update -qq; apt-get install -y -qq git curl 2>/dev/null || true ;;
        yum|dnf) ${PKG_MANAGER} install -y git curl 2>/dev/null || true ;;
    esac
    
    if ! command -v nginx &>/dev/null; then
        case "$PKG_MANAGER" in
            apt) install_nginx_apt ;;
            yum|dnf) install_nginx_yum ;;
        esac
    else
        log_success "Nginx 已安装，跳过"
    fi
    
    local php_bin="php${PHP_VERSION}"
    if ! command -v "$php_bin" &>/dev/null && ! command -v php &>/dev/null; then
        case "$PKG_MANAGER" in
            apt) install_php_apt ;;
            yum|dnf) install_php_yum ;;
        esac
    else
        log_success "PHP 已安装，跳过"
    fi
    
    if ! command -v mysql &>/dev/null; then
        case "$PKG_MANAGER" in
            apt) install_mysql_apt ;;
            yum|dnf) install_mysql_yum ;;
        esac
    else
        log_success "MySQL 已安装，跳过"
    fi
}

#=============================
# 阶段 3: 部署代码
#=============================
phase3_deploy_code() {
    log_step "阶段 3/6: 部署代码"
    
    local src_dir=""
    
    if [[ -d "${SCRIPT_DIR}/wwwroot" ]]; then
        src_dir="${SCRIPT_DIR}"
        log_info "检测到当前目录包含项目代码: ${src_dir}"
    fi
    
    mkdir -p "${WEB_ROOT}"
    
    if [[ -n "$src_dir" && "$src_dir" != "$WEB_ROOT" ]]; then
        log_info "复制代码到 ${WEB_ROOT}..."
        cp -a "${src_dir}/." "${WEB_ROOT}/"
        log_success "代码复制完成"
    elif [[ "$src_dir" == "$WEB_ROOT" ]]; then
        log_info "代码已在目标目录，跳过复制"
    else
        if command -v git &>/dev/null; then
            log_info "从 GitHub 克隆代码: ${REPO_URL}"
            git clone "${REPO_URL}" "${WEB_ROOT}" --depth 1
            log_success "代码克隆完成"
        else
            log_error "未找到 git，且当前目录无项目代码"
            log_info  "请先安装 git 或手动复制代码到 ${WEB_ROOT}"
            exit 1
        fi
    fi
    
    if [[ ! -f "${WEB_ROOT}/wwwroot/index.php" ]]; then
        log_error "未找到入口文件: ${WEB_ROOT}/wwwroot/index.php"
        log_error "请确认代码完整性"
        exit 1
    fi
    log_success "入口文件验证通过"
}

#=============================
# 阶段 4: 数据库初始化
#=============================
phase4_database() {
    log_step "阶段 4/6: 数据库初始化"
    
    if ! systemctl is-active --quiet mysql 2>/dev/null && ! systemctl is-active --quiet mariadb 2>/dev/null; then
        log_info "启动 MySQL 服务..."
        systemctl start mysql 2>/dev/null || systemctl start mariadb 2>/dev/null || true
        sleep 2
    fi
    
    # 如果是新安装的 MySQL，尝试设置密码
    if ! mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" -e "SELECT 1;" &>/dev/null; then
        if mysql -u"${DB_USER}" -h"${DB_HOST}" -e "SELECT 1;" &>/dev/null; then
            log_info "MySQL root 用户无密码，设置密码..."
            mysql -u"${DB_USER}" -h"${DB_HOST}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASS}'; FLUSH PRIVILEGES;" 2>/dev/null || \
            mysql -u"${DB_USER}" -h"${DB_HOST}" -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${DB_PASS}'); FLUSH PRIVILEGES;" 2>/dev/null || true
        else
            log_info "尝试使用 sudo 访问 MySQL..."
            if sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}'; FLUSH PRIVILEGES;" 2>/dev/null; then
                log_success "MySQL root 密码已设置"
            elif sudo mysql -e "CREATE USER IF NOT EXISTS 'root'@'localhost' IDENTIFIED BY '${DB_PASS}'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null; then
                log_success "MySQL root 用户已创建"
            else
                log_error "MySQL 连接失败！请检查账号密码"
                exit 1
            fi
        fi
    fi
    
    log_info "测试 MySQL 连接 (${DB_USER}@${DB_HOST})..."
    if ! mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" -e "SELECT 1;" &>/dev/null; then
        log_error "MySQL 连接失败！"
        exit 1
    fi
    log_success "MySQL 连接成功"
    
    log_info "创建数据库 ${DB_NAME} (utf8mb4)..."
    mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" -e \
        "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
    log_success "数据库已创建/已存在"
    
    local table_count=$(mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" -e \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}';" 2>/dev/null | tail -1)
    
    if [[ "$table_count" -gt 0 ]]; then
        log_warn "数据库 ${DB_NAME} 已有 ${table_count} 张表"
        log_info  "跳过数据导入（如需重新导入，请先手动 DROP DATABASE）"
    else
        local sql_file="${WEB_ROOT}/sql/fantan_db.sql"
        if [[ -f "$sql_file" ]]; then
            log_info "导入数据库: ${sql_file}..."
            mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" --default-character-set=utf8mb4 "${DB_NAME}" < "$sql_file" 2>/dev/null
            log_success "数据库导入完成"
            
            # 确保 bc_session 表使用 MEMORY 引擎
            mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" "${DB_NAME}" -e \
                "ALTER TABLE bc_session ENGINE=MEMORY;" 2>/dev/null || true
            
            # 确保 pop800 设置存在
            mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" "${DB_NAME}" -e \
                "INSERT IGNORE INTO bc_settings (name, data) VALUES ('pop800', '465109');" 2>/dev/null || true
        else
            log_error "SQL 文件不存在: ${sql_file}"
            exit 1
        fi
    fi
    
    local final_count=$(mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" -e \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}';" 2>/dev/null | tail -1)
    log_info "数据库 ${DB_NAME} 包含 ${final_count} 张表"
    
    if [[ "$final_count" -lt 8 ]]; then
        log_warn "表数量少于预期（8 张），数据可能不完整"
    else
        log_success "数据库表验证通过"
    fi
}

#=============================
# 阶段 5: 配置系统
#=============================
phase5_configuration() {
    log_step "阶段 5/6: 系统配置"
    
    local wwwroot="${WEB_ROOT}/wwwroot"
    
    #--- 5.1 修改数据库配置 ---
    log_info "配置数据库连接..."
    local db_config="${wwwroot}/configs/database.php"
    if [[ -f "$db_config" ]]; then
        cp "$db_config" "${db_config}.bak"
        
        sed -i "s/'hostname' => 'mysql'/'hostname' => '${DB_HOST}'/" "$db_config"
        sed -i "s/'hostname' => 'localhost'/'hostname' => '${DB_HOST}'/" "$db_config"
        sed -i "s/'database' => 'fantan_db'/'database' => '${DB_NAME}'/" "$db_config"
        sed -i "s/'username' => 'root'/'username' => '${DB_USER}'/" "$db_config"
        sed -i "s/'password' => 'root'/'password' => '${DB_PASS}'/" "$db_config"
        sed -i "s/'charset' => 'utf8'/'charset' => 'utf8mb4'/" "$db_config"
        sed -i "s/'type' => 'mysql'/'type' => 'mysqli'/" "$db_config"
        sed -i "s/'debug' => true/'debug' => false/" "$db_config"
        
        log_success "数据库配置已更新"
    else
        log_error "数据库配置文件不存在: ${db_config}"
    fi
    
    #--- 5.2 修改系统配置 ---
    log_info "配置系统参数..."
    local sys_config="${wwwroot}/configs/system.php"
    if [[ -f "$sys_config" ]]; then
        cp "$sys_config" "${sys_config}.bak"
        
        local new_auth_key=$(openssl rand -hex 16 2>/dev/null || cat /dev/urandom | tr -dc 'a-f0-9' | head -c 32)
        
        sed -i "s/'auth_key' => '[^']*'/'auth_key' => '${new_auth_key}'/" "$sys_config"
        sed -i "s/'debug' => 1/'debug' => 0/" "$sys_config"
        sed -i "s/'errorlog' => 0/'errorlog' => 1/" "$sys_config"
        sed -i "s/'tpl_referesh' => 1/'tpl_referesh' => 0/" "$sys_config"
        
        log_success "系统配置已更新 (auth_key=${new_auth_key})"
    fi
    
    #--- 5.3 配置 PHP INI ---
    log_info "配置 PHP INI..."
    
    local php_ini=""
    for ini_path in \
        "/etc/php/${PHP_VERSION}/fpm/php.ini" \
        "/etc/php/${PHP_VERSION}/apache2/php.ini" \
        "/etc/php.ini" \
        "/etc/opt/remi/php${PHP_VERSION//./}/php.ini"; do
        if [[ -f "$ini_path" ]]; then
            php_ini="$ini_path"
            break
        fi
    done
    
    if [[ -n "$php_ini" ]]; then
        cp "$php_ini" "${php_ini}.bak"
        
        sed -i 's/upload_max_filesize = .*/upload_max_filesize = 10M/' "$php_ini" 2>/dev/null || true
        sed -i 's/post_max_size = .*/post_max_size = 20M/' "$php_ini" 2>/dev/null || true
        sed -i 's/;date.timezone =.*/date.timezone = Asia\/Shanghai/' "$php_ini" 2>/dev/null || true
        sed -i 's/;short_open_tag = .*/short_open_tag = On/' "$php_ini" 2>/dev/null || true
        sed -i 's/short_open_tag = Off/short_open_tag = On/' "$php_ini" 2>/dev/null || true
        sed -i 's/display_errors = On/display_errors = Off/' "$php_ini" 2>/dev/null || true
        sed -i 's/display_startup_errors = On/display_startup_errors = Off/' "$php_ini" 2>/dev/null || true
        
        if ! grep -q "^short_open_tag" "$php_ini" 2>/dev/null; then
            echo "short_open_tag = On" >> "$php_ini"
        fi
        if ! grep -q "^date.timezone" "$php_ini" 2>/dev/null; then
            echo "date.timezone = Asia/Shanghai" >> "$php_ini"
        fi
        
        log_success "PHP INI 配置已更新: ${php_ini}"
    else
        log_warn "未找到 php.ini，创建自定义配置..."
        local conf_dir="/etc/php/${PHP_VERSION}/fpm/conf.d"
        mkdir -p "$conf_dir" 2>/dev/null || true
        if [[ -d "$conf_dir" ]]; then
            cat > "$conf_dir/99-yunwei.ini" << 'PHPEOF'
upload_max_filesize = 10M
post_max_size = 20M
date.timezone = Asia/Shanghai
short_open_tag = On
display_errors = Off
display_startup_errors = Off
error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE
log_errors = On
default_charset = "UTF-8"
PHPEOF
            log_success "PHP 自定义配置已创建: ${conf_dir}/99-yunwei.ini"
        fi
    fi
    
    #--- 5.4 配置 Nginx ---
    log_info "配置 Nginx 虚拟主机..."
    local nginx_conf=""
    
    case "$OS_ID" in
        ubuntu|debian)
            nginx_conf="/etc/nginx/sites-available/yunwei"
            mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
            ;;
        centos|rhel|rocky|almalinux)
            nginx_conf="/etc/nginx/conf.d/yunwei.conf"
            ;;
        *)
            nginx_conf="/etc/nginx/conf.d/yunwei.conf"
            ;;
    esac
    
    local fpm_sock=""
    fpm_sock=$(find /run /var/run -name "php*fpm*.sock" 2>/dev/null | head -1)
    if [[ -z "$fpm_sock" ]]; then
        if [[ -d "/run/php" ]]; then
            fpm_sock="/run/php/php${PHP_VERSION}-fpm.sock"
        else
            fpm_sock="/var/run/php/php${PHP_VERSION}-fpm.sock"
        fi
        log_warn "未找到 PHP-FPM socket，使用预期路径: ${fpm_sock}"
    fi
    log_info "PHP-FPM socket: ${fpm_sock}"
    
    cat > "$nginx_conf" << NGINX_EOF
server {
    listen 80;
    server_name ${DOMAIN};
    root ${wwwroot};
    index index.php index.html;

    charset utf-8;

    access_log /var/log/nginx/yunwei_access.log;
    error_log  /var/log/nginx/yunwei_error.log;

    location ~ ^/(source|caches|configs)/ {
        deny all;
    }

    location ~ ^/uppic/.*\\.php\$ {
        deny all;
    }

    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|mp3)\$ {
        expires 30d;
        access_log off;
    }

    location ~ \\.php\$ {
        fastcgi_pass unix:${fpm_sock};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param CHARSET utf-8;
        include fastcgi_params;
        fastcgi_read_timeout 120;
        fastcgi_send_timeout 120;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ /\\. {
        deny all;
    }
}
NGINX_EOF

    log_success "Nginx 配置已写入: ${nginx_conf}"
    
    if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
        local enabled_link="/etc/nginx/sites-enabled/yunwei"
        if [[ ! -L "$enabled_link" ]]; then
            ln -s "$nginx_conf" "$enabled_link"
        fi
        rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
    else
        mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled 2>/dev/null || true
    fi
    
    if nginx -t 2>&1; then
        log_success "Nginx 配置语法检查通过"
    else
        log_error "Nginx 配置语法错误！"
        nginx -t
        exit 1
    fi
    
    #--- 5.5 文件权限 ---
    log_info "设置文件权限..."
    
    local web_user="www-data"
    if [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "rocky" || "$OS_ID" == "almalinux" ]]; then
        web_user="nginx"
    fi
    
    mkdir -p "${wwwroot}/caches/caches_template/default"
    mkdir -p "${wwwroot}/caches/sessions"
    mkdir -p "${wwwroot}/uppic/user"
    mkdir -p "${wwwroot}/uppic/ewm"
    mkdir -p "${wwwroot}/uppic/banner"
    
    rm -rf "${wwwroot}/caches/caches_template/"*.php 2>/dev/null || true
    rm -rf "${wwwroot}/caches/"*.php 2>/dev/null || true
    mkdir -p "${wwwroot}/caches/caches_template/default"
    
    chown -R "${web_user}:${web_user}" "${wwwroot}"
    chmod -R 777 "${wwwroot}/caches"
    chmod -R 777 "${wwwroot}/uppic"
    chmod 666 "${wwwroot}/configs/setting.php" 2>/dev/null || true
    
    log_success "文件权限设置完成 (owner: ${web_user})"
}

#=============================
# 阶段 6: 启动服务 & 访问验证
#=============================
phase6_start_and_verify() {
    log_step "阶段 6/6: 启动服务 & 访问验证"
    
    log_info "启动 MySQL..."
    systemctl start mysql 2>/dev/null || systemctl start mariadb 2>/dev/null || true
    sleep 2
    if systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mariadb 2>/dev/null; then
        log_success "MySQL 运行中"
    else
        log_error "MySQL 启动失败"
    fi
    
    log_info "启动 PHP-FPM..."
    systemctl restart "php${PHP_VERSION}-fpm" 2>/dev/null || systemctl restart php-fpm 2>/dev/null || true
    sleep 1
    if systemctl is-active --quiet "php${PHP_VERSION}-fpm" 2>/dev/null || systemctl is-active --quiet php-fpm 2>/dev/null; then
        log_success "PHP-FPM 运行中"
    else
        log_warn "PHP-FPM 可能未正常启动..."
        systemctl restart "php${PHP_VERSION}-fpm" 2>/dev/null || systemctl restart php-fpm 2>/dev/null || true
        sleep 1
    fi
    
    log_info "启动 Nginx..."
    systemctl restart nginx 2>/dev/null || true
    sleep 1
    if systemctl is-active --quiet nginx; then
        log_success "Nginx 运行中"
    else
        log_error "Nginx 启动失败"
        nginx -t
        journalctl -u nginx --no-pager -n 20
        exit 1
    fi
    
    # 防火墙
    log_info "检查防火墙..."
    if command -v ufw &>/dev/null && ufw status 2>/dev/null | grep -q "active"; then
        ufw allow 80/tcp 2>/dev/null || true
        ufw allow 443/tcp 2>/dev/null || true
        log_success "UFW 已放行 80/443"
    elif command -v firewall-cmd &>/dev/null && firewall-cmd --state 2>/dev/null | grep -q "running"; then
        firewall-cmd --permanent --add-service=http 2>/dev/null || true
        firewall-cmd --permanent --add-service=https 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        log_success "firewalld 已放行 HTTP/HTTPS"
    else
        log_info "未检测到活跃的防火墙"
    fi
    
    # 访问验证
    echo ""
    separator
    log_info "开始访问验证..."
    separator
    
    local verify_url="http://localhost/"
    local verify_errors=0
    
    log_info "测试 1/4: HTTP 状态码..."
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${verify_url}" 2>/dev/null || echo "000")
    if [[ "$http_code" == "200" ]]; then
        log_success "HTTP 状态码: ${http_code} ✅"
    elif [[ "$http_code" == "302" || "$http_code" == "301" ]]; then
        log_warn "HTTP 状态码: ${http_code}（重定向）"
    else
        log_fail "HTTP 状态码: ${http_code} ❌"
        if [[ -f /var/log/nginx/yunwei_error.log ]]; then
            log_info "Nginx 错误日志:"
            tail -5 /var/log/nginx/yunwei_error.log
        fi
        ((verify_errors++))
    fi
    
    log_info "测试 2/4: 页面内容检查..."
    local page_content=$(curl -s --max-time 10 "${verify_url}" 2>/dev/null || echo "")
    if [[ -n "$page_content" ]] && echo "$page_content" | grep -qi "html"; then
        log_success "页面内容包含 HTML 标签 ✅"
    else
        log_fail "页面内容异常 ❌"
        ((verify_errors++))
    fi
    
    log_info "测试 3/4: 数据库连接验证..."
    local db_check=$(mysql -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" -e \
        "SELECT COUNT(*) FROM ${DB_NAME}.bc_game;" 2>/dev/null | tail -1)
    if [[ -n "$db_check" ]] && [[ "$db_check" -gt 0 ]]; then
        log_success "数据库连接正常 ✅"
    else
        log_fail "数据库连接或数据异常 ❌"
        ((verify_errors++))
    fi
    
    log_info "测试 4/4: PHP 扩展验证..."
    local php_bin="php"
    if command -v "php${PHP_VERSION}" &>/dev/null; then
        php_bin="php${PHP_VERSION}"
    fi
    
    local ext_ok=true
    for ext in mysqli gd curl session mbstring; do
        if ! $php_bin -m 2>/dev/null | grep -qi "^${ext}$"; then
            log_fail "PHP 扩展 ${ext} 未加载 ❌"
            ext_ok=false
        fi
    done
    if [[ "$ext_ok" == true ]]; then
        log_success "核心 PHP 扩展已加载 ✅"
    else
        ((verify_errors++))
    fi
    
    echo ""
    separator
    
    if [[ $verify_errors -eq 0 ]]; then
        log_success "🎉 所有验证通过！系统部署成功！"
    else
        log_warn "验证发现 ${verify_errors} 个问题，请检查上方日志"
        log_info "排查命令:"
        log_info "  tail -50 /var/log/nginx/yunwei_error.log"
        log_info "  systemctl status php${PHP_VERSION}-fpm"
        log_info "  ls -la /run/php/"
        log_info "  systemctl status mysql"
    fi
    
    echo ""
    separator
    echo -e "${BOLD}部署信息汇总${NC}"
    separator
    echo -e "  项目目录:   ${CYAN}${WEB_ROOT}${NC}"
    echo -e "  Web 根目录: ${CYAN}${WEB_ROOT}/wwwroot${NC}"
    echo -e "  数据库:     ${CYAN}${DB_NAME} (${DB_USER}@${DB_HOST})${NC}"
    echo -e "  域名:       ${CYAN}${DOMAIN}${NC}"
    echo -e "  PHP 版本:   ${CYAN}${PHP_VERSION}${NC}"
    echo ""
    echo -e "${BOLD}访问地址${NC}"
    separator
    echo -e "  前台首页:   ${CYAN}http://${DOMAIN}/${NC}"
    echo -e "  英文版:     ${CYAN}http://${DOMAIN}/?lang=en-us${NC}"
    echo -e "  缅甸语版:   ${CYAN}http://${DOMAIN}/?lang=my-mm${NC}"
    echo -e "  后台管理:   ${CYAN}http://${DOMAIN}/admin.php${NC}"
    echo -e "  代理管理:   ${CYAN}http://${DOMAIN}/daili.php${NC}"
    echo -e "  开奖监控:   ${CYAN}http://${DOMAIN}/service.php${NC}"
    echo ""
    echo -e "${BOLD}⚠️  安全提醒${NC}"
    separator
    echo -e "  ${YELLOW}1. 请尽快修改后台管理员密码（默认账号: admin）${NC}"
    echo -e "  ${YELLOW}2. 建议启用 HTTPS (配置 SSL 证书)${NC}"
    echo ""
    echo -e "${BOLD}配置文件位置${NC}"
    separator
    echo -e "  数据库配置: ${WEB_ROOT}/wwwroot/configs/database.php"
    echo -e "  系统配置:   ${WEB_ROOT}/wwwroot/configs/system.php"
    echo -e "  Nginx 配置: $(ls /etc/nginx/sites-available/yunwei /etc/nginx/conf.d/yunwei.conf 2>/dev/null | head -1)"
    echo -e "  Nginx 日志: /var/log/nginx/yunwei_error.log"
    echo ""
    echo -e "${BOLD}常用命令${NC}"
    separator
    echo -e "  重启 Nginx:   systemctl restart nginx"
    echo -e "  重启 PHP-FPM: systemctl restart php${PHP_VERSION}-fpm"
    echo -e "  重启 MySQL:   systemctl restart mysql"
    echo -e "  清除模板缓存: rm -rf ${WEB_ROOT}/wwwroot/caches/caches_template/*"
    echo ""
}

#=============================
# 确认提示
#=============================
confirm_deploy() {
    echo ""
    separator
    echo -e "${BOLD}部署参数确认${NC}"
    separator
    echo -e "  MySQL 主机:   ${CYAN}${DB_HOST}${NC}"
    echo -e "  MySQL 用户:   ${CYAN}${DB_USER}${NC}"
    echo -e "  MySQL 密码:   ${CYAN}${DB_PASS}${NC}"
    echo -e "  数据库名:     ${CYAN}${DB_NAME}${NC}"
    echo -e "  绑定域名:     ${CYAN}${DOMAIN}${NC}"
    echo -e "  安装目录:     ${CYAN}${WEB_ROOT}${NC}"
    echo -e "  PHP 版本:     ${CYAN}${PHP_VERSION}${NC}"
    separator
    
    if [[ "$SKIP_CONFIRM" != true ]]; then
        echo -en "\n${YELLOW}是否继续部署？[y/N]:${NC} "
        read -r answer
        if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
            log_info "部署已取消"
            exit 0
        fi
    fi
}

#=============================
# 主流程
#=============================
main() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     蚁彩（蚂蚁彩票）系统 一键部署脚本 v2.0          ║${NC}"
    echo -e "${CYAN}${BOLD}║     LEYUN360 PHP Framework + i18n                   ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    parse_args "$@"
    
    phase1_environment_check
    confirm_deploy
    phase2_install_dependencies
    phase3_deploy_code
    phase4_database
    phase5_configuration
    phase6_start_and_verify
    
    log_success "部署完成！"
}

main "$@"
