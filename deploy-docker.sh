#!/bin/bash
#=============================================================================
# 蚁彩（蚂蚁彩票）系统 Docker 一键部署脚本
# 版本: v2.2
# 日期: 2025-05-18
# 兼容: macOS / Linux / Windows (WSL/Git Bash)
# 用法:
#   bash deploy-docker.sh                                       # 交互式
#   bash deploy-docker.sh --db-pass root --domain ywcp.local -y # 非交互式
#   bash deploy-docker.sh --nginx-port 8080 --mysql-port 3307 -y # 自定义端口
#   bash deploy-docker.sh --check-only                          # 仅环境检查
#   bash deploy-docker.sh --help                                # 帮助
#=============================================================================

set -euo pipefail

#=============================
# 颜色定义
#=============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

#=============================
# 默认配置
#=============================
DB_HOST="mysql"
DB_USER="root"
DB_PASS="root"
DB_NAME="fantan_db"
DOMAIN="localhost"
NGINX_PORT=80
MYSQL_PORT=3306
SKIP_CONFIRM=false
CHECK_ONLY=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_CMD=""

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

# 检测端口是否被占用
port_in_use() {
    local port=$1
    if lsof -i :"$port" &>/dev/null 2>&1; then
        return 0  # 端口被占用
    elif ss -tlnp 2>/dev/null | grep -q ":${port} " 2>/dev/null; then
        return 0
    elif netstat -an 2>/dev/null | grep -q "\.${port}.*LISTEN" 2>/dev/null; then
        return 0
    fi
    return 1  # 端口可用
}

# 寻找可用端口
find_available_port() {
    local start_port=$1
    local port=$start_port
    while [[ $port -lt $((start_port + 100)) ]]; do
        if ! port_in_use "$port"; then
            echo "$port"
            return 0
        fi
        port=$((port + 1))
    done
    echo ""
    return 1
}

#=============================
# 参数解析
#=============================
show_help() {
    cat << 'EOF'
蚁彩（蚂蚁彩票）系统 Docker 一键部署脚本 v2.0

用法: bash deploy-docker.sh [选项]

选项:
  --db-host HOST       MySQL 主机地址         (默认: mysql，Docker 内部)
  --db-user USER       MySQL 用户名           (默认: root)
  --db-pass PASS       MySQL 密码             (默认: root)
  --db-name NAME       数据库名               (默认: fantan_db)
  --domain DOMAIN      绑定域名               (默认: localhost)
  --nginx-port PORT    Nginx 端口             (默认: 80，若被占用自动+1)
  --mysql-port PORT    MySQL 映射端口         (默认: 3306，若被占用自动+1)
  -y                   跳过确认，自动继续
  --check-only         仅执行环境检查，不部署
  --help               显示帮助信息

示例:
  # 交互式部署
  bash deploy-docker.sh

  # 指定参数部署（macOS/Linux 通用）
  bash deploy-docker.sh --db-pass root --domain ywcp.cocos2026.local -y

  # 自定义端口（端口80/3306被占用时）
  bash deploy-docker.sh --nginx-port 8080 --mysql-port 3307 -y

  # 仅检查环境
  bash deploy-docker.sh --check-only
EOF
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --db-host)     DB_HOST="$2"; shift 2 ;;
            --db-user)     DB_USER="$2"; shift 2 ;;
            --db-pass)     DB_PASS="$2"; shift 2 ;;
            --db-name)     DB_NAME="$2"; shift 2 ;;
            --domain)      DOMAIN="$2"; shift 2 ;;
            --nginx-port)  NGINX_PORT="$2"; shift 2 ;;
            --mysql-port)  MYSQL_PORT="$2"; shift 2 ;;
            -y)            SKIP_CONFIRM=true; shift ;;
            --check-only)  CHECK_ONLY=true; shift ;;
            --help|-h)     show_help ;;
            *)             log_error "未知参数: $1"; show_help ;;
        esac
    done
}

#=============================
# 阶段 1: 环境检查
#=============================
PHASE1_ERRORS=0
PHASE1_WARNINGS=0

check_docker() {
    if command -v docker &>/dev/null; then
        local ver
        ver=$(docker --version 2>/dev/null)
        log_success "Docker 已安装: ${ver}"

        # 检查 Docker 是否运行
        if docker info &>/dev/null 2>&1; then
            log_success "Docker 守护进程运行中"
        else
            log_error "Docker 守护进程未运行！请先启动 Docker"
            log_info  "  macOS: 打开 Docker Desktop 应用"
            log_info  "  Linux: sudo systemctl start docker"
            ((PHASE1_ERRORS++))
        fi
    else
        log_error "Docker 未安装！"
        log_info  "  macOS 安装: https://docs.docker.com/desktop/install/mac-install/"
        log_info  "  Linux 安装: curl -fsSL https://get.docker.com | sh"
        log_info  "  Windows 安装: https://docs.docker.com/desktop/install/windows-install/"
        ((PHASE1_ERRORS++))
    fi
}

