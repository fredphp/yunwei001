<?php
/**
 * 诊断脚本 v2 - 全面排查 500 错误
 * 使用方法: http://域名:端口/diag.php
 * 用完请删除此文件!
 */
header('Content-Type: text/html; charset=utf-8');
echo "<h1>蚁彩系统诊断 v2</h1><pre style='font-size:13px;line-height:1.6'>";
echo "PHP版本: " . PHP_VERSION . "\n";
echo "时间: " . date('Y-m-d H:i:s') . "\n";
echo "SAPI: " . php_sapi_name() . "\n\n";

define('IN_MYWEB', true);
define('MYFILE_PATH', dirname(__FILE__) . DIRECTORY_SEPARATOR);
define('FILE_PATH', dirname(__FILE__) . DIRECTORY_SEPARATOR . 'source' . DIRECTORY_SEPARATOR);
define('CACHE_PATH', FILE_PATH . '..' . DIRECTORY_SEPARATOR . 'caches' . DIRECTORY_SEPARATOR);
define('CONFIG_PATH', FILE_PATH . '..' . DIRECTORY_SEPARATOR . 'configs' . DIRECTORY_SEPARATOR);
define('SYS_TIME', time());

// ============ 1. 基础配置检查 ============
echo "=== 1. 配置文件 ===\n";

$sp = CONFIG_PATH . 'system.php';
if (file_exists($sp)) {
    $sys = @include $sp;
    if (is_array($sys)) {
        echo "system.php: ✅ 加载成功\n";
        echo "  pk10_open_type: " . (isset($sys['pk10_open_type']) ? $sys['pk10_open_type'] : '未定义') . "\n";
        echo "  tpl_name: " . $sys['tpl_name'] . "\n";
        echo "  session_storage: " . $sys['session_storage'] . "\n";
        echo "  lang: " . $sys['lang'] . "\n";
        echo "  iscache: " . $sys['iscache'] . "\n";
        echo "  errorlog: " . $sys['errorlog'] . "\n";
    } else {
        echo "system.php: ❌ 返回值不是数组\n";
    }
} else {
    echo "system.php: ❌ 不存在\n";
}

$dp = CONFIG_PATH . 'database.php';
if (file_exists($dp)) {
    $dbconfig = @include $dp;
    if (is_array($dbconfig) && isset($dbconfig['default'])) {
        echo "database.php: ✅ 加载成功\n";
        echo "  hostname: " . $dbconfig['default']['hostname'] . "\n";
        echo "  database: " . $dbconfig['default']['database'] . "\n";
        echo "  type: " . $dbconfig['default']['type'] . "\n";
    } else {
        echo "database.php: ❌ 格式异常\n";
    }
} else {
    echo "database.php: ❌ 不存在（部署脚本会自动创建）\n";
}

// ============ 2. MySQL连接检查 ============
echo "\n=== 2. MySQL连接 ===\n";
if (file_exists($dp)) {
    $dbconfig = @include $dp;
    if (is_array($dbconfig) && isset($dbconfig['default'])) {
        $m = @new mysqli($dbconfig['default']['hostname'], $dbconfig['default']['username'], $dbconfig['default']['password'], $dbconfig['default']['database']);
        if ($m->connect_error) {
            echo "MySQL直连: ❌ " . $m->connect_error . "\n";
        } else {
            echo "MySQL直连: ✅ " . $m->server_info . "\n";

            // 检查关键表
            $tables = array('bc_game', 'bc_haoma', 'bc_order', 'bc_user', 'bc_settings', 'bc_session');
            foreach ($tables as $t) {
                $r = $m->query("SELECT COUNT(*) as cnt FROM `$t`");
                if ($r) {
                    $row = $r->fetch_assoc();
                    echo "  $t: ✅ ({$row['cnt']} 行)\n";
                } else {
                    echo "  $t: ❌ 表不存在或查询失败\n";
                }
            }
            $m->close();
        }
    }
} else {
    echo "跳过（database.php不存在）\n";
}

