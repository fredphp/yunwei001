<?php
defined('IN_MYWEB') or exit('No permission resources.');
base :: load_app_class('daili', 'daili', 0);

class commission extends daili {

	private $db, $db2, $db3, $uid, $username;

	public function __construct() {
		parent :: __construct();
		$this -> db = base :: load_model('agent_rebate_log_model');
		$this -> db2 = base :: load_model('user_model');
		$this -> db3 = base :: load_model('agent_model');
		$this -> uid = intval($this -> get_userid());
		$this -> username = trim($this -> get_username());
	}

	// ★ 统一入口：汇总信息 + 默认显示所有分成明细 + 搜索 + 分页
	public function init() {
		// 获取当前代理信息
		$agent_info = $this -> db2 -> get_one(array('uid' => $this -> uid));
		// 获取代理配置
		$agent_config = array();
		if ($agent_info['agent_id'] > 0) {
			$agent_config = $this -> db3 -> get_one(array('id' => $agent_info['agent_id']));
		}
		// 今日分成
		$starttime = strtotime(date('Y-m-d'));
		$today_commission = $this -> db -> select("agent_uid = '$this->uid' AND addtime >= '$starttime'", 'SUM(rebate_money) as total');
		$today_total = $today_commission[0]['total'] ? $today_commission[0]['total'] : 0;
		// 昨日分成
		$starttime_y = strtotime(date('Y-m-d')) - 86400;
		$endtime_y = strtotime(date('Y-m-d'));
		$yesterday_commission = $this -> db -> select("agent_uid = '$this->uid' AND addtime >= '$starttime_y' AND addtime < '$endtime_y'", 'SUM(rebate_money) as total');
		$yesterday_total = $yesterday_commission[0]['total'] ? $yesterday_commission[0]['total'] : 0;
		// 本月分成
		$starttime_m = mktime(0, 0, 0, date('m'), 1, date('Y'));
		$month_commission = $this -> db -> select("agent_uid = '$this->uid' AND addtime >= '$starttime_m'", 'SUM(rebate_money) as total');
		$month_total = $month_commission[0]['total'] ? $month_commission[0]['total'] : 0;
		// 上月分成
		$starttime_lm = mktime(0, 0, 0, date('m')-1, 1, date('Y'));
		$endtime_lm = mktime(23, 59, 59, date('m'), 0, date('Y'));
		$lastmonth_commission = $this -> db -> select("agent_uid = '$this->uid' AND addtime >= '$starttime_lm' AND addtime < '$endtime_lm'", 'SUM(rebate_money) as total');
		$lastmonth_total = $lastmonth_commission[0]['total'] ? $lastmonth_commission[0]['total'] : 0;
		// 今日流水
		$order_db = base :: load_model('order_model');
		$today_flow = $order_db -> select("agent = '$this->uid' AND tui = 0 AND addtime >= '$starttime'", 'SUM(money) as total');
		$today_flow_total = $today_flow[0]['total'] ? $today_flow[0]['total'] : 0;
		// 昨日流水
		$yesterday_flow = $order_db -> select("agent = '$this->uid' AND tui = 0 AND addtime >= '$starttime_y' AND addtime < '$endtime_y'", 'SUM(money) as total');
		$yesterday_flow_total = $yesterday_flow[0]['total'] ? $yesterday_flow[0]['total'] : 0;
		// 本月流水
		$month_flow = $order_db -> select("agent = '$this->uid' AND tui = 0 AND addtime >= '$starttime_m'", 'SUM(money) as total');
		$month_flow_total = $month_flow[0]['total'] ? $month_flow[0]['total'] : 0;
		// 上月流水
		$lastmonth_flow = $order_db -> select("agent = '$this->uid' AND tui = 0 AND addtime >= '$starttime_lm' AND addtime < '$endtime_lm'", 'SUM(money) as total');
		$lastmonth_flow_total = $lastmonth_flow[0]['total'] ? $lastmonth_flow[0]['total'] : 0;

		// ★ 分成明细列表（默认显示所有，支持搜索筛选+分页）
		$where = "agent_uid = '$this->uid'";
		$search_uid = isset($_GET['search']['uid']) ? intval($_GET['search']['uid']) : '';
		$start_time = isset($_GET['search']['start_time']) ? trim($_GET['search']['start_time']) : '';
		$end_time = isset($_GET['search']['end_time']) ? trim($_GET['search']['end_time']) : '';

		if ($search_uid) {
			$where .= " AND uid = '$search_uid'";
		}
		if ($start_time) {
			$time_start = strtotime($start_time);
			if ($time_start) $where .= " AND addtime >= '$time_start'";
		}
		if ($end_time) {
			$time_end = strtotime($end_time);
			if ($time_end) $where .= " AND addtime <= '$time_end'";
		}
		$page = isset($_GET['page']) && intval($_GET['page']) ? intval($_GET['page']) : 1;
		$list = $this -> db -> listinfo($where, 'id DESC', $page, 20);
		$pages = $this -> db -> pages;

		// 本页统计
		$total_order = 0;
		$total_rebate = 0;
		if ($list && is_array($list)) {
			foreach ($list as $v) {
				$total_order += $v['order_money'];
				$total_rebate += $v['rebate_money'];
			}
		}

		// 批量获取用户名
		$user_names = array();
		if ($list && is_array($list)) {
			$need_uids = array();
			foreach ($list as $v) {
				$need_uids[$v['uid']] = 1;
			}
			if (!empty($need_uids)) {
				$uid_str = implode(',', array_keys($need_uids));
				$user_rows = $this -> db2 -> select("uid IN ($uid_str)", 'uid,username', '', 'uid ASC');
				if ($user_rows) {
					foreach ($user_rows as $ur) {
						$user_names[$ur['uid']] = $ur['username'];
					}
				}
			}
		}

		base :: load_sys_class('format', '', 0);
		include $this -> daili_tpl('commission');
	}

	// ★ 保留search方法兼容旧链接，重定向到init
	public function search() {
		$params = array();
		$params['m'] = 'daili';
		$params['c'] = 'commission';
		$params['a'] = 'init';
		if (isset($_GET['search'])) {
			foreach ($_GET['search'] as $k => $v) {
				if (trim($v) !== '') {
					$params['search[' . $k . ']'] = trim($v);
				}
			}
		}
		$url = DAILI_PATH . '&c=commission&a=init';
		if (!empty($params)) {
			$url .= '&' . http_build_query($params);
		}
		header('Location: ' . $url);
		exit;
	}
}
?>