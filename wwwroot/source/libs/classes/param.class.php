<?php
/**
 * param.class.php 参数处理类
 * 
 * @copyright (C) 2005-2014 LEYUN360 Inc.
 * @license This is a charge software, licensing terms
 * @lastmodify 2010-12-16
 * $Id: param.class.php 2 2010-12-16 10:59:13Z LEYUN360 $
 */
class param {
        // 路由配置
        private $route_config = '';

        // 允许的模块白名单（防止路径遍历）
        private $allowed_modules = array('admin', 'daili', 'go');

        // 允许的控制器白名单（防止路径遍历）
        private $allowed_controllers = array(
                'admin' => array('index', 'login', 'account', 'administrator', 'cash', 'game', 'order', 'pay', 'settings', 'translate', 'user', 'userset'),
                'daili' => array('index', 'login', 'account', 'cash', 'order', 'pay', 'user', 'userset'),
                'go'    => array('index')
        );

        public function __construct() {
                // get_magic_quotes_gpc() 在 PHP 7.4 已废弃，始终返回 false
                // PHP 5.4+ magic quotes 已移除，所以始终需要转义
                if (version_compare(PHP_VERSION, '7.4.0', '>=')) {
                        $_POST = new_addslashes($_POST);
                        $_GET = new_addslashes($_GET);
                        $_COOKIE = new_addslashes($_COOKIE);
                } elseif (!get_magic_quotes_gpc()) {
                        $_POST = new_addslashes($_POST);
                        $_GET = new_addslashes($_GET);
                        $_COOKIE = new_addslashes($_COOKIE);
                } 
                $this -> route_config = base :: load_config('route', SITE_URL) ? base :: load_config('route', SITE_URL) : base :: load_config('route', 'default');

                if (isset($this -> route_config['data']['POST']) && is_array($this -> route_config['data']['POST'])) {
                        foreach($this -> route_config['data']['POST'] as $_key => $_value) {
                                if (!isset($_POST[$_key])) $_POST[$_key] = $_value;
                        } 
                } 
                if (isset($this -> route_config['data']['GET']) && is_array($this -> route_config['data']['GET'])) {
                        foreach($this -> route_config['data']['GET'] as $_key => $_value) {
                                if (!isset($_GET[$_key])) $_GET[$_key] = $_value;
                        } 
                } 
                return true;
        } 

        /**
         * 获取模型（带白名单验证，防止路径遍历）
         */
        public function route_m() {
                $m = isset($_GET['m']) && !empty($_GET['m']) ? $_GET['m'] : (isset($_POST['m']) && !empty($_POST['m']) ? $_POST['m'] : '');
                if (empty($m)) {
                        return $this -> route_config['m'];
                }
                // 安全检查：只允许白名单中的模块
                if (!in_array($m, $this->allowed_modules)) {
                        header('HTTP/1.1 404 Not Found');
                        exit('Invalid module');
                }
                // 额外检查：不允许包含路径字符
                if (strpos($m, '/') !== false || strpos($m, '\\\\') !== false || strpos($m, '.') !== false) {
                        header('HTTP/1.1 404 Not Found');
                        exit('Invalid module');
                }
                return $m;
        } 

        /**
         * 获取控制器（带白名单验证，防止路径遍历）
         */
        public function route_c() {
                $c = isset($_GET['c']) && !empty($_GET['c']) ? $_GET['c'] : (isset($_POST['c']) && !empty($_POST['c']) ? $_POST['c'] : '');
                if (empty($c)) {
                        return $this -> route_config['c'];
                }
                // 安全检查：不允许包含路径字符
                if (strpos($c, '/') !== false || strpos($c, '\\\\') !== false || strpos($c, '.') !== false) {
                        header('HTTP/1.1 404 Not Found');
                        exit('Invalid controller');
                }
                // 安全检查：只允许字母数字和下划线
                if (!preg_match('/^[a-zA-Z_][a-zA-Z0-9_]*$/', $c)) {
                        header('HTTP/1.1 404 Not Found');
                        exit('Invalid controller');
                }
                return $c;
        } 

        /**
         * 获取事件
         */
        public function route_a() {
                $a = isset($_GET['a']) && !empty($_GET['a']) ? $_GET['a'] : (isset($_POST['a']) && !empty($_POST['a']) ? $_POST['a'] : '');
                if (empty($a)) {
                        return $this -> route_config['a'];
                }
                // 安全检查：只允许字母数字和下划线
                if (!preg_match('/^[a-zA-Z_][a-zA-Z0-9_]*$/', $a)) {
                        header('HTTP/1.1 404 Not Found');
                        exit('Invalid action');
                }
                return $a;
        } 

        /**
         * 获取语言
         * 支持三语言: zh-cn, en-us, my-mm
         * 语言优先级:
         *   1. 用户前端切换 (cookie: user_lang，前端语言切换按钮设置)
         *   2. URL参数 (?lang=zh-cn 或 ?lang=my-mm)
         *   3. 后台管理设置 (configs/setting.php 缓存)
         *   4. 系统配置 (configs/system.php 的 'lang' 字段)
         *   5. 默认 zh-cn
         */
        public function route_lang() {
                $supported_langs = array('zh-cn', 'en-us', 'my-mm');
                $lang = '';

                // 优先级1: 用户前端切换的cookie (user_lang 为明文cookie，不经sys_auth加密)
                if (isset($_COOKIE['user_lang']) && in_array($_COOKIE['user_lang'], $supported_langs)) {
                        return $_COOKIE['user_lang'];
                }

                // 优先级2: URL参数
                if (isset($_GET['lang']) && in_array($_GET['lang'], $supported_langs)) {
                        return $_GET['lang'];
                }

                // 优先级3: 从后台管理设置中读取
                $settingdata = base :: load_config('setting');
                if (is_array($settingdata) && isset($settingdata['lang']) && !empty($settingdata['lang'])) {
                        $lang = $settingdata['lang'];
                }
                // 优先级4: 从系统配置读取
                if (empty($lang) || !in_array($lang, $supported_langs)) {
                        $lang = base :: load_config('system', 'lang');
                }
                if (empty($lang) || !in_array($lang, $supported_langs)) {
                        $lang = 'zh-cn'; // 默认中文
                }
                return $lang;
        } 
} 

