<?php
defined('IN_ADMIN') or exit('No permission resources.');
include $this->admin_tpl('header');
?>
<div class="subnav">
	<h2 class="title-1">游戏开奖号码</h2>
	<a href="javascript:location.reload();" class="reload">刷新</a>
</div>
<div class="content-t">
	<div class="tps">
		<p>提示：如果发生漏号现象，请手工补号，补号后，系统会自动给予结算；为了保证下注安全，如果发生漏期，系统不支持补期操作！请对相应注单进行退单处理（如果是漏期，前台也无法下注）！</p>
	</div>
	<div class="table-list">
		<table width="100%" cellspacing="0">
			<thead>
				<tr>
					<th align="center" width="80">游戏ID</th>
					<th align="left" width="150">期数</th>
					<th align="left" width="120">开奖时间</th>
					<th align="left">开奖号码</th>
					<th align="center" width="80">结清</th>
				</tr>
			</thead>
			<tbody>
			<?php foreach ($list as $v){?>
				<tr id="list_<?php echo $v['id']?>">
					<td align="center"><?php echo $v['gameid']?></td>
					<td align="left"><?php echo $v['qishu']?></td>
					<td align="left"><?php echo format::date($v['sendtime'], 1)?></td>
					<td align="left" class="haoma"><?php echo $v['haoma'] ? $v['haoma'] : '<a href="'.ADMIN_PATH.'&c=game&a=haoma_add&id='.$v['id'].'">[补号]</a>'?></td>
					<td align="center"><?php echo $account[$v['account']]?></td>
				</tr>
			<?php }?>
			</tbody>
		</table>
		<div id="pages"><?php echo $pages?></div>
	</div>
</div>
</body>
</html>