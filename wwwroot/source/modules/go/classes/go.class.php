<?php
class go {

        //private $db;

        // 登录错误码
        public $err_code = 0;

        public function __construct() {

        }

        // 获取详细错误信息
        public function get_err() {
                $msg = array(
                        '0' => '未知错误，请重试',
                        '1' => '用户名不存在',
                        '2' => '密码错误',
                        '3' => '账户已被锁定，禁止登录',
                        '4' => '数据库查询失败（可能是字符集或连接问题）',
                );
                return isset($msg[$this -> err_code]) ? $msg[$this -> err_code] : $msg['0'];
        }

        // 检查USER登录情况
        //$username 用户名
        //$password 用户密码，提供此参数进行登录
        public function check_user($username = '', $password = '') {
                $db = base :: load_model('user_model');
                if ($username && $password) {//使用 用户名 + 密码验证 登录
                        $udb = $db -> get_one(array('username' => safe_replace($username)));
                        if ($udb) {//存在这个号码
                                $password = md5(md5($password) . $udb['encrypt']);//处理比对前的密码
                                if ($password == $udb['password']) {
                                        if ($udb['lock'] == 1) {//如果被锁定禁止登录
                                                $this -> err_code = 3;
                                                return false;
                                        }
                                        $db -> update(array('loginip' => get_onlineip(), 'logintime' => SYS_TIME), array('uid' => $udb['uid']));
                                        $pwd = md5($udb['uid'] . $udb['password']);
                                        set_cookie(array('uid', 'password'), array($udb['uid'], $pwd), 7 * 86400);
                                        return $udb;
                                } else {
                                        $this -> err_code = 2;
                                        return false;
                                }
                        } else {
                                $this -> err_code = 1;
                                return false;
                        }
                } else {//检查COOKIE登录状态
                        $uid = get_cookie('uid');
                        $pwd = get_cookie('password');
                        if (!$uid || !$pwd) return false;
                        $udb = $db -> get_one(array('uid' => intval($uid)));
                        if ($udb && $pwd == md5($udb['uid'] . $udb['password'])) {
                                if ($udb['lock'] == 1) {//如果被锁定禁止登录
                                        return false;
                                }
                                return $udb;
                        } else {
                                return false;
                        }
                }
        }

        // 检查验证码
        public function check_code($code) {
                if (!$code) return false;
                if (get_cookie('code') == strtolower($code)) {
                        return true;
                } else {
                        return false;
                }
        }

        // 存入登录COOKIE
        public function set_pwcode($username, $pwcode) {
                set_cookie('pwcode', md5($username . $pwcode));
        }

        // 获取系统设置信息
        public function get_settings($filed = '') {
                $iscache = base :: load_config('system', 'iscache'); //是否开启设置缓存
                if ($iscache) {
                        $settingdata = base :: load_config('setting');
                        if ($filed) {
                                $current_lang = defined('ROUTE_LANG') ? ROUTE_LANG : 'zh-cn';
                                if ($current_lang !== 'zh-cn') {
                                        $translated = T('settings', $filed, 'value', $settingdata[$filed]);
                                        if ($translated !== $settingdata[$filed]) {
                                                return $translated;
                                        }
                                }
                                return $settingdata[$filed];
                        } else {
                                // 应用翻译到可翻译字段
                                $current_lang = defined('ROUTE_LANG') ? ROUTE_LANG : 'zh-cn';
                                if ($current_lang !== 'zh-cn') {
                                        $translatable_fields = array('webname', 'ann', 'copyright', 'description', 'card', 'remark');
                                        foreach ($translatable_fields as $field) {
                                                if (isset($settingdata[$field])) {
                                                        $translated = T('settings', $field, 'value', $settingdata[$field]);
                                                        if ($translated !== $settingdata[$field]) {
                                                                $settingdata[$field] = $translated;
                                                        }
                                                }
                                        }
                                }
                                return $settingdata;
                        }
                } else {
                        $setdb = base :: load_model('settings_model');
                        if ($filed) {
                                $settingdata = $setdb -> get_one(array('name' => $filed));
                                $current_lang = defined('ROUTE_LANG') ? ROUTE_LANG : 'zh-cn';
                                if ($current_lang !== 'zh-cn' && $settingdata) {
                                        $translated = T('settings', $filed, 'value', $settingdata['data']);
                                        if ($translated !== $settingdata['data']) {
                                                return $translated;
                                        }
                                }
                                return $settingdata['data'];
                        } else {
                                $settingdata = $setdb -> select();
                                foreach($settingdata as $k => $v) {
                                        $settingarr[$v['name']] = $v['data'];
                                }
                                // 应用翻译到可翻译字段
                                $current_lang = defined('ROUTE_LANG') ? ROUTE_LANG : 'zh-cn';
                                if ($current_lang !== 'zh-cn') {
                                        $translatable_fields = array('webname', 'ann', 'copyright', 'description', 'card', 'remark');
                                        foreach ($translatable_fields as $field) {
                                                if (isset($settingarr[$field])) {
                                                        $translated = T('settings', $field, 'value', $settingarr[$field]);
                                                        if ($translated !== $settingarr[$field]) {
                                                                $settingarr[$field] = $translated;
                                                        }
                                                }
                                        }
                                }
                                return $settingarr;
                        }
                }
        }
}