check_docker_compose() {
    # 检查 docker compose (V2) 或 docker-compose (V1)
    if docker compose version &>/dev/null 2>&1; then
        local ver
        ver=$(docker compose version 2>/dev/null)
        log_success "Docker Compose V2: ${ver}"
        COMPOSE_CMD="docker compose"
    elif command -v docker-compose &>/dev/null 2>&1; then
        local ver
        ver=$(docker-compose --version 2>/dev/null)
        log_success "Docker Compose V1: ${ver}"
        COMPOSE_CMD="docker-compose"
    else
        log_error "Docker Compose 未安装！"
        log_info  "  Docker Compose 通常随 Docker Desktop 一起安装"
        ((PHASE1_ERRORS++))
    fi
}

check_ports() {
    # 检查 Nginx 端口
    if port_in_use "${NGINX_PORT}"; then
        log_warn "端口 ${NGINX_PORT} 已被占用（本地 Nginx/HTTP 服务）"
        local new_port
        new_port=$(find_available_port $((NGINX_PORT + 1)))
        if [[ -n "$new_port" ]]; then
            log_info  "  自动切换 Nginx 端口 → ${new_port}"
            NGINX_PORT=$new_port
        else
            log_error "  无法找到可用端口，请手动指定: --nginx-port <端口>"
            ((PHASE1_ERRORS++))
        fi
    else
        log_success "端口 ${NGINX_PORT}: 可用 (Nginx)"
    fi

    # 检查 MySQL 端口
    if port_in_use "${MYSQL_PORT}"; then
        log_warn "端口 ${MYSQL_PORT} 已被占用（本地 MySQL 服务）"
        local new_port
        new_port=$(find_available_port $((MYSQL_PORT + 1)))
        if [[ -n "$new_port" ]]; then
            log_info  "  自动切换 MySQL 端口 → ${new_port}"
            MYSQL_PORT=$new_port
        else
            log_error "  无法找到可用端口，请手动指定: --mysql-port <端口>"
            ((PHASE1_ERRORS++))
        fi
    else
        log_success "端口 ${MYSQL_PORT}: 可用 (MySQL)"
    fi
}

check_disk_space() {
    local avail
    # 跨平台磁盘空间检查
    if command -v df &>/dev/null; then
        avail=$(df -g "${SCRIPT_DIR}" 2>/dev/null | awk 'NR==2{print $4}' || df -h "${SCRIPT_DIR}" 2>/dev/null | awk 'NR==2{print $4}')
        log_info "可用磁盘空间: ${avail:-?}GB"
    fi
}

check_sql_file() {
    local sql_file="${SCRIPT_DIR}/sql/fantan_db.sql"
    if [[ -f "$sql_file" ]]; then
        local size
        size=$(ls -lh "$sql_file" | awk '{print $5}')
        log_success "SQL 文件存在: ${sql_file} (${size})"
    else
        log_warn "SQL 文件不存在: ${sql_file}，数据库将不会被初始化"
        ((PHASE1_WARNINGS++))
    fi
}

check_source_code() {
    local index_file="${SCRIPT_DIR}/wwwroot/index.php"
    if [[ -f "$index_file" ]]; then
        log_success "项目代码存在: ${SCRIPT_DIR}"
    else
        log_warn "项目代码不完整: 未找到 wwwroot/index.php"
        ((PHASE1_WARNINGS++))
    fi
}

check_docker_files() {
    local compose_file="${SCRIPT_DIR}/docker/docker-compose.yml"
    local dockerfile="${SCRIPT_DIR}/docker/php/Dockerfile"
    local nginx_conf="${SCRIPT_DIR}/docker/nginx/default.conf"

    if [[ -f "$compose_file" ]]; then
        log_success "docker-compose.yml 存在"
    else
        log_error "docker-compose.yml 不存在: ${compose_file}"
        ((PHASE1_ERRORS++))
    fi

    if [[ -f "$dockerfile" ]]; then
        log_success "PHP Dockerfile 存在"
    else
        log_error "PHP Dockerfile 不存在: ${dockerfile}"
        ((PHASE1_ERRORS++))
    fi

    if [[ -f "$nginx_conf" ]]; then
        log_success "Nginx 配置存在"
    else
        log_error "Nginx 配置不存在: ${nginx_conf}"
        ((PHASE1_ERRORS++))
    fi
}

phase1_environment_check() {
    log_step "阶段 1/6: 环境检查"

    check_docker
    check_docker_compose
    check_ports
    check_disk_space
    check_sql_file
    check_source_code
    check_docker_files

    separator
    if [[ $PHASE1_ERRORS -gt 0 ]]; then
        log_error "环境检查发现 ${PHASE1_ERRORS} 个严重问题，${PHASE1_WARNINGS} 个警告"
        log_error "请先解决严重问题后再继续"
        exit 1
    elif [[ $PHASE1_WARNINGS -gt 0 ]]; then
        log_warn "环境检查发现 ${PHASE1_WARNINGS} 个警告"
    else
        log_success "环境检查全部通过！"
    fi

    if [[ "$CHECK_ONLY" == true ]]; then
        log_info "--check-only 模式，退出"
        exit 0
    fi
}