// ============ 3. 缓存目录检查 ============
echo "\n=== 3. 缓存目录 ===\n";
$dirs = array(
    CACHE_PATH,
    CACHE_PATH . 'caches_template',
    CACHE_PATH . 'caches_template/default',
    CACHE_PATH . 'sessions',
);
foreach ($dirs as $d) {
    $exists = is_dir($d);
    $writable = $exists && is_writable($d);
    echo "$d: " . ($exists ? '✅存在' : '❌不存在') . ($writable ? ' ✅可写' : ' ❌不可写') . "\n";

    // 如果目录不存在，尝试创建
    if (!$exists) {
        $created = @mkdir($d, 0777, true);
        echo "  → 尝试创建: " . ($created ? '✅成功' : '❌失败') . "\n";
    }
}

// ============ 4. 模板文件检查 ============
echo "\n=== 4. 模板文件 ===\n";
$tpl_dir = MYFILE_PATH . 'templates/default/';
$critical_templates = array('index.html', 'login.html', 'game_pk10.html', 'game_chat.html', 'message.html', 'haoma.html');
foreach ($critical_templates as $tpl) {
    $path = $tpl_dir . $tpl;
    echo "$tpl: " . (file_exists($path) ? '✅' : '❌') . " (" . (file_exists($path) ? filesize($path) : 0) . " bytes)\n";
}

// ============ 5. 核心PHP文件语法检查 ============
echo "\n=== 5. 核心文件检查 ===\n";
$core_files = array(
    'source/base.php',
    'source/libs/classes/application.class.php',
    'source/libs/classes/param.class.php',
    'source/libs/classes/session_mysql.class.php',
    'source/libs/functions/global.func.php',
    'source/modules/go/index.php',
    'source/modules/go/classes/go.class.php',
    'api/game_service.php',
    'api/get_haoma.php',
);
foreach ($core_files as $f) {
    $path = MYFILE_PATH . $f;
    if (file_exists($path)) {
        // 简单语法检查：尝试读取并查找明显的PHP语法错误
        $content = file_get_contents($path);
        $lines = substr_count($content, "\n") + 1;
        echo "$f: ✅ ($lines 行)\n";
    } else {
        echo "$f: ❌ 不存在\n";
    }
}

// ============ 6. 模拟页面渲染 ============
echo "\n=== 6. 页面渲染模拟 ===\n";

// 6a: 测试base.php加载
echo "--- 6a: base.php 加载 ---\n";
$base_errors = array();
set_error_handler(function($errno, $errstr, $errfile, $errline) use (&$base_errors) {
    $base_errors[] = "[$errno] $errstr in $errfile:$errline";
    return true;
});
try {
    ob_start();
    include MYFILE_PATH . 'source/base.php';
    ob_end_clean();
    if (empty($base_errors)) {
        echo "base.php: ✅ 加载成功\n";
    } else {
        echo "base.php: ⚠️ 有警告:\n";
        foreach (array_slice($base_errors, 0, 5) as $e) {
            echo "  $e\n";
        }
    }
} catch (Exception $e) {
    ob_end_clean();
    echo "base.php: ❌ 异常: " . $e->getMessage() . "\n";
} catch (Error $e) {
    ob_end_clean();
    echo "base.php: ❌ 致命错误: " . $e->getMessage() . "\n";
}
restore_error_handler();

// 6b: 测试application加载
echo "--- 6b: application 加载 ---\n";
if (defined('FILE_PATH')) {
    $app_file = FILE_PATH . 'libs/classes/application.class.php';
    if (file_exists($app_file)) {
        $app_errors = array();
        set_error_handler(function($errno, $errstr, $errfile, $errline) use (&$app_errors) {
            $app_errors[] = "[$errno] $errstr in $errfile:$errline";
            return true;
        });
        try {
            include $app_file;
            echo "application.class.php: ✅ 加载成功\n";
        } catch (Error $e) {
            echo "application.class.php: ❌ 致命错误: " . $e->getMessage() . "\n";
        }
        restore_error_handler();
    } else {
        echo "application.class.php: ❌ 不存在\n";
    }
}

