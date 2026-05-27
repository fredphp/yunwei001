<?php
defined('IN_DAILI') or exit('No permission resources.');
include $this->daili_tpl('header');
?>
<div class="subnav">
	<h2 class="title-1">分成管理</h2>
	<div class="content-menu">
		<a href="<?php echo DAILI_PATH?>&c=commission" class="on"><em>分成汇总</em></a><span>|</span>
		<a href="<?php echo DAILI_PATH?>&c=commission&a=search"><em>分成明细</em></a>
	</div>
</div>
<div class="content-t">
	<table width="100%" cellspacing="0" class="table_form">
		<tr>
			<th>代理类型：</th>
			<td><?php echo $agent_config ? $agent_config['name'] : '未设置';?></td>
		</tr>
		<tr>
			<th>分成比例：</th>
			<td><?php echo $agent_config ? $agent_config['rebate'].'%' : '未设置';?></td>
		</tr>
		<tr>
			<th>累计佣金：</th>
			<td><span style="color:#FF0000;font-size:16px;font-weight:bold;"><?php echo $agent_info['commission'];?></span></td>
		</tr>
		<tr>
			<th>账户余额：</th>
			<td><span style="color:#0066FF;font-size:16px;font-weight:bold;"><?php echo $agent_info['money'];?></span></td>
		</tr>
	</table>
	<div class="mt20"></div>
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
</div>