#=============================
# 阶段 2: 配置生成
#=============================
phase2_generate_config() {
    log_step "阶段 2/6: 配置生成"

    # 生成 .env 文件
    local env_file="${SCRIPT_DIR}/docker/.env"
    mkdir -p "${SCRIPT_DIR}/docker"
    cat > "$env_file" << ENVFILE
# 蚁彩系统 Docker 环境配置
# 由 deploy-docker.sh v2.0 自动生成
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

# MySQL 配置
MYSQL_ROOT_PASSWORD=${DB_PASS}
MYSQL_DATABASE=${DB_NAME}

# 端口映射
NGINX_PORT=${NGINX_PORT}
MYSQL_PORT=${MYSQL_PORT}
ENVFILE

    log_success "Docker 环境配置已生成: ${env_file}"

    # 修改数据库配置文件
    local db_config="${SCRIPT_DIR}/wwwroot/configs/database.php"
    if [[ -f "$db_config" ]]; then
        # 备份原配置（仅首次）
        if [[ ! -f "${db_config}.bak" ]]; then
            cp "$db_config" "${db_config}.bak"
            log_info "已备份数据库配置: ${db_config}.bak"
        fi

        # 使用 sed 跨平台修改
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS sed
            sed -i '' "s/'hostname' => '.*'/'hostname' => 'mysql'/" "$db_config"
            sed -i '' "s/'database' => '.*'/'database' => '${DB_NAME}'/" "$db_config"
            sed -i '' "s/'username' => '.*'/'username' => '${DB_USER}'/" "$db_config"
            sed -i '' "s/'password' => '.*'/'password' => '${DB_PASS}'/" "$db_config"
            sed -i '' "s/'charset' => '.*'/'charset' => 'utf8mb4'/" "$db_config"
            sed -i '' "s/'debug' => true/'debug' => false/" "$db_config"
            sed -i '' "s/'type' => '.*'/'type' => 'mysqli'/" "$db_config"
        else
            # Linux sed
            sed -i "s/'hostname' => '.*'/'hostname' => 'mysql'/" "$db_config"
            sed -i "s/'database' => '.*'/'database' => '${DB_NAME}'/" "$db_config"
            sed -i "s/'username' => '.*'/'username' => '${DB_USER}'/" "$db_config"
            sed -i "s/'password' => '.*'/'password' => '${DB_PASS}'/" "$db_config"
            sed -i "s/'charset' => '.*'/'charset' => 'utf8mb4'/" "$db_config"
            sed -i "s/'debug' => true/'debug' => false/" "$db_config"
            sed -i "s/'type' => '.*'/'type' => 'mysqli'/" "$db_config"
        fi
        log_success "数据库配置已更新 (hostname=mysql, charset=utf8mb4, debug=false)"
    else
        log_warn "数据库配置文件不存在: ${db_config}"
    fi

    # 修改系统配置
    local sys_config="${SCRIPT_DIR}/wwwroot/configs/system.php"
    if [[ -f "$sys_config" ]]; then
        if [[ ! -f "${sys_config}.bak" ]]; then
            cp "$sys_config" "${sys_config}.bak"
            log_info "已备份系统配置: ${sys_config}.bak"
        fi

        # 仅当 auth_key 仍为默认值时才更换（避免重复部署破坏 cookie 加密）
        local default_auth_key="b83988e84d43c9a102e1da5a0cf55de9"
        local current_auth_key
        current_auth_key=$(grep "'auth_key'" "$sys_config" | sed "s/.*'auth_key' => '\([^']*\)'.*/\1/")
        if [[ "$current_auth_key" == "$default_auth_key" ]]; then
            local new_auth_key
            new_auth_key=$(openssl rand -hex 16 2>/dev/null || head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "s/'auth_key' => '.*'/'auth_key' => '${new_auth_key}'/" "$sys_config"
            else
                sed -i "s/'auth_key' => '.*'/'auth_key' => '${new_auth_key}'/" "$sys_config"
            fi
            log_success "系统配置已更新 (auth_key=${new_auth_key:0:8}...)"
        else
            log_info "auth_key 已为非默认值，保持不变（避免破坏 cookie 加密）"
        fi

        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' "s/'tpl_referesh' => 1/'tpl_referesh' => 0/" "$sys_config"
        else
            sed -i "s/'tpl_referesh' => 1/'tpl_referesh' => 0/" "$sys_config"
        fi
    fi
}

#=============================
# 阶段 3: 构建并启动容器
#=============================

# 检查 Docker 镜像加速器配置
check_docker_mirror() {
    log_info "检查 Docker 镜像加速器配置..."

    # 检查是否已配置镜像加速器
    local mirror_configured=false
    local docker_daemon_json=""

    # macOS: Docker Desktop 配置路径
    if [[ "$(uname)" == "Darwin" ]]; then
        # Docker Desktop for Mac 使用 settings.json
        if [[ -f "$HOME/.docker/daemon.json" ]]; then
            docker_daemon_json=$(cat "$HOME/.docker/daemon.json" 2>/dev/null)
        fi
    else
        # Linux: /etc/docker/daemon.json
        if [[ -f "/etc/docker/daemon.json" ]]; then
            docker_daemon_json=$(cat /etc/docker/daemon.json 2>/dev/null)
        fi
    fi

    if echo "$docker_daemon_json" | grep -q "registry-mirrors" 2>/dev/null; then
        mirror_configured=true
        log_success "Docker 镜像加速器已配置"
    fi

    # 尝试测试拉取
    if [[ "$mirror_configured" != true ]]; then
        log_warn "未检测到 Docker 镜像加速器配置"
        log_info "国内网络环境下，拉取 Docker Hub 镜像可能会失败"
        log_info ""
        log_info "如拉取失败，请配置 Docker 镜像加速器："
        log_info "  macOS: Docker Desktop → Settings → Docker Engine → 添加："
        log_info '  { "registry-mirrors": ["https://docker.1ms.run", "https://docker.xuanyuan.me"] }'
        log_info "  Linux: 编辑 /etc/docker/daemon.json 添加相同配置，然后："
        log_info "  sudo systemctl restart docker"
        log_info ""
    fi
}

phase3_build_and_start() {
    log_step "阶段 3/6: 构建并启动 Docker 容器"

    local docker_dir="${SCRIPT_DIR}/docker"

    # 验证 docker-compose.yml 存在
    if [[ ! -f "${docker_dir}/docker-compose.yml" ]]; then
        log_error "docker-compose.yml 不存在: ${docker_dir}/docker-compose.yml"
        log_info "请确认项目文件完整"
        exit 1
    fi

    # 验证 PHP Dockerfile 存在
    if [[ ! -f "${docker_dir}/php/Dockerfile" ]]; then
        log_error "PHP Dockerfile 不存在: ${docker_dir}/php/Dockerfile"
        log_info "请确认项目文件完整"
        exit 1
    fi

    # 检查 Docker 镜像加速器配置（国内网络必需）
    check_docker_mirror

    # 停止旧容器（如存在）
    log_info "停止旧容器（如存在）..."
    cd "$docker_dir"
    $COMPOSE_CMD --env-file .env down 2>/dev/null || true

    # 预拉取基础镜像（提供更友好的错误提示）
    log_info "预拉取 PHP 7.4-FPM 基础镜像..."
    if ! docker pull php:7.4-fpm 2>&1; then
        log_error "拉取 php:7.4-fpm 镜像失败！"
        log_info ""
        log_info "这通常是网络问题（国内无法直接访问 Docker Hub），解决方案："
        log_info ""
        log_info "方案1: 配置 Docker 镜像加速器（推荐）"
        log_info "  macOS: Docker Desktop → Settings → Docker Engine → 添加以下配置:"
        log_info '  { "registry-mirrors": ["https://docker.1ms.run", "https://docker.xuanyuan.me"] }'
        log_info "  然后点击 Apply & Restart"
        log_info ""
        log_info "方案2: 手动拉取镜像后再部署"
        log_info "  docker pull docker.1ms.run/library/php:7.4-fpm"
        log_info "  docker tag docker.1ms.run/library/php:7.4-fpm php:7.4-fpm"
        log_info ""
        log_info "方案3: 使用代理"
        log_info "  export HTTP_PROXY=http://your-proxy:port"
        log_info "  export HTTPS_PROXY=http://your-proxy:port"
        log_info ""
        exit 1
    fi

    # 预拉取其他镜像
    log_info "预拉取 Nginx 和 MySQL 镜像..."
    docker pull nginx:alpine 2>&1 | tail -1 || true
    docker pull mysql:8.0 2>&1 | tail -1 || true

    # 构建 PHP 镜像（--no-cache 确保包含最新的cron配置）
    log_info "构建 PHP 7.4-FPM 镜像（首次可能需要几分钟）..."
    $COMPOSE_CMD --env-file .env build --no-cache php 2>&1 | tail -10

    # 检查构建结果
    if [[ ${PIPESTATUS[0]} -ne 0 ]] 2>/dev/null; then
        log_error "PHP 镜像构建失败！"
        log_info "查看完整日志: cd ${docker_dir} && ${COMPOSE_CMD} build php"
        exit 1
    fi
    log_success "PHP 镜像构建完成"

    # 启动所有容器
    log_info "启动容器..."
    $COMPOSE_CMD --env-file .env up -d 2>&1 | tail -10

    # 等待 MySQL 启动
    log_info "等待 MySQL 启动就绪..."
    local max_wait=90
    local waited=0
    while [[ $waited -lt $max_wait ]]; do
        if docker exec yunwei_mysql mysqladmin ping -h localhost -u"${DB_USER}" -p"${DB_PASS}" --silent 2>/dev/null; then
            log_success "MySQL 已就绪 (${waited}s)"
            break
        fi
        sleep 2
        waited=$((waited + 2))
        echo -ne "  等待中... ${waited}s\r"
    done

    if [[ $waited -ge $max_wait ]]; then
        log_warn "MySQL 启动超时，但容器可能仍在初始化中"
        log_info "可手动检查: docker logs yunwei_mysql"
    fi

    # 检查容器状态
    log_info "检查容器运行状态..."
    $COMPOSE_CMD --env-file .env ps

    # 检查各容器
    local all_running=true
    for container in yunwei_nginx yunwei_php yunwei_mysql; do
        if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            log_success "${container} 运行中"
        else
            log_fail "${container} 未运行"
            all_running=false
        fi
    done

    if [[ "$all_running" != true ]]; then
        log_error "部分容器未正常启动，查看日志："
        log_info  "  cd ${docker_dir} && ${COMPOSE_CMD} logs"
        # 输出最近日志帮助排查
        log_info "--- 最近容器日志 ---"
        $COMPOSE_CMD --env-file .env logs --tail=20 2>&1 | tail -30
        exit 1
    fi
}

#=============================
# 阶段 4: 数据库初始化
#=============================
phase4_database_init() {
    log_step "阶段 4/6: 数据库初始化"

    # 给 MySQL 额外等待时间确保完全就绪
    log_info "等待 MySQL 完全就绪..."
    sleep 5

    # 检查数据库是否已由 docker-entrypoint-initdb.d 自动导入
    log_info "检查数据库初始化状态..."

    local table_count
    table_count=$(docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -e \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}';" 2>/dev/null | tail -1)

    if [[ -n "$table_count" ]] && [[ "$table_count" -gt 0 ]]; then
        log_success "数据库已自动初始化（${table_count} 张表）"
    else
        # 手动导入
        log_info "数据库未自动初始化，手动导入 SQL..."
        local sql_file="${SCRIPT_DIR}/sql/fantan_db.sql"
        if [[ -f "$sql_file" ]]; then
            docker exec -i yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" --default-character-set=utf8mb4 "${DB_NAME}" < "$sql_file" 2>/dev/null
            log_success "SQL 导入完成"
        else
            log_error "SQL 文件不存在: ${sql_file}"
            log_info  "请手动导入数据库"
        fi
    fi

    # 验证关键表
    local game_count
    game_count=$(docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -e \
        "SELECT COUNT(*) FROM ${DB_NAME}.bc_game;" 2>/dev/null | tail -1)

    if [[ -n "$game_count" ]] && [[ "$game_count" -gt 0 ]]; then
        log_success "bc_game 表有 ${game_count} 条游戏配置记录"
    else
        log_warn "bc_game 表为空，游戏数据可能不完整"
    fi

    # 转换数据库表字符集 utf8 → utf8mb4（支持中文/缅甸语/emoji）
    log_info "转换数据库字符集 utf8 → utf8mb4..."
    docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -e \
        "ALTER DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

    # 获取所有表并转换
    local tables
    tables=$(docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -N -e \
        "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='${DB_NAME}' AND TABLE_TYPE='BASE TABLE';" 2>/dev/null)

    local convert_count=0
    for table in $tables; do
        docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -e \
            "ALTER TABLE ${DB_NAME}.\`${table}\` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            convert_count=$((convert_count + 1))
        else
            log_warn "  表 ${table} 转换失败（可能含索引长度超限，尝试仅改默认字符集）"
            docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -e \
                "ALTER TABLE ${DB_NAME}.\`${table}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
        fi
    done

    if [[ $convert_count -gt 0 ]]; then
        log_success "已转换 ${convert_count} 张表的字符集为 utf8mb4"
    else
        log_warn "未转换任何表，可能已是 utf8mb4 或表为空"
    fi
}

#=============================
# 阶段 5: 设置权限 & 配置 hosts
#=============================
phase5_permissions_and_hosts() {
    log_step "阶段 5/6: 权限设置 & Hosts 配置"

    # 设置文件权限
    log_info "设置文件权限..."
    # 清除模板缓存（避免旧缓存导致乱码）
    docker exec yunwei_php rm -rf /var/www/html/wwwroot/caches/caches_template 2>/dev/null || true
    docker exec yunwei_php rm -rf /var/www/html/wwwroot/caches/*.php 2>/dev/null || true
    log_info "已清除模板缓存"
    docker exec yunwei_php chmod -R 777 /var/www/html/wwwroot/caches 2>/dev/null || true
    docker exec yunwei_php bash -c "echo > /var/www/html/wwwroot/caches/cron.log" 2>/dev/null || true
    log_info "已清空旧的cron日志"
    docker exec yunwei_php chmod -R 777 /var/www/html/wwwroot/uppic 2>/dev/null || true
    docker exec yunwei_php chmod 666 /var/www/html/wwwroot/configs/setting.php 2>/dev/null || true
    log_success "文件权限设置完成"

    # 配置 hosts（如果使用了自定义域名）
    if [[ "$DOMAIN" != "localhost" ]]; then
        local hosts_entry="127.0.0.1 ${DOMAIN}"

        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS
            if grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
                log_info "hosts 文件已包含 ${DOMAIN}"
            else
                log_info "添加 ${DOMAIN} 到 /etc/hosts（需要 sudo 权限）..."
                echo "$hosts_entry" | sudo tee -a /etc/hosts > /dev/null 2>/dev/null
                if [[ $? -eq 0 ]]; then
                    log_success "hosts 文件已更新: ${hosts_entry}"
                else
                    log_warn "无法自动修改 /etc/hosts，请手动添加:"
                    log_info  "  sudo sh -c 'echo \"${hosts_entry}\" >> /etc/hosts'"
                fi
            fi
        else
            # Linux
            if grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
                log_info "hosts 文件已包含 ${DOMAIN}"
            else
                echo "$hosts_entry" >> /etc/hosts 2>/dev/null
                if [[ $? -eq 0 ]]; then
                    log_success "hosts 文件已更新: ${hosts_entry}"
                else
                    log_warn "无法自动修改 /etc/hosts，请手动添加:"
                    log_info  "  echo '${hosts_entry}' | sudo tee -a /etc/hosts"
                fi
            fi
        fi

        # macOS 刷新 DNS 缓存
        if [[ "$(uname)" == "Darwin" ]]; then
            log_info "刷新 macOS DNS 缓存..."
            sudo dscacheutil -flushcache 2>/dev/null || true
            sudo killall -HUP mDNSResponder 2>/dev/null || true
            log_success "DNS 缓存已刷新"
        fi
    fi
}

#=============================
# 阶段 6: 访问验证
#=============================
phase6_verify() {
    log_step "阶段 6/6: 访问验证"

    # 访问验证
    echo ""
    separator
    log_info "开始访问验证..."
    separator

    local verify_url
    if [[ "$DOMAIN" != "localhost" ]]; then
        verify_url="http://${DOMAIN}:${NGINX_PORT}/"
    else
        verify_url="http://localhost:${NGINX_PORT}/"
    fi

    local verify_errors=0

    # 测试 1: HTTP 状态码
    log_info "测试 1/6: HTTP 状态码..."
    local http_code
    http_code=$(curl -s -L -o /dev/null -w "%{http_code}" --max-time 10 "${verify_url}" 2>/dev/null || echo "000")
    if [[ "$http_code" == "200" ]]; then
        log_success "HTTP 状态码: ${http_code}"
    elif [[ "$http_code" == "302" || "$http_code" == "301" ]]; then
        log_warn "HTTP 状态码: ${http_code}（重定向，可能正常）"
    else
        log_fail "HTTP 状态码: ${http_code}"
        verify_errors=$((verify_errors + 1))
        # 显示可能的错误信息
        log_info "尝试获取页面内容..."
        curl -s -L --max-time 10 "${verify_url}" 2>/dev/null | head -5
    fi

    # 测试 2: 页面内容
    log_info "测试 2/6: 页面内容检查..."
    local page_content
    page_content=$(curl -s -L --max-time 10 "${verify_url}" 2>/dev/null || echo "")
    if [[ -n "$page_content" ]] && echo "$page_content" | grep -qi "html"; then
        log_success "页面内容包含 HTML 标签"
    else
        log_fail "页面内容异常"
        verify_errors=$((verify_errors + 1))
    fi

    # 测试 3: 数据库连接（从 MySQL 容器内部验证）
    log_info "测试 3a/6: MySQL 服务验证..."
    local db_check
    db_check=$(docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -e \
        "SELECT COUNT(*) FROM ${DB_NAME}.bc_game;" 2>/dev/null | tail -1)
    if [[ -n "$db_check" ]] && [[ "$db_check" -gt 0 ]]; then
        log_success "MySQL 服务正常 (bc_game: ${db_check} 条记录)"
    else
        log_fail "MySQL 服务异常"
        verify_errors=$((verify_errors + 1))
    fi

    # 测试 3b: PHP→MySQL 连接验证（关键！）
    log_info "测试 3b/6: PHP→MySQL 连接验证..."
    local php_db_check
    php_db_check=$(docker exec yunwei_php php -r "
        \$c = include '/var/www/html/wwwroot/configs/database.php';
        \$host = \$c['default']['hostname'];
        \$user = \$c['default']['username'];
        \$pass = \$c['default']['password'];
        \$db = \$c['default']['database'];
        \$m = new mysqli(\$host, \$user, \$pass, \$db);
        if (\$m->connect_error) { echo 'FAIL:' . \$m->connect_error; } else { echo 'OK:' . \$m->server_info; \$m->close(); }
    " 2>/dev/null || echo "FAIL:exec_error")
    if [[ "$php_db_check" == OK* ]]; then
        log_success "PHP→MySQL 连接成功 (${php_db_check#OK:})"
    else
        log_fail "PHP→MySQL 连接失败: ${php_db_check#FAIL:}"
        log_info "  请检查 wwwroot/configs/database.php 中 hostname 是否为 'mysql'"
        verify_errors=$((verify_errors + 1))
    fi

    # 测试 4: PHP 扩展
    log_info "测试 4/6: PHP 扩展验证..."
    local ext_ok=true
    for ext in mysqli gd curl json session mbstring bcmath; do
        local check
        check=$(docker exec yunwei_php php -m 2>/dev/null | grep -i "^${ext}$" || echo "")
        if [[ -n "$check" ]]; then
            log_info "  ${ext}: ✅"
        else
            log_fail "  ${ext}: 未加载"
            ext_ok=false
        fi
    done
    if [[ "$ext_ok" == true ]]; then
        log_success "所有必需 PHP 扩展已加载"
    else
        verify_errors=$((verify_errors + 1))
    fi

    # 测试 5: 语言系统验证（后端控制，非URL参数）
    log_info "测试 5/6: 语言系统验证（后端管理设置控制）..."
    # 检查 bc_settings 表中是否有 lang 行
    local lang_setting
    lang_setting=$(docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -N -e \
        "SELECT data FROM ${DB_NAME}.bc_settings WHERE name='lang';" 2>/dev/null || echo "")
    if [[ -n "$lang_setting" ]]; then
        log_success "语言设置已配置: ${lang_setting}（通过后台管理→基本设置切换语言）"
    else
        log_warn "bc_settings 表中未找到 lang 行，正在插入默认值..."
        docker exec yunwei_mysql mysql -u"${DB_USER}" -p"${DB_PASS}" -e \
            "INSERT IGNORE INTO ${DB_NAME}.bc_settings (name, data) VALUES ('lang', 'zh-cn');" 2>/dev/null || true
        log_success "已插入默认语言设置: zh-cn"
    fi

    # 测试 6: Cron计划任务
    log_info "测试 6/7: Cron计划任务验证..."
    # 检查Cron守护进程（使用临时变量避免set -euo pipefail下unbound variable问题）
    local cron_running=0
    cron_running=$(docker exec yunwei_php ps aux 2>/dev/null | grep -v grep | grep -c '[c]ron') || cron_running=0
    if [[ "${cron_running:-0}" -gt 0 ]] 2>/dev/null; then
        log_success "Cron守护进程运行中 (${cron_running} 个进程)"
    else
        log_warn "Cron守护进程未运行，尝试自动启动..."
        # 自动修复：尝试多种方式启动cron
        docker exec yunwei_php bash -c "rm -f /var/run/crond.pid /run/crond.pid 2>/dev/null; service cron start 2>/dev/null || /etc/init.d/cron start 2>/dev/null || cron 2>/dev/null" || true
        sleep 2
        # 再次检查
        cron_running=$(docker exec yunwei_php ps aux 2>/dev/null | grep -v grep | grep -c '[c]ron') || cron_running=0
        if [[ "${cron_running:-0}" -gt 0 ]] 2>/dev/null; then
            log_success "Cron守护进程已自动启动 (${cron_running} 个进程)"
        else
            log_fail "Cron守护进程自动启动失败！开奖采集和结算将不会自动执行"
            log_info "  手动修复: docker exec yunwei_php bash -c 'cron'"
            log_info "  或者:     docker restart yunwei_php"
            verify_errors=$((verify_errors + 1))
        fi
    fi
    # 检查crontab是否配置
    local crontab_content=0
    crontab_content=$(docker exec yunwei_php crontab -l 2>/dev/null | grep -c "cron_service" 2>/dev/null) || crontab_content=0
    if [[ "${crontab_content:-0}" -gt 0 ]] 2>/dev/null; then
        log_success "Crontab已配置 (${crontab_content} 条cron_service规则)"
    else
        log_warn "Crontab未配置，尝试自动设置..."
        # 自动修复：设置crontab
        docker exec yunwei_php bash -c "crontab /etc/cron.d/lottery 2>/dev/null && echo 'OK' || echo 'FAIL'" 2>/dev/null | tail -1 | grep -q "OK" && \
            log_success "Crontab已自动配置" || \
            { log_fail "Crontab自动配置失败！"; verify_errors=$((verify_errors + 1)); }
    fi
    # 检查cron日志
    local cron_log_size=0
    cron_log_size=$(docker exec yunwei_php wc -c /var/www/html/wwwroot/caches/cron.log 2>/dev/null | awk '{print $1}') || cron_log_size=0
    if [[ "${cron_log_size:-0}" -gt 0 ]] 2>/dev/null; then
        log_success "Cron日志已生成 (${cron_log_size} bytes)"
        # 显示最近2行
        docker exec yunwei_php tail -2 /var/www/html/wwwroot/caches/cron.log 2>/dev/null | while read line; do
            log_info "  $line"
        done || true
    else
        log_warn "Cron日志为空（可能刚启动，等待1分钟后再次检查）"
    fi

    # 测试 7: 诊断脚本
    log_info "测试 7/7: 诊断脚本检查..."
    local diag_url="${verify_url}diag.php"
    local diag_content
    diag_content=$(curl -s -L --max-time 10 "${diag_url}" 2>/dev/null || echo "")
    if [[ -n "$diag_content" ]] && echo "$diag_content" | grep -qi "诊断完成"; then
        log_success "诊断脚本可访问"
        log_info "  详细诊断: ${diag_url}"
    else
        log_warn "诊断脚本不可访问（不影响正常功能）"
    fi

    #--- 验证结果汇总 ---
    echo ""
    separator

    if [[ $verify_errors -eq 0 ]]; then
        log_success "🎉 所有验证通过！系统部署成功！"
    else
        log_warn "验证发现 ${verify_errors} 个问题，请检查上方日志"
    fi

    #--- 部署信息 ---
    echo ""
    separator
    echo -e "${BOLD}📦 Docker 部署信息${NC}"
    separator
    echo -e "  项目目录:    ${CYAN}${SCRIPT_DIR}${NC}"
    echo -e "  Docker 配置: ${CYAN}${SCRIPT_DIR}/docker/${NC}"
    echo -e "  数据库:      ${CYAN}${DB_NAME} (${DB_USER}@mysql容器)${NC}"
    echo -e "  MySQL 密码:  ${CYAN}${DB_PASS}${NC}"
    echo -e "  Nginx 端口:  ${CYAN}${NGINX_PORT}${NC}"
    echo -e "  MySQL 端口:  ${CYAN}${MYSQL_PORT}${NC}"
    echo -e "  绑定域名:    ${CYAN}${DOMAIN}${NC}"
    echo ""
    echo -e "${BOLD}🌐 访问地址${NC}"
    separator
    if [[ "$DOMAIN" != "localhost" ]]; then
        echo -e "  前台首页:    ${CYAN}http://${DOMAIN}:${NGINX_PORT}/${NC}"
        echo -e "  后台管理:    ${CYAN}http://${DOMAIN}:${NGINX_PORT}/admin.php${NC}"
        echo -e "  代理管理:    ${CYAN}http://${DOMAIN}:${NGINX_PORT}/daili.php${NC}"
        echo -e "  开奖监控:    ${CYAN}http://${DOMAIN}:${NGINX_PORT}/service.php${NC}"
    else
        echo -e "  前台首页:    ${CYAN}http://localhost:${NGINX_PORT}/${NC}"
        echo -e "  后台管理:    ${CYAN}http://localhost:${NGINX_PORT}/admin.php${NC}"
        echo -e "  代理管理:    ${CYAN}http://localhost:${NGINX_PORT}/daili.php${NC}"
        echo -e "  开奖监控:    ${CYAN}http://localhost:${NGINX_PORT}/service.php${NC}"
    fi
    echo ""
    echo -e "${BOLD}🌍 语言切换${NC}"
    separator
    echo -e "  ${YELLOW}语言由后台管理控制，前台自动生效${NC}"
    echo -e "  ${CYAN}后台管理 → 基本设置 → 网站语言${NC}"
    echo -e "  支持语言: 中文 (zh-cn) | English (en-us) | မြန်မာ (my-mm)"
    echo ""
    echo -e "${BOLD}🔧 Docker 管理命令${NC}"
    separator
    echo -e "  查看容器:    ${CYAN}cd ${SCRIPT_DIR}/docker && ${COMPOSE_CMD} ps${NC}"
    echo -e "  查看日志:    ${CYAN}cd ${SCRIPT_DIR}/docker && ${COMPOSE_CMD} logs -f${NC}"
    echo -e "  停止服务:    ${CYAN}cd ${SCRIPT_DIR}/docker && ${COMPOSE_CMD} down${NC}"
    echo -e "  重启服务:    ${CYAN}cd ${SCRIPT_DIR}/docker && ${COMPOSE_CMD} restart${NC}"
    echo -e "  进入PHP容器: ${CYAN}docker exec -it yunwei_php bash${NC}"
    echo -e "  进入MySQL:   ${CYAN}docker exec -it yunwei_mysql mysql -u${DB_USER} -p${DB_PASS}${NC}"
    echo -e "  重新部署:    ${CYAN}bash ${SCRIPT_DIR}/deploy-docker.sh --db-pass ${DB_PASS} --domain ${DOMAIN} --nginx-port ${NGINX_PORT} --mysql-port ${MYSQL_PORT} -y${NC}"
    echo ""
    echo -e "${BOLD}⚠️  安全提醒${NC}"
    separator
    echo -e "  ${YELLOW}1. 请尽快修改后台管理员密码（默认账号: admin）${NC}"
    echo -e "  ${YELLOW}2. 请配置开奖 API Token: wwwroot/api/game_service.php${NC}"
    echo -e "  ${YELLOW}3. MySQL root 密码当前为: ${DB_PASS}，生产环境请使用强密码${NC}"
    echo -e "  ${YELLOW}4. auth_key 已自动更新${NC}"
    echo -e "  ${YELLOW}5. 生产环境建议启用 HTTPS${NC}"
    echo ""
    echo -e "${BOLD}⚙️  计划任务 (Cron)${NC}"
    separator
    echo -e "  ${GREEN}✅ 开奖采集+结算已自动配置（每30秒执行）${NC}"
    echo -e "  Cron日志: ${CYAN}docker exec yunwei_php tail -f /var/www/html/wwwroot/caches/cron.log${NC}"
    echo -e "  手动执行: ${CYAN}docker exec yunwei_php php /var/www/html/wwwroot/cron_service.php${NC}"
    echo -e "  重启Cron: ${CYAN}docker exec yunwei_php service cron restart${NC}"
    echo -e "  PK10模式: ${CYAN}pk10_open_type=1(接口) / 2(本地自开奖)${NC}"
    echo -e "  切换模式: ${CYAN}修改 wwwroot/configs/system.php 中 pk10_open_type 后重启容器${NC}"
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
    echo -e "  MySQL 用户:   ${CYAN}${DB_USER}${NC}"
    echo -e "  MySQL 密码:   ${CYAN}${DB_PASS}${NC}"
    echo -e "  数据库名:     ${CYAN}${DB_NAME}${NC}"
    echo -e "  Nginx 端口:   ${CYAN}${NGINX_PORT}${NC}"
    echo -e "  MySQL 端口:   ${CYAN}${MYSQL_PORT}${NC}"
    echo -e "  项目目录:     ${CYAN}${SCRIPT_DIR}${NC}"
    echo -e "  绑定域名:     ${CYAN}${DOMAIN}${NC}"
    echo -e "  部署方式:     ${CYAN}Docker Compose (Nginx + PHP 7.4 FPM + MySQL 8.0)${NC}"
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
    echo -e "${CYAN}${BOLD}║   蚁彩（蚂蚁彩票）系统 Docker 一键部署脚本 v2.0      ║${NC}"
    echo -e "${CYAN}${BOLD}║   LEYUN360 PHP Framework + i18n (中/EN/မြန်မာ)        ║${NC}"
    echo -e "${CYAN}${BOLD}║   Docker: Nginx + PHP 7.4 FPM + MySQL 8.0            ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    parse_args "$@"

    # 阶段 1: 环境检查
    phase1_environment_check

    # 确认部署参数
    confirm_deploy

    # 阶段 2: 配置生成
    phase2_generate_config

    # 阶段 3: 构建并启动容器
    phase3_build_and_start

    # 阶段 4: 数据库初始化
    phase4_database_init

    # 阶段 5: 权限设置 & Hosts 配置
    phase5_permissions_and_hosts

    # 阶段 6: 访问验证
    phase6_verify

    log_success "Docker 部署完成！"
}

# 执行主流程
main "$@"
