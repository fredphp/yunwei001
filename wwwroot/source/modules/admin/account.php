<?php
defined('IN_MYWEB') or exit('No permission resources.');
base::load_app_class('admin','admin',0);
class account extends admin{

	private $db, $type;

	public function __construct() {
		parent::__construct(1);
		$this->db = base::load_model('account_model');
		$this->type = array(
			0 => '<span style="color: #FFA700;">充值</span>',
			1 => '<span style="color: #0070FF;">提现</span>',
			2 => '<span style="color: #00B520;">投注</span>',
			3 => '<span style="color: #FF0000;">盈利</span>',
			4 => '<span style="color: #FF00DE;">退单</span>',
			5 => '<span style="color: #F60;">红包</span>'
		);
	}

	public function init() {
		$page = isset($_GET['page']) && intval($_GET['page']) ? intval($_GET['page']) : 1;
		$list = $this->db->listinfo('', 'id DESC', $page, 15);
		$pages = $this->db->pages;
		base::load_sys_class('format', '', 0);

		include $this->admin_tpl('account_list');
	}

	public function search() {
 		$where = "";
		if(is_array($_GET['search'])) {
			$uid = isset($_GET['search']['uid']) ? $_GET['search']['uid'] : '';
			$type = isset($_GET['search']['type']) ? $_GET['search']['type'] : '';
			$state = isset($_GET['search']['state']) ? $_GET['search']['state'] : '';
			$gameid = isset($_GET['search']['gameid']) ? $_GET['search']['gameid'] : '';
			$qishu = isset($_GET['search']['qishu']) ? $_GET['search']['qishu'] : '';
			$orderid = isset($_GET['search']['orderid']) ? $_GET['search']['orderid'] : '';
			$agent = isset($_GET['search']['agent']) ? $_GET['search']['agent'] : '';
			$agents = isset($_GET['search']['agents']) ? $_GET['search']['agents'] : '';
			$aid = isset($_GET['search']['aid']) ? $_GET['search']['aid'] : '';
			$payid = isset($_GET['search']['payid']) ? $_GET['search']['payid'] : '';
			$username = isset($_GET['search']['username']) ? $_GET['search']['username'] : '';
			$start_time = isset($_GET['search']['start_time']) ? $_GET['search']['start_time'] : '';
			$end_time = isset($_GET['search']['end_time']) ? $_GET['search']['end_time'] : '';
		}
		$search_uid = intval($uid);
		$search_type = intval($type);
		$typeoption[$search_type] = 'selected="selected"';
		if($search_uid) $where .= $where ?  " AND uid='$search_uid'" : "uid='$search_uid'";
		if($search_type){
			if($search_type == 5) $search_type = 0;
			$where .= $where ?  " AND type='$search_type'" : "type='$search_type'";
		}
		$page = isset($_GET['page']) && intval($_GET['page']) ? intval($_GET['page']) : 1;
		$list = $this->db->listinfo($where, 'id DESC', $page, 15);
 		$pages = $this->db->pages;
		base::load_sys_class('format', '', 0);
 		include $this->admin_tpl('account_list');
	}

	public function del() {
		if ($_POST['type']) { // 批量操作
			//showmessage('禁止操作！', HTTP_REFERER);
			if (!is_array($_POST['id'])) { // 不是数组列
				showmessage('请先选择再执行操作！', HTTP_REFERER);
			}
			foreach($_POST['id'] as $v) {
				$idadd[] = intval($v);
			}
			$where = "id IN (" . implode(",", $idadd) . ")";
			$this -> db -> delete($where);
			showmessage('删除成功！', 'c=account&a=init');
		} else { // 单条操作
			//echo json_encode(array('run' => 'no', 'msg' => '禁止操作！'));
			//exit();
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

	public function delall() {
		$time = SYS_TIME - (86400 * 30 * 3);
		$where = "addtime <= '$time'";
		if ($this -> db -> delete($where)) {
			echo json_encode(array('run' => 'yes', 'msg' => '清理完成！'));
			exit();
		} else {
			echo json_encode(array('run' => 'no', 'msg' => '清理失败！'));
			exit();
		}
	}
}