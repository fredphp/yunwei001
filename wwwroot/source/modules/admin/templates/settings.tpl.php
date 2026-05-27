<?php
defined('IN_ADMIN') or exit('No permission resources.');
include $this->admin_tpl('header');
?>
<div class="subnav">
        <h2 class="title-1">系统设置</h2>
        <div class="content-menu">
                <a id="menu-1" href="javascript:;" onclick="menuswitch('1');" class="on"><em>SEO设置</em></a><span>|</span>
                <a id="menu-2" href="javascript:;" onclick="menuswitch('2');"><em>基本设置</em></a><span>|</span>
                <a id="menu-3" href="javascript:;" onclick="menuswitch('3');"><em>财务设置</em></a>
        </div>
</div>
<div class="content-t">
        <form enctype="multipart/form-data" action="<?php echo ADMIN_PATH?>&c=settings&a=init" method="post" id="myform">
                <div id="content-1">
                        <table width="100%" cellspacing="0" class="table_form">
                                <tbody>
                                        <tr>
                                                <th>网站名称：</th>
                                                <td><input class="input-text" type="text" name="setting[webname]" value="<?php echo $webname;?>"></td>
                                        </tr>
                                        <tr>
                                                <th>网站名称(English)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_en_us_webname" value="<?php echo isset($translate['webname_en-us']) ? htmlspecialchars($translate['webname_en-us']) : '';?>" style="width: 300px;" />
                                                        <span>英文翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站名称(မြန်မာ)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_my_mm_webname" value="<?php echo isset($translate['webname_my-mm']) ? htmlspecialchars($translate['webname_my-mm']) : '';?>" style="width: 300px;" />
                                                        <span>缅甸语翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站访问地址：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[weburl]" value="<?php echo $weburl;?>">
                                                        <span>以“http://”开始，“/”结尾的网站访问地址</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站关键字：</th>
                                                <td><input class="input-text" type="text" name="setting[keywords]" style="width: 500px;" value="<?php echo $keywords;?>"><span>多个用“,”分开</span></td>
                                        </tr>
                                        <tr>
                                                <th>网站关键字(English)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_en_us_keywords" value="<?php echo isset($translate['keywords_en-us']) ? htmlspecialchars($translate['keywords_en-us']) : '';?>" style="width: 500px;" />
                                                        <span>英文翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站关键字(မြန်မာ)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_my_mm_keywords" value="<?php echo isset($translate['keywords_my-mm']) ? htmlspecialchars($translate['keywords_my-mm']) : '';?>" style="width: 500px;" />
                                                        <span>缅甸语翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站描述：</th>
                                                <td><input class="input-text" type="text" name="setting[description]" style="width: 500px;" value="<?php echo $description;?>"></td>
                                        </tr>
                                        <tr>
                                                <th>网站描述(English)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_en_us_description" value="<?php echo isset($translate['description_en-us']) ? htmlspecialchars($translate['description_en-us']) : '';?>" style="width: 500px;" />
                                                        <span>英文翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站描述(မြန်မာ)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_my_mm_description" value="<?php echo isset($translate['description_my-mm']) ? htmlspecialchars($translate['description_my-mm']) : '';?>" style="width: 500px;" />
                                                        <span>缅甸语翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站版权：</th>
                                                <td><input class="input-text" type="text" name="setting[copyright]" style="width: 500px;" value="<?php echo $copyright;?>"></td>
                                        </tr>
                                        <tr>
                                                <th>网站版权(English)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_en_us_copyright" value="<?php echo isset($translate['copyright_en-us']) ? htmlspecialchars($translate['copyright_en-us']) : '';?>" style="width: 500px;" />
                                                        <span>英文翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站版权(မြန်မာ)：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="translate_my_mm_copyright" value="<?php echo isset($translate['copyright_my-mm']) ? htmlspecialchars($translate['copyright_my-mm']) : '';?>" style="width: 500px;" />
                                                        <span>缅甸语翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>统计代码：</th>
                                                <td>
                                                        <textarea class="input-text" name="setting[code]" style="width: 500px;height: 80px;"><?php echo $code;?></textarea>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>客服QQ：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[qq]" style="width: 500px;" value="<?php echo $qq;?>">
                                                        <p>多个QQ用“|”分开，显示名称和QQ用“@”分开，如：售前咨询@8888888|售后咨询@6666666</p>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>联系电话：</th>
                                                <td><input class="input-text" type="text" name="setting[phone]" value="<?php echo $phone;?>"></td>
                                        </tr>
                                        <tr>
                                                <th>Email：</th>
                                                <td><input class="input-text" type="text" name="setting[email]" value="<?php echo $email;?>"></td>
                                        </tr>
                                </tbody>
                        </table>
                </div>
                <div id="content-2" style="display:none;">
                        <table width="100%" cellspacing="0" class="table_form">
                                <tbody>
                                  <tr>
                                    <th>暂停投注：</th>
                                    <td>
                                                <label><input type="radio" name="setting[stop]" value="0" <?php if ($stop == 0) echo 'checked="checked"'?> />否</label>
                                                <label><input type="radio" name="setting[stop]" value="1" <?php if ($stop == 1) echo 'checked="checked"'?> />是</label>
                                                <span class="label">控制全局投注开关，如需关停个别游戏，请前往《游戏管理》</span>
                                    </td>
                                  </tr>
                                        <tr>
                                                <th>网站语言：</th>
                                                <td>
                                                        <select name="setting[lang]" class="input-text">
                                                                <option value="zh-cn" <?php if ($lang == 'zh-cn') echo 'selected';?>>中文 (Chinese)</option>
                                                                <option value="en-us" <?php if ($lang == 'en-us') echo 'selected';?>>English</option>
                                                                <option value="my-mm" <?php if ($lang == 'my-mm') echo 'selected';?>>မြန်မာ (Myanmar)</option>
                                                        </select>
                                                        <span>控制前台显示语言，修改后前台所有页面将切换为对应语言</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>初始金额：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[money]" value="<?php echo $money;?>">
                                                        <span>新注册用户初始的金额，一般用于限时全体活动</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>货币符号：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[stamp]" value="<?php echo $stamp;?>">
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>用户名验证：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[username_type]" value="<?php echo $username_type;?>">
                                                        <span>用于注册验证，支持正则或内置验证，*：不限制、m：手机号、*2-20：长度限制，支持验证组合，如：m|e：判断是否手机或者邮箱</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>禁用关键词：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[userfilter]" style="width: 500px;" value="<?php echo $userfilter;?>">
                                                        <span>多个关键字用用半角逗号“,”分开，包含关键词的用户名或者昵称禁止使用</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站公告：</th>
                                                <td>
                                                        <textarea class="input-text" name="setting[ann]" style="width: 500px;height: 80px;"><?php echo $ann;?></textarea>
                                                        <p>支持HTML</p>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站公告(English)：</th>
                                                <td>
                                                        <textarea class="input-text" name="translate_en_us_ann" style="width: 500px;height: 60px;"><?php echo isset($translate['ann_en-us']) ? htmlspecialchars($translate['ann_en-us']) : '';?></textarea>
                                                        <span>英文翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>网站公告(မြန်မာ)：</th>
                                                <td>
                                                        <textarea class="input-text" name="translate_my_mm_ann" style="width: 500px;height: 60px;"><?php echo isset($translate['ann_my-mm']) ? htmlspecialchars($translate['ann_my-mm']) : '';?></textarea>
                                                        <span>缅甸语翻译，留空则使用中文</span>
                                                </td>
                                        </tr>
                                </tbody>
                        </table>
                </div>
                <div id="content-3" style="display:none;">
                        <table width="100%" cellspacing="0" class="table_form">
                                <tbody>
                                        <tr>
                                                <th>最低充值金额：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[pay]" value="<?php echo $pay;?>">
                                                        <span>全局生效</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>提现手续费：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[cash]" value="<?php echo $cash;?>">
                                                        <span>全局生效，可填写百分比如：5% 即按照提现金额百分之5计算，或直接填写每笔订单的手续费</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>单笔提现上限：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[maxcash]" value="<?php echo $maxcash;?>">
                                                        <span>全局生效，每笔最大提现金额</span>
                                                </td>
                                        </tr>
                                        <tr>
                                                <th>投注金额限制：</th>
                                                <td>
                                                        <input class="input-text" type="text" name="setting[send_money]" value="<?php echo $send_money;?>">
                                                        <span>全局生效，填写格式：1-50000，如需限制个人账户请前往《账户管理》</span>
                                                </td>
                                        </tr>
                        <tr>
                                <th width="100"></th>
                                <td><?php echo $wxewm ? '<img src="uppic/ewm/'.$wxewm.'" width="200" height="200" />' : ''?></td>
                        </tr>
                        <tr>
                                <th width="100">微信收款二维码：</th>
                                <td>
                                        <input type="file" id="wxfile" name="wxfile" accept="image/*" />
                                        <span>该信息将展示在直属会员或代理支付页面，建议二维码图片尺寸：200PX * 200PX</span>
                                </td>
                        </tr>
                        <tr>
                                <th width="100"></th>
                                <td><?php echo $aliewm ? '<img src="uppic/ewm/'.$aliewm.'" width="200" height="200" />' : ''?></td>
                        </tr>
                        <tr>
                                <th width="100">支付宝收款二维码：</th>
                                <td>
                                        <input type="file" id="alifile" name="alifile" accept="image/*" />
                                        <span>该信息将展示在直属会员或代理支付页面，建议二维码图片尺寸：200PX * 200PX</span>
                                </td>
                        </tr>
                        <tr>
                                <th>收款银行：</th>
                                <td>
                                        <textarea class="input-text" name="setting[card]" style="width: 300px;height: 60px;"><?php echo $card;?></textarea>
                                        <p>该信息将展示在直属会员或代理支付页面，请完整填写银行名称、卡号和姓名信息</p>
                                </td>
                        </tr>
                        <tr>
                                <th>收款银行(English)：</th>
                                <td>
                                        <textarea class="input-text" name="translate_en_us_card" style="width: 300px;height: 60px;"><?php echo isset($translate['card_en-us']) ? htmlspecialchars($translate['card_en-us']) : '';?></textarea>
                                        <span>英文翻译，留空则使用中文</span>
                                </td>
                        </tr>
                        <tr>
                                <th>收款银行(မြန်မာ)：</th>
                                <td>
                                        <textarea class="input-text" name="translate_my_mm_card" style="width: 300px;height: 60px;"><?php echo isset($translate['card_my-mm']) ? htmlspecialchars($translate['card_my-mm']) : '';?></textarea>
                                        <span>缅甸语翻译，留空则使用中文</span>
                                </td>
                        </tr>
                        <tr>
                                <th>支付备注：</th>
                                <td>
                                        <input class="input-text" type="text" name="setting[remark]" value="<?php echo $remark?>" style="width: 200px;" />
                                        <span>该信息将展示在直属会员或代理支付页面，可填写联系方式或其他备注信息</span>
                                </td>
                        </tr>
                        <tr>
                                <th>支付备注(English)：</th>
                                <td>
                                        <input class="input-text" type="text" name="translate_en_us_remark" value="<?php echo isset($translate['remark_en-us']) ? htmlspecialchars($translate['remark_en-us']) : '';?>" style="width: 200px;" />
                                        <span>英文翻译，留空则使用中文</span>
                                </td>
                        </tr>
                        <tr>
                                <th>支付备注(မြန်မာ)：</th>
                                <td>
                                        <input class="input-text" type="text" name="translate_my_mm_remark" value="<?php echo isset($translate['remark_my-mm']) ? htmlspecialchars($translate['remark_my-mm']) : '';?>" style="width: 200px;" />
                                        <span>缅甸语翻译，留空则使用中文</span>
                                </td>
                        </tr>
                                </tbody>
                        </table>
                        <div class="mt20"></div>
                        <h3 class="title-1" style="padding:10px 0;">代理管理</h3>
                        <table width="100%" cellspacing="0" class="table_form" id="agent_table">
                                <thead>
                                        <tr>
                                                <th width="60">ID</th>
                                                <th>代理名称</th>
                                                <th width="120">分成比例(%)</th>
                                                <th width="80">状态</th>
                                                <th width="80">操作</th>
                                        </tr>
                                </thead>
                                <tbody id="agent_tbody">
                                <?php if(isset($agent_list) && is_array($agent_list)) { foreach($agent_list as $ag) { ?>
                                        <tr id="agent_<?php echo $ag['id']?>">
                                                <td><?php echo $ag['id']?></td>
                                                <td><input class="input-text" type="text" name="agent_list[<?php echo $ag['id']?>][name]" value="<?php echo htmlspecialchars($ag['name'])?>" style="width:200px;" /></td>
                                                <td><input class="input-text" type="text" name="agent_list[<?php echo $ag['id']?>][rebate]" value="<?php echo $ag['rebate']?>" style="width:80px;" />%</td>
                                                <td>
                                                        <label><input type="radio" name="agent_list[<?php echo $ag['id']?>][state]" value="1" <?php if($ag['state'] == 1) echo 'checked="checked"'?> />启用</label>
                                                        <label><input type="radio" name="agent_list[<?php echo $ag['id']?>][state]" value="0" <?php if($ag['state'] == 0) echo 'checked="checked"'?> />停用</label>
                                                </td>
                                                <td><a href="javascript:;" onclick="delete_agent_row(<?php echo $ag['id']?>);" style="color:#F00;">删除</a></td>
                                        </tr>
                                <?php }} ?>
                                </tbody>
                                <tfoot>
                                        <tr>
                                                <td colspan="5" style="padding:10px;">
                                                        <input type="button" class="button" value=" + 添加代理 " onclick="add_agent_row();" />
                                                        <span style="color:#999;margin-left:10px;">分成比例基于玩家下注流水计算，如填写5表示玩家每下注100元，代理获得5元分成</span>
                                                </td>
                                        </tr>
                                </tfoot>
                        </table>
                        <input type="hidden" name="agent_deleted" id="agent_deleted" value="" />
                </div>
                <p class="mt20"></p>
                <input type="submit" class="button" name="dosubmit" value=" 提 交 " />
        </form>
