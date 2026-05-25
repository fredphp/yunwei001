<?php
defined('IN_MYWEB') or exit('No permission resources.');
base :: load_app_class('admin', 'admin', 0);
class administrator extends admin {
	private $db;

	public function __construct() {
		parent :: __construct(1);
		$this -> db = base :: load_model('admin_model');
	}

	public function init() {
		$page = isset($_GET['page']) && intval($_GET['page']) ? intval($_GET['page']) : 1;
		$list = $this -> db -> listinfo('', 'id DESC', $page, 15);
		$pages = $this -> db -> pages;
		base :: load_sys_class('format', '', 0);
		$issuperarr = array(0 => '信息管理员', 1 => '超级管理');
		include $this -> admin_tpl('administrator_list');
	}

	public function add() {
		$super = $this -> get_userinfo('issuper'); //操作者身份
		if (isset($_POST['dosubmit'])) {
			$username = isset($_POST['username']) && trim($_POST['username']) ? safe_replace(trim($_POST['username'])) : showmessage('请输入用户名！', HTTP_REFERER);
			$password = isset($_POST['password']) && trim($_POST['password']) ? trim($_POST['password']) : showmessage('请输入密码！', HTTP_REFERER);
			$mobile = isset($_POST['mobile']) && trim($_POST['mobile']) ? safe_replace(trim($_POST['mobile'])) : '';
			$issuper = 0;
			if ($super == 1) {
				$issuper = intval($_POST['issuper']);
			}
			if ($this -> db -> get_one(array('username' => $username))) {
				showmessage('用户已存在！', HTTP_REFERER);
			} else {
				if (strlen($username) > 20 || strlen($username) < 3) {
					showmessage('用户名为3-20位之间！', HTTP_REFERER);
				}
				if (strlen($password) > 20 || strlen($password) < 6) {
					showmessage('密码为6-20位之间！', HTTP_REFERER);
				}
				list($password, $encrypt) = creat_password($password);
				if ($this -> db -> insert(array('username' => $username, 'mobile' => $mobile, 'password' => $password, 'encrypt' => $encrypt, 'issuper' => $issuper))) {
					showmessage('管理员添加成功！', 'c=administrator&a=init');
				} else {
					showmessage('操作失败！', HTTP_REFERER);
				}
			}
		}
		include $this -> admin_tpl('administrator_add');
	}

	public function del() {
		$id = intval($_GET['id']);
		if (!$id) {
			echo json_encode(array('run' => 'no', 'msg' => '参数错误！'));
			exit();
		}
		$r = $this -> db -> get_one(array('id' => $id));
		if ($r) {
			if ($r['issuper'] == 1) { // 操作的对象是超级管理身份
				$super = $this -> get_userinfo('issuper'); //操作者身份
				if ($super != 1) { // 操作者不是超级管理员
					echo json_encode(array('run' => 'no', 'msg' => '权限不足！'));
					exit();
				}
				$super_num = $this -> db -> count(array('issuper' => 1));
				if ($super_num <= 1) { // 唯一的超级管理员
					echo json_encode(array('run' => 'no', 'msg' => '至少需要保留一个超级管理员！'));
					exit();
				}
			}
			if ($this -> db -> delete(array('id' => $id))) {
				echo json_encode(array('run' => 'yes', 'msg' => '删除成功！', 'id' => 'list_' . $id));
				exit();
			} else {
				echo json_encode(array('run' => 'no', 'msg' => '删除失败！'));
				exit();
			}
		} else {
			echo json_encode(array('run' => 'no', 'msg' => '未找到对应数据！'));
			exit();
		}
	}

	public function edit() {
		$id = isset($_GET['id']) && intval($_GET['id']) ? intval($_GET['id']) : showmessage('参数错误！', HTTP_REFERER);
		$data = $this -> db -> get_one(array('id' => $id));
		if ($data) {
			$super = $this -> get_userinfo('issuper'); //操作者身份
			if (isset($_POST['dosubmit'])) {
				$issuper = 0;
				if ($super == 1) {
					$issuper = intval($_POST['issuper']);
				}
				if ($data['issuper'] == 1) { // 操作的对象是超级管理身份
					if ($super != 1) { // 操作者不是超级管理员
						showmessage('权限不足！', HTTP_REFERER);
					}
					$super_num = $this -> db -> count(array('issuper' => 1));
					if ($super_num <= 1 && $issuper != 1) { // 唯一的超级管理员
						showmessage('至少需要保留一个超级管理员！', HTTP_REFERER);
					}
				}
				$pwd = isset($_POST['password']) && trim($_POST['password']) ? trim($_POST['password']) : '';
				$update = array('issuper' => $issuper);
				if ($pwd) {
					if (strlen($pwd) > 20 || strlen($pwd) < 6) {
						showmessage('密码为6-20位之间', HTTP_REFERER);
					}
					list($password, $encrypt) = creat_password($pwd);
					$update['password'] = $password;
					$update['encrypt'] = $encrypt;
				}
				$mobile = isset($_POST['mobile']) && trim($_POST['mobile']) ? safe_replace(trim($_POST['mobile'])) : '';
				$update['mobile'] = $mobile;
				if ($this -> db -> update($update, array('id' => $id))) {
					showmessage('修改成功！', 'c=administrator&a=init');
				} else {
					showmessage('修改失败！', HTTP_REFERER);
				}
			}
			$checked[$data['issuper']] = 'checked="checked"';
			include $this -> admin_tpl('administrator_edit');
		} else {
			showmessage('未找到对应数据！', HTTP_REFERER);
		}
	}

	public function ajax_username() {
		$username = isset($_POST['param']) && trim($_POST['param']) ? safe_replace(trim($_POST['param'])) : '';
		if (!$username || $this -> db -> get_one(array('username' => $username))) {
			$msg['info'] = '已存在该用户名！';
			$msg['status'] = 'n';
		} else {
			$msg['info'] = '用户名可以使用！';
			$msg['status'] = 'y';
		}
		echo json_encode($msg);
	}
}
?>