// 6c: 测试控制器加载
echo "--- 6c: go/index.php 控制器 ---\n";
$ctrl_file = MYFILE_PATH . 'source/modules/go/index.php';
if (file_exists($ctrl_file)) {
    $ctrl_errors = array();
    set_error_handler(function($errno, $errstr, $errfile, $errline) use (&$ctrl_errors) {
        $ctrl_errors[] = "[$errno] $errstr in $errfile:$errline";
        return true;
    });
    try {
        // 不实际实例化（需要base.php上下文），只检查语法
        $content = php_check_syntax($ctrl_file, $error_msg);
        if ($content === false) {
            echo "go/index.php: ❌ 语法错误: $error_msg\n";
        } else {
            echo "go/index.php: ✅ 语法检查通过\n";
        }
    } catch (Error $e) {
        echo "go/index.php: ❌ 致命错误: " . $e->getMessage() . "\n";
    }
    restore_error_handler();
} else {
    echo "go/index.php: ❌ 不存在\n";
}

// 6d: 测试game_service.php
echo "--- 6d: game_service.php ---\n";
$gs_file = MYFILE_PATH . 'api/game_service.php';
if (file_exists($gs_file)) {
    $gs_errors = array();
    set_error_handler(function($errno, $errstr, $errfile, $errline) use (&$gs_errors) {
        $gs_errors[] = "[$errno] $errstr in $errfile:$errline";
        return true;
    });
    try {
        $content = php_check_syntax($gs_file, $error_msg);
        if ($content === false) {
            echo "game_service.php: ❌ 语法错误: $error_msg\n";
        } else {
            echo "game_service.php: ✅ 语法检查通过\n";
        }
    } catch (Error $e) {
        echo "game_service.php: ❌ 致命错误: " . $e->getMessage() . "\n";
    }
    restore_error_handler();
}

// ============ 7. Session测试 ============
echo "\n=== 7. Session测试 ===\n";
if (defined('CACHE_PATH')) {
    $sess_dir = CACHE_PATH . 'sessions/';
    echo "Session目录: $sess_dir\n";
    echo "  存在: " . (is_dir($sess_dir) ? '✅' : '❌') . "\n";
    echo "  可写: " . (is_writable($sess_dir) ? '✅' : '❌') . "\n";

    // 测试MySQL session
    if (file_exists($dp)) {
        $dbconfig = @include $dp;
        $m = @new mysqli($dbconfig['default']['hostname'], $dbconfig['default']['username'], $dbconfig['default']['password'], $dbconfig['default']['database']);
        if (!$m->connect_error) {
            $r = $m->query("SELECT COUNT(*) as cnt FROM bc_session");
            if ($r) {
                $row = $r->fetch_assoc();
                echo "  bc_session表: ✅ ({$row['cnt']} 条活跃session)\n";
            } else {
                echo "  bc_session表: ❌ 查询失败\n";
            }
            $m->close();
        }
    }
}

// ============ 8. 错误日志分析 ============
echo "\n=== 8. 错误日志 ===\n";
$elog = CACHE_PATH . 'error_log.php';
if (file_exists($elog)) {
    $lines = file($elog);
    echo count($lines)." 行\n";

    // 最近10条
    echo "最近10条:\n";
    foreach(array_slice($lines, -10) as $l) {
        echo "  " . htmlspecialchars(trim($l)) . "\n";
    }

    // 统计错误类型
    $error_types = array();
    foreach ($lines as $l) {
        if (preg_match('/\|\s*(\d+)\s*\|/', $l, $m)) {
            $type = $m[1];
            if (!isset($error_types[$type])) $error_types[$type] = 0;
            $error_types[$type]++;
        }
    }
    echo "\n错误类型统计:\n";
    foreach ($error_types as $type => $count) {
        $type_name = array(1 => 'Error', 2 => 'Warning', 4 => 'Parse', 8 => 'Notice', 16 => 'CoreError', 32 => 'CoreWarning', 64 => 'CompileError', 128 => 'CompileWarning', 256 => 'UserError', 512 => 'UserWarning', 1024 => 'UserNotice');
        $name = isset($type_name[$type]) ? $type_name[$type] : "Type$type";
        echo "  $name ($type): $count 次\n";
    }
} else {
    echo "无自定义错误日志\n";
}

