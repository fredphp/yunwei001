<?php
defined('IN_MYWEB') or exit('No permission resources.');
base :: load_app_class('admin', 'admin', 0);

class settings extends admin {
        private $db;

        public function __construct() {
                parent :: __construct(1);
                $this -> db = base :: load_model('settings_model');
        }

        public function init() {
                if (isset($_POST['dosubmit'])) {
                        $setting_arr = $_POST['setting'];
                        if ($_FILES['wxfile']['size'] || $_FILES['alifile']['size']) {//如果选择了上传图片
                                $up = base::load_sys_class('upimg');
                                $up->datedir = false;//不要添加日期目录
                                $up->dir = 'ewm';
                                $up->thumb = 0;
                                if ($_FILES['wxfile']['size']) {//微信
                                        $up->filename = 'wxfile';
                                        $wxreturn = $up->up();
                                        if ($wxreturn['state'] == 'success') {
                                                @unlink('./uppic/ewm/'.$config['wxewm']);//删除原来的图像
                                                $setting_arr['wxewm'] = $wxreturn['info'];
                                        }
                                }
                                if ($_FILES['alifile']['size']) {//支付宝
                                        $up->filename = 'alifile';
                                        $alireturn = $up->up();
                                        if ($alireturn['state'] == 'success') {
                                                @unlink('./uppic/ewm/'.$config['aliewm']);//删除原来的图像
                                                $setting_arr['aliewm'] = $alireturn['info'];
                                        }
                                }
                        }
                        foreach($setting_arr as $k => $v) {
                                $setting[$k] = safe_replace(trim($v));
                                $this -> db -> insert(array('name' => $k , 'data' => safe_replace(trim($v))), 1, 1); //更新数据
                        }
                        // ★ 保存多语言翻译
                        $translatable_fields = array('webname', 'ann', 'copyright', 'description', 'keywords', 'card', 'remark');
                        foreach ($translatable_fields as $field) {
                                if (isset($setting_arr[$field])) {
                                        // 保存英文翻译
                                        $en_key = 'translate_en_us_' . $field;
                                        if (isset($_POST[$en_key]) && trim($_POST[$en_key])) {
                                                T_set('settings', $field, 'value', 'en-us', safe_replace(trim($_POST[$en_key])));
                                        }
                                        // 保存缅甸语翻译
                                        $my_key = 'translate_my_mm_' . $field;
                                        if (isset($_POST[$my_key]) && trim($_POST[$my_key])) {
                                                T_set('settings', $field, 'value', 'my-mm', safe_replace(trim($_POST[$my_key])));
                                        }
                                }
                        }
                        // ★ 同步更新语言设置到 system.php 配置文件
                        if (isset($setting_arr['lang'])) {
                                $supported_langs = array('zh-cn', 'en-us', 'my-mm');
                                $new_lang = safe_replace(trim($setting_arr['lang']));
                                if (in_array($new_lang, $supported_langs)) {
                                        $system_config = base :: load_config('system');
                                        $system_config['lang'] = $new_lang;
                                        write_config($system_config, 'system.php');
                                }
                        }
                        // ★ 保存代理管理数据
                        $this -> save_agents();
                        // 写入本地文件
                        $iscache = base :: load_config('system', 'iscache'); //是否开启设置缓存
                        if ($iscache) write_config($setting, 'setting.php');
                        showmessage('更新成功！', HTTP_REFERER);
                }
                $settingarr = $this -> get_settings(); //读取系统设置
                foreach($settingarr as $k => $v) {
                        $$k = $v;
                }
                // 读取已有翻译
                $translate = array();
                $db_config = base :: load_config('database');
                $tablepre = $db_config['default']['tablepre'];
                base :: load_sys_class('db_factory');
                $db = db_factory :: get_instance($db_config) -> get_database('default');
                $table = $tablepre . 'translate';
                // 先检查翻译表是否存在
                $check_sql = "SHOW TABLES LIKE '$table'";
                $table_exists = $db -> query($check_sql, true);
                if ($table_exists) {
                        $translatable_fields = array('webname', 'ann', 'copyright', 'description', 'keywords', 'card', 'remark');
                        $field_list = "'" . implode("','", $translatable_fields) . "'";
                        $sql = "SELECT `source_id`, `lang`, `value` FROM `$table` WHERE `source_table`='settings' AND `source_id` IN ($field_list) AND `field_name`='value'";
                        $db -> query($sql);
                        while ($row = $db -> fetch_next()) {
                                $translate[$row['source_id'] . '_' . $row['lang']] = $row['value'];
                        }
                }
                // ★ 读取代理列表
                $agent_list = $this -> get_agent_list();
                include $this -> admin_tpl('settings');
        }

        // ★ 获取代理列表
        private function get_agent_list() {
                $agent_db = base :: load_model('agent_model');
                $list = $agent_db -> select('', '*', '', 'id ASC');
                return $list ? $list : array();
        }

        // ★ 保存代理管理数据
        private function save_agents() {
                $agent_db = base :: load_model('agent_model');
                $user_db = base :: load_model('user_model');

                // 1. 处理已删除的代理
                $deleted = isset($_POST['agent_deleted']) ? trim($_POST['agent_deleted']) : '';
                if ($deleted) {
                        $del_ids = array_map('intval', explode(',', $deleted));
                        foreach ($del_ids as $did) {
                                if ($did > 0) {
                                        // 将关联该代理的用户重置为普通账户
                                        $user_db -> update(array('aid' => 0, 'agent_id' => 0, 'agent' => 0, 'agents' => 0), array('agent_id' => $did));
                                        $agent_db -> delete(array('id' => $did));
                                }
                        }
                }

                // 2. 更新已有代理
                if (isset($_POST['agent_list']) && is_array($_POST['agent_list'])) {
                        foreach ($_POST['agent_list'] as $id => $data) {
                                $id = intval($id);
                                if ($id > 0) {
                                        $update = array(
                                                'name' => safe_replace(trim($data['name'])),
                                                'rebate' => round(floatval($data['rebate']), 2),
                                                'state' => intval($data['state']) ? 1 : 0
                                        );
                                        $agent_db -> update($update, array('id' => $id));
                                        // 如果停用代理，将关联用户的aid设为0
                                        if ($update['state'] == 0) {
                                                $user_db -> update(array('aid' => 0), array('agent_id' => $id));
                                        } elseif ($update['state'] == 1) {
                                                // 如果启用代理，将关联用户的aid设为1
                                                $user_db -> update(array('aid' => 1), array('agent_id' => $id));
                                        }
                                }
                        }
                }

                // 3. 新增代理
                if (isset($_POST['agent_new']) && is_array($_POST['agent_new'])) {
                        foreach ($_POST['agent_new'] as $data) {
                                $name = safe_replace(trim($data['name']));
                                if (empty($name)) continue; // 跳过空名称
                                $insert = array(
                                        'name' => $name,
                                        'rebate' => round(floatval($data['rebate']), 2),
                                        'state' => intval($data['state']) ? 1 : 0,
                                        'addtime' => SYS_TIME
                                );
                                $agent_db -> insert($insert);
                        }
                }
        }

        // ★ AJAX获取代理列表（供其他页面使用）
        public function ajax_get_agents() {
                $agent_db = base :: load_model('agent_model');
                $list = $agent_db -> select("state = 1", 'id,name,rebate', '', 'id ASC');
                header('Content-Type: application/json; charset=utf-8');
                echo json_encode($list ? $list : array());
                exit();
        }
}
?>
