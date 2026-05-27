<?php
defined('IN_MYWEB') or exit('No permission resources.');
base :: load_app_class('admin', 'admin', 0);
class agent_rebate extends admin {
	private $db;

	public function __construct() {
		parent :: __construct(1);
		$this -> db = base :: load_model('agent_rebate_log_model');
	}

	public function init() {
		$page = isset($_GET['page']) && intval($_GET['page']) ? intval($_GET['page']) : 1;
		$list = $this -> db -> listinfo('', 'id DESC', $page, 20);
		$pages = $this -> db -> pages;
		base :: load_sys_class('format', '', 0);
		// ★ 获取代理列表用于显示名称
		$agent_db = base :: load_model('agent_model');
		$agent_list = $agent_db -> select('', 'id,name,rebate', '', 'id ASC');
		$agent_names = array();
		if ($agent_list) {
			foreach ($agent_list as $ag) {
				$agent_names[$ag['id']] = $ag['name'];
			}
		}
		// ★ 获取用户名映射
		$user_db = base :: load_model('user_model');
		include $this -> admin_tpl('agent_rebate_list');
	}

	public function search() {
		$where = "";
		if (is_array($_GET['search'])) {
			$uid = isset($_GET['search']['uid']) ? intval($_GET['search']['uid']) : '';
			$agent_id = isset($_GET['search']['agent_id']) ? intval($_GET['search']['agent_id']) : '';
			$start_time = isset($_GET['search']['start_time']) ? $_GET['search']['start_time'] : '';
			$end_time = isset($_GET['search']['end_time']) ? $_GET['search']['end_time'] : '';
		}
		if ($uid) $where .= $where ? " AND uid='$uid'" : "uid='$uid'";
		if ($agent_id) $where .= $where ? " AND agent_id='$agent_id'" : "agent_id='$agent_id'";
		if ($start_time) {
			$time_start = strtotime($start_time);
			$where .= $where ? " AND addtime >= '$time_start'" : "addtime >= '$time_start'";
		}
		if ($end_time) {
			$time_end = strtotime($end_time);
			$where .= $where ? " AND addtime <= '$time_end'" : "addtime <= '$time_end'";
		}
		$page = isset($_GET['page']) && intval($_GET['page']) ? intval($_GET['page']) : 1;
		$list = $this -> db -> listinfo($where, 'id DESC', $page, 20);
		$pages = $this -> db -> pages;
		base :: load_sys_class('format', '', 0);
		// ★ 获取代理列表
		$agent_db = base :: load_model('agent_model');
		$agent_list = $agent_db -> select('', 'id,name,rebate', '', 'id ASC');
		$agent_names = array();
		if ($agent_list) {
			foreach ($agent_list as $ag) {
				$agent_names[$ag['id']] = $ag['name'];
			}
		}
		$user_db = base :: load_model('user_model');
		include $this -> admin_tpl('agent_rebate_list');
	}

	public function del() {
		$id = intval($_GET['id']);
		if (!$id) {
			echo json_encode(array('run' => 'no', 'msg' => '参数错误！'));
			exit();
		}
		if ($this -> db -> delete(array('id' => $id))) {
			echo json_encode(array('run' => 'yes', 'msg' => '删除成功！', 'id' => 'list_' . $id));
			exit();
		} else {
			echo json_encode(array('run' => 'no', 'msg' => '删除失败！'));
			exit();
		}
	}
}
?>