</div>
<script type="text/javascript">
var agent_row_count = <?php echo isset($agent_list) && is_array($agent_list) ? count($agent_list) : 0?>;
function add_agent_row() {
        agent_row_count--;
        var html = '<tr id="agent_new_' + agent_row_count + '">'
                + '<td>新增</td>'
                + '<td><input class="input-text" type="text" name="agent_new[' + agent_row_count + '][name]" value="" style="width:200px;" placeholder="代理名称" /></td>'
                + '<td><input class="input-text" type="text" name="agent_new[' + agent_row_count + '][rebate]" value="0" style="width:80px;" />%</td>'
                + '<td>'
                + '<label><input type="radio" name="agent_new[' + agent_row_count + '][state]" value="1" checked="checked" />启用</label>'
                + '<label><input type="radio" name="agent_new[' + agent_row_count + '][state]" value="0" />停用</label>'
                + '</td>'
                + '<td><a href="javascript:;" onclick="$(this).closest(\'tr\').detach();" style="color:#F00;">删除</a></td>'
                + '</tr>';
        $('#agent_tbody').append(html);
}
function delete_agent_row(id) {
        if (confirm('确定删除该代理吗？删除后已关联该代理的用户将变为普通账户！')) {
                $('#' + 'agent_' + id).detach();
                var deleted = $('#agent_deleted').val();
                $('#agent_deleted').val(deleted ? deleted + ',' + id : id);
        }
}
</script>
</body>
</html>