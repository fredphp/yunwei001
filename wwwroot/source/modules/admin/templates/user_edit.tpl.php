<?php
defined('IN_ADMIN') or exit('No permission resources.');
include $this->admin_tpl('header');
?>
<div class="subnav">
	<h2 class="title-1">账户管理</h2>
	<div class="content-menu">
		<a href="<?php echo ADMIN_PATH?>&c=user&a=init"><em>账户列表</em></a><span>|</span>
		<a href="<?php echo ADMIN_PATH?>&c=user&a=add" class="on"><em>账户注册</em></a>
	</div>
</div>
<div class="content-t">
	<form action="<?php echo ADMIN_PATH?>&c=user&a=edit&uid=<?php echo $uid?>" method="post" id="myform">
		<table width="100%" class="table_form">
			<tr>
				<th>用户名：</th>
				<td>
					<?php echo $data['username']?>
				</td>
			</tr>
			<tr>
				<th>昵称：</th>
				<td>
					<input class="input-text" type="text" name="nickname" value="<?php echo $data['nickname']?>" id="nickname" style="width: 200px;" />
				</td>
			</tr>
			<tr>
				<th>新密码：</th>
				<td>
					<input class="input-text" type="text" name="password" value="" id="password" />
					<span>密码限制为6-20个字符，不修改请留空</span>
				</td>
			</tr>
			<tr>
				<th>锁定：</th>
				<td>
					<label for="lock_1"><input type="radio" id="lock_1" name="lock" value="1" <?php if($data['lock'] == 1) echo 'checked="checked"';?> />是</label>
					<label for="lock_2"><input type="radio" id="lock_2" name="lock" value="0" <?php if(!$data['lock']) echo 'checked="checked"';?> />否</label>
					<span class="label">锁定后将禁止登录</span>
				</td>
			</tr>
			<tr>
				<th>Email：</th>
				<td>
					<input class="input-text" type="text" name="email" value="<?php echo $data['email']?>" id="email" />
				</td>
			</tr>
			<tr>
				<th>QQ：</th>
				<td>
					<input class="input-text" type="text" name="qq" value="<?php echo $data['qq']?>" id="qq" />
				</td>
			</tr>
			<tr>
				<th>手机号：</th>
				<td>
					<input class="input-text" type="text" name="mobile" value="<?php echo $data['mobile']?>" id="mobile" />
				</td>
			</tr>
			<tr>
				<th>投注金额限制：</th>
				<td>
					<input class="input-text" type="text" name="send_money" value="<?php echo $data['send_money']?>" id="send_money" />
					<span>填写格式：1-50000，此处设置优先于全局系统设置，留空则遵循全局系统设置</span>
				</td>
			</tr>
			<tr>
				<th class="red">敏感资料：</th>
				<td>以下是敏感资料，请谨慎修改</td>
			</tr>
			<tr>
				<th class="red">姓名：</th>
				<td>
					<input class="input-text" type="text" name="name" value="<?php echo $data['name']?>" id="name" />
				</td>
			</tr>
			<tr>
				<th class="red">银行名称：</th>
				<td>
					<input class="input-text" type="text" name="bank" value="<?php echo $data['bank']?>" id="bank" style="width: 200px;" />
				</td>
			</tr>
			<tr>
				<th class="red">银行账号：</th>
				<td>
					<input class="input-text" type="text" name="card" value="<?php echo $data['card']?>" id="card" style="width: 200px;" />
				</td>
			</tr>
			<tr>
				<th class="red">微信：</th>
				<td>
					<input class="input-text" type="text" name="weixin" value="<?php echo $data['weixin']?>" id="weixin" />
				</td>
			</tr>
			<tr>
				<th class="red">支付宝：</th>
				<td>
					<input class="input-text" type="text" name="alipay" value="<?php echo $data['alipay']?>" id="alipay" />
				</td>
			</tr>
			<tr>
				<th class="red">代理关系：</th>
				<td>
					修改代理关系会影响分成计算，请谨慎操作
				</td>
			</tr>
			<tr>
				<th class="red">代理：</th>
				<td>
					<label for="aid_1"><input type="radio" id="aid_1" name="aid" value="0" <?php if($data['aid'] == 0) echo 'checked="checked"';?> onclick="$('#agent_select_tr').hide();" />普通账户</label>
					<label for="aid_2"><input type="radio" id="aid_2" name="aid" value="1" <?php if($data['aid'] == 1) echo 'checked="checked"';?> onclick="$('#agent_select_tr').show();" />代理</label>
					<span class="label">选择代理后将关联到对应代理配置</span>
				</td>
			</tr>
			<tr id="agent_select_tr" <?php if($data['aid'] != 1) echo 'style="display:none;"';?>>
				<th class="red">选择代理：</th>
				<td>
					<select name="agent_id" id="agent_id" class="input-text" style="width: 200px;">
						<option value="0">-- 请选择代理 --</option>
						<?php if(isset($agent_list) && is_array($agent_list)) { foreach($agent_list as $ag) { ?>
						<option value="<?php echo $ag['id']?>" <?php if($data['agent_id'] == $ag['id']) echo 'selected="selected"';?> rebate="<?php echo $ag['rebate']?>"><?php echo htmlspecialchars($ag['name'])?> (分成:<?php echo $ag['rebate']?>%)</option>
						<?php }} ?>
					</select>
					<span>代理列表来源于 通用设置 → 财务设置 → 代理管理</span>
				</td>
			</tr>
		</table>
		<div class="mt20"></div>
		<input type="submit" class="button" name="dosubmit" value=" 提 交 " />
	</form>
</div>
<script type="text/javascript">
<!--
$(function(){
	var Vform = $("#myform").Validform();
	Vform.config({tiptype:3});
	Vform.addRule([
		{
			ele:'#password',
			datatype:'s6-20',
			ignore:"ignore",
			nullmsg:'请输入密码',
			errormsg:'密码限制为6-20个字符'
		}
	]);
	$('#username').focus();//处理需要即时验证的表单需要点击后才能提交的BUG
})
//-->
</script>
</body>
</html>
