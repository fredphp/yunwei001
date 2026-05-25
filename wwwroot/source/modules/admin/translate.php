<?php
defined('IN_MYWEB') or exit('No permission resources.');
base :: load_app_class('admin', 'admin', 0);

class translate extends admin {
        private $db;
        private $translate_table;

        public function __construct() {
                parent :: __construct(1);
                $this -> db = base :: load_model('settings_model');
                $db_config = base :: load_config('database');
                $tablepre = $db_config['default']['tablepre'];
                $this -> translate_table = $tablepre . 'translate';
        }

        /**
         * 获取数据库连接（确保db_factory已加载）
         */
        private function get_db() {
                static $db = null;
                if ($db === null) {
                        $db_config = base :: load_config('database');
                        base :: load_sys_class('db_factory');
                        $db = db_factory :: get_instance($db_config) -> get_database('default');
                }
                return $db;
        }

        /**
         * 确保翻译表存在
         */
        private function ensure_table() {
                $db = $this -> get_db();
                $check = $db -> query("SHOW TABLES LIKE '{$this -> translate_table}'", true);
                if (empty($check)) {
                        $create_sql = "CREATE TABLE IF NOT EXISTS `{$this -> translate_table}` (
                                `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
                                `source_table` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '源表名',
                                `source_id` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '源记录ID或键名',
                                `field_name` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '字段名',
                                `lang` VARCHAR(10) NOT NULL DEFAULT '' COMMENT '语言代码',
                                `value` TEXT COMMENT '翻译内容',
                                PRIMARY KEY (`id`),
                                UNIQUE KEY `idx_translate_unique` (`source_table`, `source_id`, `field_name`, `lang`),
                                KEY `idx_translate_lookup` (`source_table`, `lang`),
                                KEY `idx_translate_source` (`source_table`, `source_id`)
                        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据库内容多语言翻译表'";
                        $db -> query($create_sql);
                }
        }

        /**
         * 翻译列表（主页）
         */
        public function init() {
                $this -> ensure_table();
                $db = $this -> get_db();
                $table = $this -> translate_table;

                // 筛选参数
                $filter_table = isset($_GET['filter_table']) ? trim($_GET['filter_table']) : '';
                $filter_lang = isset($_GET['filter_lang']) ? trim($_GET['filter_lang']) : '';
                $filter_keyword = isset($_GET['filter_keyword']) ? trim($_GET['filter_keyword']) : '';

                // 分页
                $page = isset($_GET['page']) && intval($_GET['page']) ? intval($_GET['page']) : 1;
                $pagesize = 20;

                // 构建WHERE条件
                $where = "1=1";
                if ($filter_table) {
                        $where .= " AND `source_table`='" . addslashes($filter_table) . "'";
                }
                if ($filter_lang) {
                        $where .= " AND `lang`='" . addslashes($filter_lang) . "'";
                }
                if ($filter_keyword) {
                        $where .= " AND (`value` LIKE '%" . addslashes($filter_keyword) . "%' OR `source_id` LIKE '%" . addslashes($filter_keyword) . "%')";
                }

                // 统计总数
                $count_sql = "SELECT COUNT(*) AS num FROM `{$table}` WHERE {$where}";
                $count_row = $db -> query($count_sql, true);
                $total = $count_row ? intval($count_row['num']) : 0;
                $totalpages = $total > 0 ? ceil($total / $pagesize) : 1;
                if ($page > $totalpages) $page = $totalpages;
                if ($page < 1) $page = 1;
                $offset = ($page - 1) * $pagesize;

                // 查询数据
                $sql = "SELECT * FROM `{$table}` WHERE {$where} ORDER BY `source_table` ASC, `source_id` ASC, `lang` ASC LIMIT {$offset}, {$pagesize}";
                $db -> query($sql);
                $list = array();
                while ($row = $db -> fetch_next()) {
                        $list[] = $row;
                }

                // 获取所有源表名（用于筛选下拉框）
                $db -> query("SELECT DISTINCT `source_table` FROM `{$table}` ORDER BY `source_table` ASC");
                $source_tables = array();
                while ($row = $db -> fetch_next()) {
                        $source_tables[] = $row['source_table'];
                }

                // 源表名中文映射
                $table_labels = array(
                        'game' => '游戏名称',
                        'settings' => '系统设置',
                        'account_type' => '账户类型',
                        'cash_state' => '提现状态',
                        'pay_state' => '充值状态',
                        'game_state' => '游戏状态',
                        'user_role' => '用户角色',
                );

                // 语言映射
                $lang_labels = array(
                        'zh-cn' => '中文',
                        'en-us' => 'English',
                        'my-mm' => 'မြန်မာ',
                );

                include $this -> admin_tpl('translate_list');
        }

        /**
         * 添加翻译
         */
        public function add() {
                $this -> ensure_table();

                if (isset($_POST['dosubmit'])) {
                        $source_table = isset($_POST['source_table']) ? trim($_POST['source_table']) : '';
                        $source_id = isset($_POST['source_id']) ? trim($_POST['source_id']) : '';
                        $field_name = isset($_POST['field_name']) ? trim($_POST['field_name']) : '';
                        $lang = isset($_POST['lang']) ? trim($_POST['lang']) : '';
                        $value = isset($_POST['value']) ? trim($_POST['value']) : '';

                        if (!$source_table || !$source_id || !$field_name || !$lang) {
                                showmessage('请填写完整信息！', HTTP_REFERER);
                        }

                        T_set($source_table, $source_id, $field_name, $lang, $value);
                        showmessage('添加成功！', 'c=translate');
                }

                // 获取可翻译的源表列表
                $translatable_sources = array(
                        'game' => '游戏 (bc_game)',
                        'settings' => '系统设置 (bc_settings)',
                        'account_type' => '账户类型',
                        'cash_state' => '提现状态',
                        'pay_state' => '充值状态',
                        'game_state' => '游戏状态',
                        'user_role' => '用户角色',
                );

                $lang_labels = array(
                        'en-us' => 'English',
                        'my-mm' => 'မြန်မာ (Myanmar)',
                );

                include $this -> admin_tpl('translate_add');
        }

        /**
         * 编辑翻译
         */
        public function edit() {
                $this -> ensure_table();
                $db = $this -> get_db();
                $table = $this -> translate_table;

                $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
                if (!$id) showmessage('参数错误！', HTTP_REFERER);

                if (isset($_POST['dosubmit'])) {
                        $value = isset($_POST['value']) ? trim($_POST['value']) : '';
                        $source_table = isset($_POST['source_table']) ? addslashes(trim($_POST['source_table'])) : '';
                        $source_id = isset($_POST['source_id']) ? addslashes(trim($_POST['source_id'])) : '';
                        $field_name = isset($_POST['field_name']) ? addslashes(trim($_POST['field_name'])) : '';
                        $lang = isset($_POST['lang']) ? addslashes(trim($_POST['lang'])) : '';

                        $s_value = addslashes($value);
                        $sql = "UPDATE `{$table}` SET `value`='{$s_value}' WHERE `id`={$id}";
                        $db -> query($sql);
                        showmessage('修改成功！', 'c=translate');
                }

                // 读取当前记录
                $row = $db -> query("SELECT * FROM `{$table}` WHERE `id`={$id} LIMIT 1", true);
                if (!$row) showmessage('记录不存在！', 'c=translate');

                $lang_labels = array(
                        'zh-cn' => '中文',
                        'en-us' => 'English',
                        'my-mm' => 'မြန်မာ',
                );

                $table_labels = array(
                        'game' => '游戏名称',
                        'settings' => '系统设置',
                        'account_type' => '账户类型',
                        'cash_state' => '提现状态',
                        'pay_state' => '充值状态',
                        'game_state' => '游戏状态',
                        'user_role' => '用户角色',
                );

                include $this -> admin_tpl('translate_edit');
        }

        /**
         * 删除翻译
         */
        public function del() {
                $this -> ensure_table();
                $db = $this -> get_db();
                $table = $this -> translate_table;

                $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
                if (!$id) {
                        echo json_encode(array('run' => 'no', 'msg' => '参数错误！'));
                        exit();
                }

                $sql = "DELETE FROM `{$table}` WHERE `id`={$id}";
                if ($db -> query($sql)) {
                        echo json_encode(array('run' => 'yes', 'msg' => '删除成功！', 'id' => 'list_' . $id));
                } else {
                        echo json_encode(array('run' => 'no', 'msg' => '删除失败！'));
                }
                exit();
        }

        /**
         * 批量删除
         */
        public function delall() {
                $this -> ensure_table();
                $db = $this -> get_db();
                $table = $this -> translate_table;

                $ids = isset($_POST['ids']) ? $_POST['ids'] : '';
                if (!$ids) {
                        echo json_encode(array('run' => 'no', 'msg' => '请选择要删除的记录！'));
                        exit();
                }

                $id_arr = array_map('intval', explode(',', $ids));
                $id_list = implode(',', $id_arr);
                $sql = "DELETE FROM `{$table}` WHERE `id` IN ({$id_list})";
                if ($db -> query($sql)) {
                        echo json_encode(array('run' => 'yes', 'msg' => '批量删除成功！'));
                } else {
                        echo json_encode(array('run' => 'no', 'msg' => '批量删除失败！'));
                }
                exit();
        }

        /**
         * 获取源表原文（AJAX）
         * 当选择源表和源ID后，自动获取中文原文
         */
        public function ajax_get_source() {
                $this -> ensure_table();
                $db = $this -> get_db();
                $db_config = base :: load_config('database');
                $tablepre = $db_config['default']['tablepre'];

                $source_table = isset($_GET['source_table']) ? addslashes(trim($_GET['source_table'])) : '';

                $results = array();
                switch ($source_table) {
                        case 'game':
                                $db -> query("SELECT id, name FROM `{$tablepre}game` ORDER BY id ASC");
                                while ($row = $db -> fetch_next()) {
                                        $results[] = array('id' => $row['id'], 'name' => $row['name']);
                                }
                                break;
                        case 'settings':
                                $translatable = array('webname', 'ann', 'copyright', 'description', 'card', 'remark', 'keywords', 'qq', 'code');
                                $field_list = "'" . implode("','", $translatable) . "'";
                                $db -> query("SELECT `name`, `data` FROM `{$tablepre}settings` WHERE `name` IN ({$field_list}) ORDER BY `name` ASC");
                                while ($row = $db -> fetch_next()) {
                                        $results[] = array('id' => $row['name'], 'name' => $row['name'] . ': ' . mb_substr($row['data'], 0, 30, 'UTF-8'));
                                }
                                break;
                        case 'account_type':
                                for ($i = 0; $i <= 4; $i++) {
                                        $labels = array('充值', '提现', '投注', '盈利', '退单');
                                        $results[] = array('id' => $i, 'name' => $labels[$i]);
                                }
                                break;
                        case 'cash_state':
                                for ($i = 0; $i <= 3; $i++) {
                                        $labels = array('等待处理', '正在处理', '提现完成', '提现失败');
                                        $results[] = array('id' => $i, 'name' => $labels[$i]);
                                }
                                break;
                        case 'pay_state':
                                for ($i = 0; $i <= 1; $i++) {
                                        $labels = array('未支付', '已支付');
                                        $results[] = array('id' => $i, 'name' => $labels[$i]);
                                }
                                break;
                        case 'game_state':
                                for ($i = 0; $i <= 1; $i++) {
                                        $labels = array('停用', '启用');
                                        $results[] = array('id' => $i, 'name' => $labels[$i]);
                                }
                                break;
                        case 'user_role':
                                for ($i = 0; $i <= 1; $i++) {
                                        $labels = array('会员', '代理');
                                        $results[] = array('id' => $i, 'name' => $labels[$i]);
                                }
                                break;
                }

                header('Content-Type: application/json; charset=utf-8');
                echo json_encode($results);
                exit();
        }
}
?>
