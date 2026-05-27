<?php
defined('IN_ADMIN') or exit('No permission resources.');
include $this->admin_tpl('header');
?>
<div class="subnav">
	<h2 class="title-1">代理分成记录</h2>
	<a href="javascript:location.reload();" class="reload">刷新</a>
	<a href="javascript:;" onclick="searchshow(1)" class="searchshow">展开/收起搜索栏</a>
	<div class="content-menu">
		<a href="<?php echo ADMIN_PATH?>&c=agent_rebate&a=init" class="on"><em>分成记录</em></a>
	</div>
</div>
<div class="content-t">
	<div id="searchshow">
		<form name="searchform" action="<?php echo ADMIN_PATH?>&c=agent_rebate&a=search" method="get">
			<input type="hidden" name="m" value="admin">
			<input type="hidden" name="c" value="agent_rebate">
			<input type="hidden" name="a" value="search">
			<table width="100%" cellspacing="0" class="search-form">
				<tbody>
					<tr>
						<td>
							<div class="explain-col">
								用户UID <input class="input-text" type="text" name="search[uid]" style="width:60px;" value="<?php echo isset($uid) ? $uid : ''?>">
								代理
								<select name="search[agent_id]" class="input-text">
									<option value="0">全部</option>
									<?php if(isset($agent_list) && is_array($agent_list)) { foreach($agent_list as $ag) { ?>
									<option value="<?php echo $ag['id']?>" <?php if(isset($agent_id) && $agent_id == $ag['id']) echo 'selected';?>><?php echo htmlspecialchars($ag['name'])?></option>
									<?php }} ?>
								</select>
								时间 <?php echo form::date('search[start_time]', isset($start_time) ? $start_time : '','1')?>
								到 <?php echo form::date('search[end_time]', isset($end_time) ? $end_time : '','1')?>
								<input type="submit" value="搜索" class="button" name="dosubmit">
							</div>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	<div class="table-list">
		<table width="100%" cellspacing="0">
			<thead>
				<tr>
					<th align="center" width="60">ID</th>
					<th align="center" width="80">用户(UID)</th>
					<th align="center" width="100">代理名称</th>
					<th align="center" width="80">代理(UID)</th>
					<th align="center" width="80">下注金额</th>
					<th align="center" width="80">分成比例</th>
					<th align="center" width="80">分成金额</th>
					<th align="center" width="140">时间</th>
					<th align="center" width="60">操作</th>
				</tr>
			</thead>
			<tbody>
			<?php
			// ★ 统计
			$total_rebate = 0;
			$total_order = 0;
			if (isset($list) && is_array($list)) {
			foreach ($list as $v) {
				$total_rebate += $v['rebate_money'];
				$total_order += $v['order_money'];
				// 获取用户名
				$user_info = $user_db -> get_one(array('uid' => $v['uid']), 'username');
				$agent_user_info = $user_db -> get_one(array('uid' => $v['agent_uid']), 'username');
				$agent_name = isset($agent_names[$v['agent_id']]) ? $agent_names[$v['agent_id']] : '已删除';
			?>
				<tr id="list_<?php echo $v['id']?>">
					<td align="center"><?php echo $v['id']?></td>
					<td align="center"><?php echo $user_info ? $user_info['username'].'('.$v['uid'].')' : $v['uid']?></td>
					<td align="center"><?php echo htmlspecialchars($agent_name)?></td>
					<td align="center"><?php echo $agent_user_info ? $agent_user_info['username'].'('.$v['agent_uid'].')' : $v['agent_uid']?></td>
					<td align="center"><?php echo $v['order_money']?></td>
					<td align="center"><?php echo $v['rebate']?>%</td>
					<td align="center" style="color:#F00;"><?php echo $v['rebate_money']?></td>
					<td align="center"><?php echo format::date($v['addtime'], 1)?></td>
					<td align="center">
						<a href="javascript:;" onclick="showwindow('<?php echo ADMIN_PATH?>&c=agent_rebate&a=del&id=<?php echo $v['id']?>', '确定删除这条分成记录吗？');">[删除]</a>
					</td>
				</tr>
			<?php }} ?>
			</tbody>
			<tfoot>
				<tr>
					<td colspan="4" align="right"><strong>本页合计：</strong></td>
					<td align="center"><strong><?php echo round($total_order, 2)?></strong></td>
					<td align="center">--</td>
					<td align="center" style="color:#F00;"><strong><?php echo round($total_rebate, 2)?></strong></td>
					<td colspan="2"></td>
				</tr>
			</tfoot>
		</table>
		<div id="pages"><?php echo $pages?></div>
	</div>
</div>
</body>
</html>
