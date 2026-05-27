<?php
defined('IN_DAILI') or exit('No permission resources.');
include $this->daili_tpl('header');
?>
<div class="subnav">
	<h2 class="title-1">分成管理</h2>
	<div class="content-menu">
		<a href="<?php echo DAILI_PATH?>&c=commission" class="on"><em>分成管理</em></a>
	</div>
</div>
<div class="content-t">
	<!-- 汇总信息 -->
	<table width="100%" cellspacing="0" class="table_form">
		<tr>
			<th width="100">代理类型：</th>
			<td><?php echo $agent_config ? $agent_config['name'] : '未设置';?></td>
			<th width="100">分成比例：</th>
			<td><?php echo $agent_config ? $agent_config['rebate'].'%' : '未设置';?></td>
		</tr>
		<tr>
			<th>累计佣金：</th>
			<td><span style="color:#FF0000;font-size:16px;font-weight:bold;"><?php echo $agent_info['commission'];?></span></td>
			<th>账户余额：</th>
			<td><span style="color:#0066FF;font-size:16px;font-weight:bold;"><?php echo $agent_info['money'];?></span></td>
		</tr>
	</table>
	<div class="mt10"></div>
	<table width="100%" cellspacing="0" class="table_list">
		<thead>
			<tr>
				<th>统计项</th>
				<th>今日</th>
				<th>昨日</th>
				<th>本月</th>
				<th>上月</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>玩家流水</td>
				<td><?php echo $today_flow_total;?></td>
				<td><?php echo $yesterday_flow_total;?></td>
				<td><?php echo $month_flow_total;?></td>
				<td><?php echo $lastmonth_flow_total;?></td>
			</tr>
			<tr>
				<td>分成金额</td>
				<td><span style="color:#FF0000;font-weight:bold;"><?php echo $today_total;?></span></td>
				<td><?php echo $yesterday_total;?></td>
				<td><span style="color:#FF0000;font-weight:bold;"><?php echo $month_total;?></span></td>
				<td><?php echo $lastmonth_total;?></td>
			</tr>
		</tbody>
	</table>

	<!-- 分成明细列表 -->
	<div class="mt20"></div>
	<h3 class="title-1" style="padding:5px 0;">分成明细</h3>
	<form action="<?php echo DAILI_PATH?>&c=commission&a=init" method="get">
		<input type="hidden" name="m" value="daili" />
		<input type="hidden" name="c" value="commission" />
		<input type="hidden" name="a" value="init" />
		<table width="100%" cellspacing="0" class="table_form">
			<tr>
				<th>玩家UID：</th>
				<td><input class="input-text" type="text" name="search[uid]" value="<?php echo $search_uid ? $search_uid : ''?>" style="width: 100px;" /></td>
				<th>开始时间：</th>
				<td><input class="input-text" type="text" name="search[start_time]" value="<?php echo $start_time ? $start_time : ''?>" onclick="WdatePicker()" style="width: 130px;" /></td>
				<th>结束时间：</th>
				<td><input class="input-text" type="text" name="search[end_time]" value="<?php echo $end_time ? $end_time : ''?>" onclick="WdatePicker()" style="width: 130px;" /></td>
				<td>
					<input type="submit" class="button" name="dosubmit" value=" 搜 索 " />
					<?php if ($search_uid || $start_time || $end_time) { ?>
					<a href="<?php echo DAILI_PATH?>&c=commission&a=init" style="color:#F00; margin-left:5px;">清除搜索</a>
					<?php } ?>
				</td>
			</tr>
		</table>
	</form>
	<table width="100%" cellspacing="0" class="table_list">
		<thead>
			<tr>
				<th>ID</th>
				<th>玩家(UID)</th>
				<th>注单ID</th>
				<th>下注金额</th>
				<th>分成比例</th>
				<th>分成金额</th>
				<th>时间</th>
			</tr>
		</thead>
		<tbody>
			<?php
			if (!empty($list) && is_array($list)) {
				foreach ($list as $v) {
					$user_display = isset($user_names[$v['uid']]) ? $user_names[$v['uid']].'('.$v['uid'].')' : $v['uid'];
			?>
			<tr>
				<td><?php echo $v['id'];?></td>
				<td><?php echo $user_display;?></td>
				<td><?php echo $v['order_id'];?></td>
				<td><?php echo $v['order_money'];?></td>
				<td><?php echo $v['rebate'];?>%</td>
				<td><span style="color:#FF0000;font-weight:bold;"><?php echo $v['rebate_money'];?></span></td>
				<td><?php echo date('Y-m-d H:i:s', $v['addtime']);?></td>
			</tr>
			<?php
				}
			} else {
			?>
			<tr><td colspan="7" style="text-align:center; padding:20px; color:#999;">暂无分成记录</td></tr>
			<?php } ?>
		</tbody>
		<?php if (!empty($list) && is_array($list)) { ?>
		<tfoot>
			<tr>
				<td colspan="3" align="right"><strong>本页合计：</strong></td>
				<td><strong><?php echo round($total_order, 2)?></strong></td>
				<td>--</td>
				<td><span style="color:#FF0000;font-weight:bold;"><?php echo round($total_rebate, 2)?></span></td>
				<td></td>
			</tr>
		</tfoot>
		<?php } ?>
	</table>
	<div id="pages"><?php echo $pages;?></div>
</div>