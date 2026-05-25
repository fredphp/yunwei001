# 蚁彩（蚂蚁彩票）系统部署文档

> **版本**: v1.0  
> **最后更新**: 2025-05-18  
> **框架**: LEYUN360 自定义 PHP MVC 框架  
> **项目仓库**: https://github.com/fredphp/yunwei001.git

---

## 目录

1. [系统架构概览](#1-系统架构概览)
2. [环境要求](#2-环境要求)
3. [目录结构](#3-目录结构)
4. [代码逻辑深度分析](#4-代码逻辑深度分析)
5. [部署步骤](#5-部署步骤)
6. [Nginx 配置](#6-nginx-配置)
7. [安全加固](#7-安全加固)
8. [i18n 多语言系统说明](#8-i18n-多语言系统说明)
9. [常见问题排查](#9-常见问题排查)
10. [一键部署脚本使用说明](#10-一键部署脚本使用说明)

---

## 1. 系统架构概览

### 1.1 技术栈

| 组件 | 技术选型 | 版本要求 |
|------|---------|---------|
| Web 服务器 | Nginx + PHP-FPM | Nginx 1.14+, PHP 7.0-7.4 |
| PHP 运行时 | PHP-FPM | **7.0 ~ 7.4**（不兼容 PHP 8.0+） |
| 数据库 | MySQL | 5.5+ |
| 前端框架 | jQuery 1.8.1 + Layer 弹窗 | - |
| 表单验证 | Validform | - |
| 轮播组件 | TouchSlide | - |

### 1.2 MVC 路由机制

系统采用自定义 MVC 框架（LEYUN360），路由格式为：

```
http://domain/?m=模块&c=控制器&a=动作
```

**三大模块**：

| 模块 | 入口文件 | 说明 | 多语言 |
|------|---------|------|--------|
| `go` | `index.php` → `?m=go` | 前台（用户端） | ✅ 支持中/英/缅 |
| `admin` | `admin.php` → `?m=admin` | 后台管理 | ❌ 仅中文 |
| `daili` | `daili.php` → `?m=daili` | 代理管理 | ❌ 仅中文 |

**路由流程**：

```
用户请求 → index.php 
  → source/base.php (框架引导)
    → param.class.php (解析 m/c/a/lang)
      → application.class.php (MVC调度)
        → modules/{m}/{c}.php (控制器)
          → model/*.class.php (数据模型)
          → templates/default/*.html (视图模板)
```

### 1.3 默认路由

配置文件 `configs/route.php`：

```php
'default' => array('m'=>'go', 'c'=>'index', 'a'=>'init')
```

即访问根路径时，默认进入前台首页 `go` 模块 `index` 控制器 `init` 方法。

---

## 2. 环境要求

### 2.1 PHP 版本（关键）

| PHP 版本 | 兼容性 | 说明 |
|----------|--------|------|
| 5.4 - 5.6 | ⚠️ 可用 | mysql_* 驱动可用但已弃用 |
| **7.0 - 7.4** | ✅ **推荐** | mysqli 驱动正常，功能完整 |
| 8.0+ | ❌ **不兼容** | 多处 breaking changes |

**PHP 8.0+ 不兼容原因**：
1. `get_magic_quotes_gpc()` 函数在 PHP 8.0 被移除（`param.class.php:15`）
2. `mysql_*` 系列函数已移除（旧驱动 `mysql.class.php`）
3. `is_resource()` 对 mysqli 对象返回 false（PHP 8.1+）
4. 模板引擎使用 `/es` preg_replace 修饰符，PHP 8.0 已移除（`template_cache.class.php:83`）

### 2.2 必需 PHP 扩展

| 扩展 | 用途 | 优先级 |
|------|------|--------|
| **mysqli** | 数据库驱动（主力驱动） | 🔴 关键 |
| **gd** | 验证码生成、图片上传缩略图 | 🔴 关键 |
| **curl** | 开奖数据采集 API、外部请求 | 🔴 关键 |
| **json** | API 响应数据序列化 | 🔴 关键 |
| **session** | 用户会话管理 | 🔴 关键 |
| **mbstring** | 多字节字符串处理 | 🟡 高 |
| **bcmath** | 订单结算金额计算 `bcmul()` | 🟡 高 |
| **openssl** | HTTPS curl 请求 | 🟢 中 |
| **fileinfo** | 文件上传类型检测 | ⚪ 低 |

### 2.3 数据库

| 项目 | 要求 |
|------|------|
| MySQL 版本 | 5.5+ |
| 字符集 | utf8 |
| 存储引擎 | MyISAM（所有业务表）+ MEMORY（session 表） |
| 默认数据库名 | `fantan_db` |
| 表前缀 | `bc_` |

### 2.4 操作系统

- 推荐：Ubuntu 18.04/20.04 LTS 或 CentOS 7/8
- 需 root 或 sudo 权限执行部署

---

## 3. 目录结构

```
wwwroot/                              ← WEB 根目录（Nginx 指向此目录）
├── index.php                         ← 主入口（→ ?m=go）
├── admin.php                         ← 后台入口（→ ?m=admin）
├── daili.php                         ← 代理入口（→ ?m=daili）
├── api.php                           ← API 网关
├── service.php                       ← 开奖采集/结算监控页面
├── configs/                          ← 配置文件目录
│   ├── system.php                    ← 系统核心配置
│   ├── database.php                  ← 数据库连接配置
│   ├── route.php                     ← 路由配置
│   └── setting.php                   ← 站点设置（后台可修改）
├── source/                           ← 应用源代码
│   ├── base.php                      ← 框架引导文件
│   ├── libs/classes/                 ← 核心类库
│   │   ├── application.class.php     ← MVC 调度器
│   │   ├── param.class.php           ← URL/路由/语言解析
│   │   ├── db_factory.class.php      ← 数据库工厂
│   │   ├── mysqli.class.php          ← mysqli 驱动
│   │   ├── model.class.php           ← ORM 基类
│   │   ├── session_mysql.class.php   ← MySQL Session 处理器
│   │   ├── template_cache.class.php  ← 模板编译引擎
│   │   ├── upimg.class.php           ← 图片上传处理
│   │   └── checkcode.class.php       ← 验证码生成
│   ├── libs/functions/               ← 全局函数
│   │   └── global.func.php           ← L()翻译函数 + 工具函数
│   ├── model/                        ← 数据模型（每表一个）
│   ├── modules/                      ← MVC 模块
│   │   ├── go/                       ← 前台模块
│   │   ├── admin/                    ← 后台模块
│   │   └── daili/                    ← 代理模块
│   └── languages/                    ← 多语言包
│       ├── zh-cn/                    ← 中文（默认）
│       ├── en-us/                    ← 英文
│       └── my-mm/                    ← 缅甸语
├── templates/                        ← 前台模板
│   └── default/                      ← 默认模板方案
│       ├── header.html               ← 公共头部（含语言切换器）
│       ├── footer.html               ← 公共底部
│       ├── index.html                ← 首页
│       ├── game_chat.html            ← 番摊游戏大厅
│       └── ...                       ← 其他 29 个模板
├── api/                              ← API 端点
│   ├── game_service.php              ← 开奖采集 + 订单结算引擎
│   ├── get_haoma.php                 ← 开奖结果查询 API
│   ├── checkcode.php                 ← 验证码图片
│   └── curl_http.php                 ← CURL HTTP 客户端
├── statics/                          ← 前端静态资源
│   ├── css/, js/, images/
│   └── js/global.js                  ← 全局 JS（含 LANG 翻译变量）
├── games/                            ← 游戏动画资源
│   └── BJSC/                         ← 北京赛车动画
├── uppic/                            ← 用户上传目录 ⚠️ 需写权限
│   ├── user/                         ← 用户头像
│   ├── ewm/                          ← 二维码
│   └── banner/                       ← 轮播图
└── caches/                           ← 运行时缓存 ⚠️ 需写权限
    ├── sessions/                     ← Session 文件存储（备用）
    └── caches_template/              ← 编译后的模板 PHP

sql/                                  ← 数据库脚本
├── fantan_db.sql                     ← 完整建库 + 种子数据
└── 190928115002.psc                  ← Navicat 备份
```

---

## 4. 代码逻辑深度分析

### 4.1 启动流程

```
1. index.php
   ├── define('MYFILE_PATH', wwwroot/)    // 定义 webroot 路径
   └── include source/base.php            // 引入框架引导
   
2. source/base.php
   ├── define('IN_MYWEB', true)           // 入口安全标记
   ├── define('FILE_PATH', source/)       // 框架源码路径
   ├── define('CACHE_PATH', caches/)      // 缓存路径
   ├── define('CONFIG_PATH', configs/)    // 配置路径
   ├── define('SITE_PROTOCOL', http/https) // 协议检测
   ├── define('SITE_URL', $_SERVER['HTTP_HOST'])
   ├── base::load_sys_func('global')      // 加载全局函数
   ├── set_error_handler()                // 错误处理
   ├── date_default_timezone_set('Etc/GMT-8')  // 时区 GMT+8
   ├── header('Content-type: text/html; charset=utf-8')
   ├── define('SYS_TIME', time())         // 系统时间
   └── base::creat_app()                  // 创建应用

3. base::creat_app()
   └── new application()                  // 实例化应用
       ├── new param()                    // URL参数解析
       │   ├── ROUTE_M = route_m()        // 模块 (go/admin/daili)
       │   ├── ROUTE_C = route_c()        // 控制器
       │   ├── ROUTE_A = route_a()        // 动作
       │   └── ROUTE_LANG = route_lang()  // 当前语言
       └── init()                         // 执行控制器方法
           └── call_user_func([$controller, ROUTE_A])
```

### 4.2 语言解析逻辑

文件：`source/libs/classes/param.class.php`

```php
public function route_lang() {
    // 1. 优先从 URL 参数获取: ?lang=en-us
    $lang = isset($_GET['lang']) ? trim($_GET['lang']) : '';
    
    // 2. 白名单验证（仅允许 zh-cn, en-us, my-mm）
    if (in_array($lang, array('zh-cn', 'en-us', 'my-mm'))) {
        set_cookie('language', $lang);  // 写入 cookie 持久化
        return $lang;
    }
    
    // 3. 从 cookie 读取
    $cookie_lang = get_cookie('language');
    if (in_array($cookie_lang, array('zh-cn', 'en-us', 'my-mm'))) {
        return $cookie_lang;
    }
    
    // 4. 使用系统默认语言
    return base::load_config('system', 'lang');  // 默认 zh-cn
}
```

### 4.3 翻译函数 L() 逻辑

文件：`source/libs/functions/global.func.php`

```php
function L($key, $module = 'go') {
    global $LANG, $LANG_LOADED;
    
    // 首次调用时加载语言包
    if (!$LANG_LOADED) {
        $LANG = array();
        // 加载系统语言包
        $sys_lang = FILE_PATH . 'languages/' . ROUTE_LANG . '/system.lang.php';
        if (file_exists($sys_lang)) {
            $tmp = include $sys_lang;
            if (is_array($tmp)) $LANG = array_merge($LANG, $tmp);
        }
        // 加载模块语言包
        $mod_lang = FILE_PATH . 'languages/' . ROUTE_LANG . '/' . $module . '.lang.php';
        if (file_exists($mod_lang)) {
            $tmp = include $mod_lang;
            if (is_array($tmp)) $LANG = array_merge($LANG, $tmp);
        }
        $LANG_LOADED = true;
    }
    
    // 查找翻译
    if (isset($LANG[$key])) {
        return $LANG[$key];
    }
    
    // 未找到翻译，返回键名本身
    return $key;
}
```

### 4.4 数据库连接机制

```
base::load_model('user_model')
  → _load_class('user_model', 'model')
  → include model/user_model.class.php
  → new user_model() extends model
    → model::__construct()
      → db_factory::get_instance()
        → 读取 configs/database.php
        → 创建 mysqli 驱动实例
        → mysqli->connect(hostname, username, password, database)
```

数据库配置（`configs/database.php`）：

```php
return array(
    'default' => array(
        'hostname' => '127.0.0.1',
        'database' => 'fantan_db',
        'username' => 'root',
        'password' => 'root',
        'tablepre' => 'bc_',
        'charset'  => 'utf8',
        'type'     => 'mysqli',    // 驱动类型
        'debug'    => true,        // ⚠️ 生产环境必须改为 false
        'pconnect' => 0,
        'autoconnect' => 0
    )
);
```

### 4.5 Session 机制

- **默认存储**：MySQL 数据库（`bc_session` 表，ENGINE=MEMORY）
- **备用存储**：文件（`caches/sessions/` 目录）
- **配置项**：`configs/system.php` → `session_storage => 'mysql'`
- **超时时间**：1800 秒（30 分钟）

### 4.6 开奖数据采集与结算

文件：`api/game_service.php`

**采集流程**：
1. 前端 `service.php` 页面定时 AJAX 请求 `api/game_service.php`
2. 根据彩票类型（cqssc/gdkl/pk10/pcdd 等）构造 API URL
3. CURL 请求 `pay5000.com` API 获取开奖号码
4. 写入 `bc_haoma` 表
5. 结算：查询 `bc_order` 未结算注单，根据玩法规则计算输赢
6. 更新用户余额、写入 `bc_account` 流水

**支持的彩票类型**：
| 代码 | 名称 | gameid | 采集来源 |
|------|------|--------|---------|
| cqssc | 重庆时时彩 | 1,7,12 | pay5000 API |
| gdkl | 广东快乐10分 | 2,8 | pay5000 API |
| xync | 幸运农场 | 3 | pay5000 API |
| pcdd | PC蛋蛋/幸运28 | 4,9 | pay5000 API |
| jnd28 | 加拿大28 | 5,10 | pay5000 API |
| pk10 | 北京赛车 | 6,11 | pay5000 API |
| teqdd | 极速28 | 13 | 系统自开 |
| jsssc | 极速时时彩 | 14 | 系统自开 |

**⚠️ 重要**：需在 `api/game_service.php` 中配置 API Token：
```php
define('TOKEN', "你的账号token");  // 替换为 pay5000.com 的 token
```

### 4.7 模板编译引擎

文件：`source/libs/classes/template_cache.class.php`

- 模板文件：`templates/default/*.html`
- 编译输出：`caches/caches_template/*.php`
- 编译规则：将 `<?php echo L('key')?>` 编译为原生 PHP
- 刷新控制：`tpl_referesh = 1` 时每次请求检查模板更新；生产环境应设为 `0`

### 4.8 关键数据表关系

```
bc_user (用户表)
  ├── uid → bc_order.uid (投注订单)
  ├── uid → bc_account.uid (资金流水)
  ├── uid → bc_pay.uid (充值记录)
  ├── uid → bc_cash.uid (提现记录)
  └── aid → 代理等级 (0=普通, 1-3=代理层级)

bc_game (游戏配置)
  ├── id → bc_haoma.gameid (开奖号码)
  └── id → bc_order.gameid (投注订单)

bc_haoma (开奖号码)
  └── gameid+qishu → 唯一标识一期开奖

bc_order (投注订单)
  └── account=0 → 未结算; account>0 → 盈利; account<0 → 亏损

bc_settings (系统设置，key-value)
  └── 22 行配置项，后台管理可修改
```

---

## 5. 部署步骤

### 5.1 手动部署步骤

#### Step 1: 环境准备

```bash
# Ubuntu
apt update && apt install -y nginx php7.4-fpm php7.4-mysql php7.4-gd php7.4-curl \
    php7.4-mbstring php7.4-bcmath php7.4-json php7.4-session mysql-server

# CentOS
yum install -y nginx php74-php-fpm php74-php-mysqlnd php74-php-gd php74-php-curl \
    php74-php-mbstring php74-php-bcmath php74-php-json php74-php-session mysql-server
```

#### Step 2: 获取代码

```bash
cd /var/www
git clone https://github.com/fredphp/yunwei001.git yunwei
cd yunwei
```

#### Step 3: 创建数据库

```bash
mysql -u root -p -e "
CREATE DATABASE fantan_db DEFAULT CHARACTER SET utf8;
USE fantan_db;
SOURCE sql/fantan_db.sql;
"
```

#### Step 4: 修改配置

```bash
# 修改数据库配置
vi wwwroot/configs/database.php
# 改为实际数据库账号密码，debug 改为 false

# 修改系统配置
vi wwwroot/configs/system.php
# 修改 auth_key 为随机字符串
```

#### Step 5: 设置权限

```bash
chown -R www-data:www-data /var/www/yunwei/wwwroot
chmod -R 777 /var/www/yunwei/wwwroot/caches
chmod -R 777 /var/www/yunwei/wwwroot/uppic
chmod 666 /var/www/yunwei/wwwroot/configs/setting.php
```

#### Step 6: 配置 Nginx

```bash
# 参照第 6 节配置 Nginx
vi /etc/nginx/sites-available/yunwei
ln -s /etc/nginx/sites-available/yunwei /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

#### Step 7: 验证访问

```bash
curl -I http://localhost/
# 应返回 200 OK
```

---

## 6. Nginx 配置

### 6.1 标准配置

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/yunwei/wwwroot;
    index index.php index.html;

    # 禁止访问敏感目录
    location ~ ^/(source|caches|configs)/ {
        deny all;
        return 403;
    }

    # 禁止执行上传目录中的 PHP
    location ~ ^/uppic/.*\.php$ {
        deny all;
        return 403;
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|mp3)$ {
        expires 30d;
        access_log off;
    }

    # PHP 处理
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # 超时设置（开奖采集可能较慢）
        fastcgi_read_timeout 120;
        fastcgi_send_timeout 120;
    }

    # 默认路由
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # 禁止访问隐藏文件
    location ~ /\. {
        deny all;
    }
}
```

### 6.2 HTTPS 配置（推荐）

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate     /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # ... 其余配置同上 ...
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 7. 安全加固

### 7.1 必须修改的配置

| 文件 | 配置项 | 默认值 | 建议值 | 说明 |
|------|--------|--------|--------|------|
| `configs/database.php` | `debug` | `true` | `false` | 调试模式暴露 SQL 错误 |
| `configs/database.php` | `password` | `root` | 强密码 | 数据库密码 |
| `configs/system.php` | `auth_key` | `b83988e...` | 随机 32 位 | Cookie 加解密密钥 |
| `configs/system.php` | `debug` | `0` | `0` | 确保关闭调试 |
| `api/game_service.php` | `TOKEN` | `"你的账号token"` | 实际 token | API 访问令牌 |

### 7.2 目录安全

```bash
# 禁止 Web 访问的目录
source/     ← 应用源码（包含数据库凭证）
caches/     ← 运行时缓存（含编译模板）
configs/    ← 配置文件（含数据库密码）

# 需要写权限但禁止执行 PHP
uppic/      ← 用户上传目录（防止 PHP 木马执行）
```

### 7.3 防火墙规则

```bash
# 仅开放必要端口
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw enable
```

### 7.4 MySQL 安全

```bash
mysql_secure_installation
# 1. 设置 root 密码
# 2. 移除匿名用户
# 3. 禁止 root 远程登录
# 4. 移除 test 数据库
```

---

## 8. i18n 多语言系统说明

### 8.1 支持语言

| 代码 | 语言 | 状态 |
|------|------|------|
| `zh-cn` | 简体中文 | 默认语言 |
| `en-us` | English | 完整翻译 |
| `my-mm` | မြန်မာ (缅甸语) | 完整翻译 |

### 8.2 语言切换方式

1. **URL 参数**：`?lang=en-us`（立即切换，同时写入 Cookie）
2. **Cookie 持久化**：`get_cookie('language')` 记住用户选择
3. **默认回退**：无参数且无 Cookie 时使用 `system.php` 中的 `lang` 配置

### 8.3 语言包文件

```
source/languages/
├── zh-cn/
│   ├── system.lang.php    ← 系统通用翻译（7 个 key）
│   └── go.lang.php        ← 前台模块翻译（354 个 key）
├── en-us/
│   ├── system.lang.php
│   └── go.lang.php
└── my-mm/
    ├── system.lang.php
    └── go.lang.php
```

### 8.4 翻译调用方式

**PHP 模板中**：
```php
<?php echo L('login')?>        // 输出: 登录 / Login / လော့ဂ်အင်
<?php echo L('withdrawal')?>    // 输出: 提现 / Withdraw / ငွေထုတ်
```

**JavaScript 中**（通过 header.html 注入的 LANG 全局变量）：
```javascript
layer.alert(LANG.login_failed);   // 弹窗提示
$('#btn').text(LANG.submit);      // 按钮文字
```

### 8.5 仅前台支持多语言

后台（admin）和代理（daili）模块**不支持多语言**，始终保持中文界面。

---

## 9. 常见问题排查

### 9.1 白屏/500 错误

```bash
# 检查 Nginx 错误日志
tail -50 /var/log/nginx/error.log

# 检查 PHP-FPM 错误日志
tail -50 /var/log/php7.4-fpm/error.log

# 检查应用错误日志
tail -50 /var/www/yunwei/wwwroot/caches/error_log.php
```

### 9.2 数据库连接失败

```bash
# 测试连接
mysql -u root -p -e "SHOW DATABASES;"

# 检查配置
cat wwwroot/configs/database.php
```

### 9.3 模板编译错误

```bash
# 清除模板缓存
rm -rf wwwroot/caches/caches_template/*
# 下次访问时自动重新编译
```

### 9.4 Session 问题

```bash
# 检查 session 表
mysql -u root -p -e "SELECT COUNT(*) FROM fantan_db.bc_session;"

# 如切换为文件 session
# 修改 configs/system.php: 'session_storage' => 'files'
# 确保 wwwroot/caches/sessions/ 有写权限
```

### 9.5 图片上传失败

```bash
# 检查目录权限
ls -la wwwroot/uppic/
# 应为 drwxrwxrwx

# 检查 PHP 上传配置
php -i | grep upload_max_filesize
# 建议设为 10M
```

### 9.6 验证码不显示

```bash
# 检查 GD 扩展
php -m | grep gd

# 检查字体文件
ls wwwroot/source/libs/data/font/elephant.ttf
```

### 9.7 开奖数据不更新

```bash
# 1. 确认 API Token 已配置
grep "define('TOKEN'" wwwroot/api/game_service.php

# 2. 手动测试采集
curl "http://localhost/api/game_service.php?lotteryname=cqssc&gameid=1&account=0"

# 3. 检查 CURL 扩展
php -m | grep curl
```

---

## 10. 一键部署脚本使用说明

项目根目录下提供了 `deploy.sh` 一键部署脚本。

### 10.1 使用方式

```bash
# 基本用法（交互式）
sudo bash deploy.sh

# 指定参数（非交互式）
sudo bash deploy.sh --db-pass MyP@ssw0rd --domain example.com -y

# 仅检查环境
sudo bash deploy.sh --check-only

# 查看帮助
sudo bash deploy.sh --help
```

### 10.2 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--db-host` | MySQL 主机 | 127.0.0.1 |
| `--db-user` | MySQL 用户名 | root |
| `--db-pass` | MySQL 密码 | root |
| `--db-name` | 数据库名 | fantan_db |
| `--domain` | 绑定域名 | localhost |
| `--web-root` | Web 根目录 | /var/www/yunwei |
| `--php-version` | PHP 版本 | 7.4 |
| `-y` | 跳过确认 | - |
| `--check-only` | 仅检查环境 | - |

### 10.3 脚本执行流程

```
1. 环境检查
   ├── 操作系统检测
   ├── Nginx 安装检测
   ├── PHP 版本 + 扩展检测
   ├── MySQL 安装检测
   └── 端口占用检测

2. 安装依赖（如缺失）
   ├── Nginx
   ├── PHP-FPM + 扩展
   └── MySQL

3. 部署代码
   ├── 创建目录
   ├── 克隆代码 / 复制文件
   ├── 导入数据库
   └── 修改配置文件

4. 配置服务
   ├── Nginx 虚拟主机
   ├── PHP-FPM 配置
   └── 文件权限

5. 启动服务
   ├── 启动 MySQL
   ├── 启动 PHP-FPM
   └── 启动 Nginx

6. 访问验证
   ├── HTTP 状态码检测
   ├── 数据库连接验证
   ├── PHP 扩展验证
   └── 页面内容验证
```

### 10.4 部署后访问

| 入口 | URL | 说明 |
|------|-----|------|
| 前台首页 | `http://domain/` | 用户首页 |
| 前台英文 | `http://domain/?lang=en-us` | 英文版 |
| 前台缅甸语 | `http://domain/?lang=my-mm` | 缅甸语版 |
| 后台管理 | `http://domain/admin.php` | 管理后台 |
| 代理管理 | `http://domain/daili.php` | 代理后台 |
| 开奖监控 | `http://domain/service.php` | 采集结算监控 |

**默认管理员账号**：`admin` / 密码需重置

---

## 附录 A：数据库表清单

| 表名 | 引擎 | 说明 | 种子数据 |
|------|------|------|---------|
| bc_admin | MyISAM | 管理员 | 1 条 (admin) |
| bc_user | MyISAM | 用户/代理 | 0 条 |
| bc_game | MyISAM | 游戏配置 | 14 条 |
| bc_haoma | MyISAM | 开奖号码 | 0 条 |
| bc_order | MyISAM | 投注订单 | 0 条 |
| bc_pay | MyISAM | 充值记录 | 0 条 |
| bc_cash | MyISAM | 提现记录 | 0 条 |
| bc_account | MyISAM | 资金流水 | 0 条 |
| bc_session | MEMORY | PHP Session | 0 条 |
| bc_settings | MyISAM | 系统设置 | 22 条 |

## 11. Docker 一键部署（macOS / Linux / Windows 通用）

### 11.1 Docker 方式优势

| 特性 | 原生部署 | Docker 部署 |
|------|---------|------------|
| 操作系统 | 仅 Linux | macOS / Linux / Windows |
| PHP 版本 | 需手动安装 7.4 | 自动构建 7.4 镜像 |
| MySQL | 需手动安装 | 自动启动 MySQL 5.7 |
| 端口冲突 | 需手动处理 | 可自定义端口 |
| 环境隔离 | 无 | 完全隔离 |
| 一键启动 | ❌ | ✅ |

### 11.2 Docker 部署架构

```
docker-compose.yml
├── nginx (Nginx 1.24 Alpine)
│   ├── 端口: 80 → 80
│   └── 挂载: wwwroot/ → /var/www/html/wwwroot
├── php (PHP 7.4 FPM, 自构建)
│   ├── 扩展: mysqli, gd, curl, mbstring, bcmath, json, session
│   └── 挂载: wwwroot/ → /var/www/html/wwwroot
└── mysql (MySQL 5.7)
    ├── 端口: 3306 → 3306
    ├── 自动初始化: sql/fantan_db.sql
    └── 持久化: Docker Volume (yunwei_mysql_data)
```

### 11.3 使用方式

```bash
# 方式一：一键部署脚本（推荐）
bash deploy-docker.sh                                    # 交互式
bash deploy-docker.sh --db-pass root --domain ywcp.local -y  # 非交互式
bash deploy-docker.sh --nginx-port 8080 -y               # 自定义端口
bash deploy-docker.sh --check-only                        # 仅环境检查

# 方式二：手动 Docker Compose
cd docker
docker compose up -d          # 启动所有容器
docker compose ps             # 查看状态
docker compose logs -f        # 查看日志
docker compose down           # 停止
```

### 11.4 Docker 部署参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--db-user` | MySQL 用户名 | root |
| `--db-pass` | MySQL 密码 | root |
| `--db-name` | 数据库名 | fantan_db |
| `--nginx-port` | Nginx 端口 | 80 |
| `--mysql-port` | MySQL 映射端口 | 3306 |
| `-y` | 跳过确认 | - |
| `--check-only` | 仅检查环境 | - |

### 11.5 Docker 管理命令

```bash
cd docker

# 容器管理
docker compose ps                    # 查看运行状态
docker compose logs -f nginx         # 查看 Nginx 日志
docker compose logs -f php           # 查看 PHP 日志
docker compose logs -f mysql         # 查看 MySQL 日志
docker compose restart               # 重启所有服务
docker compose down                  # 停止并删除容器

# 数据库操作
docker exec -it yunwei_mysql mysql -uroot -proot fantan_db

# PHP 操作
docker exec -it yunwei_php bash      # 进入 PHP 容器
docker exec yunwei_php php -m        # 查看已加载扩展

# 清除所有数据（危险！）
docker compose down -v               # 停止并删除容器+数据卷
```

---

## 附录 B：PHP 兼容性补丁（如需 PHP 8.x）

```php
// param.class.php 顶部添加：
if (!function_exists('get_magic_quotes_gpc')) {
    function get_magic_quotes_gpc() { return false; }
}

// mysqli.class.php 中 is_resource() 替换：
// 将 is_resource($this->link) 替换为：
is_object($this->link) || is_resource($this->link)

// template_cache.class.php 中 /e 修饰符替换：
// 将 preg_replace('/pattern/es', 'func()', $str) 替换为：
// preg_replace_callback('/pattern/s', function($m) { return func($m); }, $str)
```