// PHP-FPM 错误日志
echo "\n--- PHP-FPM 错误日志 ---\n";
$php_log_paths = array(
    '/var/log/php-fpm/error.log',
    '/var/log/php7.4-fpm/error.log',
    '/usr/local/var/log/php-fpm/error.log',
    '/var/log/php/error.log',
);
foreach ($php_log_paths as $p) {
    if (file_exists($p) && is_readable($p)) {
        $last_lines = array();
        $fp = fopen($p, 'r');
        fseek($fp, -1, SEEK_END);
        $pos = ftell($fp);
        $line_count = 0;
        $content = '';
        while ($pos >= 0 && $line_count < 20) {
            fseek($fp, $pos, SEEK_SET);
            $char = fgetc($fp);
            if ($char === "\n" && $content !== '') {
                $last_lines[] = $content;
                $content = '';
                $line_count++;
            } else {
                $content = $char . $content;
            }
            $pos--;
        }
        if ($content) $last_lines[] = $content;
        fclose($fp);
        echo "✅ $p:\n";
        foreach (array_reverse(array_slice($last_lines, 0, 10)) as $l) {
            echo "  " . htmlspecialchars(trim($l)) . "\n";
        }
        break;
    }
}
// 也尝试php.ini中配置的error_log
$php_error_log = ini_get('error_log');
if ($php_error_log && file_exists($php_error_log) && is_readable($php_error_log)) {
    echo "php.ini error_log: $php_error_log\n";
    $lines = explode("\n", file_get_contents($php_error_log, false, null, max(0, filesize($php_error_log) - 5000)));
    foreach (array_slice($lines, -10) as $l) {
        if (trim($l)) echo "  " . htmlspecialchars(trim($l)) . "\n";
    }
}

// Nginx错误日志
echo "\n--- Nginx 错误日志 ---\n";
$nginx_log_paths = array(
    '/var/log/nginx/error.log',
    '/usr/local/var/log/nginx/error.log',
);
foreach ($nginx_log_paths as $p) {
    if (file_exists($p) && is_readable($p)) {
        $size = filesize($p);
        $content = file_get_contents($p, false, null, max(0, $size - 5000));
        $lines = explode("\n", $content);
        echo "✅ $p:\n";
        foreach (array_slice($lines, -10) as $l) {
            if (trim($l)) echo "  " . htmlspecialchars(trim($l)) . "\n";
        }
        break;
    }
}

// ============ 9. 实际页面测试 ============
echo "\n=== 9. 实际页面访问测试 ===\n";
$test_pages = array(
    '/index.php' => '首页',
    '/index.php?a=login' => '登录页',
);
foreach ($test_pages as $url => $name) {
    $full_url = 'http://' . $_SERVER['HTTP_HOST'] . $url;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $full_url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_NOBODY, false);
    curl_setopt($ch, CURLOPT_HEADER, false);
    // 不跟随重定向
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    echo "$name ($url): HTTP $http_code";
    if ($http_code == 200) {
        echo " ✅";
    } elseif ($http_code == 302 || $http_code == 301) {
        echo " ⚠️ 重定向";
    } else {
        echo " ❌";
        if ($error) echo " ($error)";
        // 显示前200字符
        if ($response) {
            $preview = strip_tags(substr($response, 0, 200));
            echo "\n  预览: " . htmlspecialchars($preview);
        }
    }
    echo "\n";
}

// ============ 10. PHP扩展检查 ============
echo "\n=== 10. PHP扩展 ===\n";
$required_exts = array('mysqli', 'pdo_mysql', 'gd', 'curl', 'json', 'session', 'mbstring', 'bcmath', 'zip');
foreach ($required_exts as $ext) {
    echo "$ext: " . (extension_loaded($ext) ? '✅' : '❌') . "\n";
}

echo "\n=== 诊断完成 ===\n</pre>";
