<?php
/**
 * 开奖采集与注单结算 - CLI定时任务脚本
 *
 * 替代原 service.php 浏览器AJAX轮询模式
 * 由Linux crontab定时调用，通过内部HTTP请求调用game_service接口
 *
 * 用法:
 *   php cron_service.php              # 执行一次完整采集+结算
 *   php cron_service.php collect      # 仅执行采集（不自开奖+外部采集）
 *   php cron_service.php settle       # 仅执行注单结算
 *   php cron_service.php teqdd        # 仅处理极速28
 *   php cron_service.php jsssc        # 仅处理极速时时彩
 *
 * Crontab配置（每30秒执行一次）:
 *   * * * * * php /path/to/wwwroot/cron_service.php >> /path/to/wwwroot/caches/cron.log 2>&1
 *   * * * * sleep 30; php /path/to/wwwroot/cron_service.php >> /path/to/wwwroot/caches/cron.log 2>&1
 */

// ========== 安全检查：仅允许CLI运行 ==========
if (php_sapi_name() !== 'cli') {
    http_response_code(403);
    exit('Access Denied. CLI mode only.');
}

// ========== 防止重复运行（文件锁） ==========
$lock_dir = __DIR__ . '/../caches';
if (!is_dir($lock_dir)) {
    @mkdir($lock_dir, 0777, true);
}
$lock_file = $lock_dir . '/cron_service.lock';
$lock_fp = @fopen($lock_file, 'w+');
if (!$lock_fp) {
    // 无法创建锁文件（权限问题），尝试临时目录
    $lock_file = sys_get_temp_dir() . '/cron_service_yunwei.lock';
    $lock_fp = @fopen($lock_file, 'w+');
}
if (!$lock_fp || !flock($lock_fp, LOCK_EX | LOCK_NB)) {
    exit('[' . date('Y-m-d H:i:s') . '] Another cron_service instance is running. Skip.' . PHP_EOL);
}
register_shutdown_function(function() use ($lock_fp, $lock_file) {
    flock($lock_fp, LOCK_UN);
    fclose($lock_fp);
    @unlink($lock_file);
});

// ========== 配置 ==========
// 安全令牌（必须与game_service.php中的SERVICE_TOKEN一致）
define('SERVICE_TOKEN', 'g9FVgXM2XKjZH2SSITWaN4L6S5qEZgwy6RehiioXM10');

// 内部请求基础URL（自动检测Docker环境）
// Docker容器内: Nginx在yunwei_nginx容器(同网络)，使用http://yunwei_nginx
// 物理服务器: Nginx在本机127.0.0.1，可能需要HTTPS
if (getenv('DOCKER_CRON') === '1' || file_exists('/.dockerenv')) {
    // Docker环境：Nginx在另一个容器，通过Docker内部网络访问
    $base_url = 'http://yunwei_nginx';
} else {
    // 物理服务器：Nginx在本机，可能有HTTPS重定向
    $base_url = 'https://127.0.0.1';
}

// 彩种映射表（gameid => lotteryname）
$games = array(
    1 => 'cqssc',
    2 => 'gdkl',
    3 => 'xync',
    4 => 'pcdd',
    5 => 'jnd28',
    6 => 'pk10',
    7 => 'teqdd',   // 极速28（对应service.php中的id=7，实际gameid=13）
    8 => 'jsssc',   // 极速时时彩（对应service.php中的id=8，实际gameid=14）
);

// 获取命令行参数
$mode = isset($argv[1]) ? trim($argv[1]) : 'all';

$log_time = date('Y-m-d H:i:s');
echo "[{$log_time}] ===== cron_service START (mode={$mode}) =====" . PHP_EOL;

// ========== 内部HTTP请求函数 ==========
function cron_request($url, $post_data = array(), $timeout = 30) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, $timeout);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);  // 跟随重定向
    curl_setopt($ch, CURLOPT_MAXREDIRS, 3);
    // 仅允许访问本机/内网（Docker环境不绑定接口，因为Nginx在不同容器）
    if (!file_exists('/.dockerenv')) {
        curl_setopt($ch, CURLOPT_INTERFACE, '127.0.0.1');
    }
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    if ($error) {
        return json_encode(array('state' => 0, 'msg' => 'CURL错误: ' . $error));
    }
    if ($http_code !== 200) {
        return json_encode(array('state' => 0, 'msg' => 'HTTP错误: ' . $http_code));
    }
    return $response;
}

// ========== 确定要处理的彩种 ==========
$process_ids = array();
switch ($mode) {
    case 'teqdd':
        $process_ids = array(7);
        break;
    case 'jsssc':
        $process_ids = array(8);
        break;
    case 'collect':
    case 'settle':
    case 'all':
    default:
        $process_ids = array_keys($games);
        break;
}

// ========== 第一步：开奖采集 ==========
if ($mode === 'all' || $mode === 'collect' || $mode === 'teqdd' || $mode === 'jsssc') {
    echo PHP_EOL . "--- 阶段1: 开奖采集 ---" . PHP_EOL;
    foreach ($process_ids as $id) {
        $lotteryname = $games[$id];
        $url = $base_url . '/api.php?op=game_service';
        $post_data = array(
            'gameid' => $id,
            'lotteryname' => $lotteryname,
            'account' => 0,
            'service_token' => SERVICE_TOKEN,  // 安全令牌
        );

        $result = cron_request($url, $post_data, 30);
        $data = json_decode($result, true);

        $name = isset($data['name']) ? $data['name'] : $lotteryname;
        $msg = isset($data['msg']) ? $data['msg'] : '未知';
        $code = isset($data['code']) ? $data['code'] : '-';
        $last = isset($data['last']) ? $data['last'] : '-';
        $state = isset($data['state']) ? $data['state'] : 0;

        if ($state == 1) {
            echo "  [{$lotteryname}] {$name} 第{$last}期 号码:{$code} - {$msg}" . PHP_EOL;
        } else {
            echo "  [{$lotteryname}] {$name} - 失败: {$msg}" . PHP_EOL;
        }
    }
}

// ========== 第二步：注单结算 ==========
if ($mode === 'all' || $mode === 'settle' || $mode === 'teqdd' || $mode === 'jsssc') {
    echo PHP_EOL . "--- 阶段2: 注单结算 ---" . PHP_EOL;
    foreach ($process_ids as $id) {
        $lotteryname = $games[$id];
        $url = $base_url . '/api.php?op=game_service';
        $post_data = array(
            'gameid' => $id,
            'lotteryname' => $lotteryname,
            'account' => 1,
            'service_token' => SERVICE_TOKEN,  // 安全令牌
        );

        $result = cron_request($url, $post_data, 60);
        $data = json_decode($result, true);

        $name = isset($data['name']) ? $data['name'] : $lotteryname;
        $msg = isset($data['msg']) ? $data['msg'] : '未知';
        $state = isset($data['state']) ? $data['state'] : 0;

        if ($state == 1) {
            echo "  [{$lotteryname}] {$name} - {$msg}" . PHP_EOL;
        } else {
            echo "  [{$lotteryname}] {$name} - 结算失败: {$msg}" . PHP_EOL;
        }
    }
}

echo PHP_EOL . "[" . date('Y-m-d H:i:s') . "] ===== cron_service END =====" . PHP_EOL . PHP_EOL;
