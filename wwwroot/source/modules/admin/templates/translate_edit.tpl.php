<?php defined('IN_ADMIN') or exit('No permission resources.');
include $this -> admin_tpl('header');
?>
<style>
        .translate-form { max-width: 700px; }
        .translate-form table { width: 100%; }
        .translate-form th { width: 120px; text-align: right; padding: 8px 10px; vertical-align: top; }
        .translate-form td { padding: 8px 10px; }
        .translate-form .input-text { width: 400px; }
        .translate-form textarea.input-text { height: 80px; }
        .preview-box { background: #f9f9f9; padding: 10px; border-radius: 4px; margin-top: 8px; border: 1px dashed #ddd; }
        .preview-box strong { color: #333; }
        .info-row { margin-bottom: 6px; }
        .info-label { display: inline-block; width: 70px; color: #666; }
        .info-value { color: #333; font-weight: bold; }
        .badge { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 12px; color: #fff; }
</style>

<div class="subnav">
        <h2 class="title-1">编辑翻译</h2>
        <div class="content-menu">
                <a href="<?php echo ADMIN_PATH?>&c=translate"><em>翻译列表</em></a><span>|</span>
                <a href="javascript:;" class="on"><em>编辑翻译</em></a>
        </div>
</div>

<div class="content-t">
        <!-- 当前记录信息 -->
        <div style="background:#f0f7ff;padding:15px;border-radius:4px;margin-bottom:15px;border:1px solid #b8daff;">
                <div class="info-row"><span class="info-label">源表：</span><span class="badge badge-<?php echo $row['source_table'];?>"><?php echo isset($table_labels[$row['source_table']]) ? $table_labels[$row['source_table']] : $row['source_table'];?></span></div>
                <div class="info-row"><span class="info-label">源ID：</span><span class="info-value"><?php echo htmlspecialchars($row['source_id']);?></span></div>
                <div class="info-row"><span class="info-label">字段：</span><span class="info-value"><?php echo htmlspecialchars($row['field_name']);?></span></div>
                <div class="info-row"><span class="info-label">语言：</span><span class="badge <?php echo $row['lang'] == 'en-us' ? 'badge-lang-en' : 'badge-lang-my';?>"><?php echo isset($lang_labels[$row['lang']]) ? $lang_labels[$row['lang']] : $row['lang'];?></span></div>
        </div>

        <form action="<?php echo ADMIN_PATH?>&c=translate&a=edit&id=<?php echo $row['id'];?>" method="post" class="translate-form" id="myform">
                <input type="hidden" name="source_table" value="<?php echo htmlspecialchars($row['source_table']);?>" />
                <input type="hidden" name="source_id" value="<?php echo htmlspecialchars($row['source_id']);?>" />
                <input type="hidden" name="field_name" value="<?php echo htmlspecialchars($row['field_name']);?>" />
                <input type="hidden" name="lang" value="<?php echo htmlspecialchars($row['lang']);?>" />

                <table cellspacing="0" class="table_form">
                        <tbody>
                                <tr>
                                        <th>当前翻译：</th>
                                        <td>
                                                <textarea name="value" class="input-text" rows="4"><?php echo htmlspecialchars($row['value']);?></textarea>
                                        </td>
                                </tr>
                        </tbody>
                </table>
                <p class="mt20"></p>
                <input type="submit" class="button" name="dosubmit" value=" 保存修改 " />
                <a href="<?php echo ADMIN_PATH?>&c=translate" class="button" style="background:#eee;text-decoration:none;color:#333;"> 返 回 </a>
        </form>
</div>

<style>
        .badge-game { background: #4CAF50; }
        .badge-settings { background: #2196F3; }
        .badge-account_type { background: #FF9800; }
        .badge-cash_state { background: #9C27B0; }
        .badge-pay_state { background: #00BCD4; }
        .badge-game_state { background: #795548; }
        .badge-user_role { background: #607D8B; }
        .badge-lang-en { background: #0072C6; }
        .badge-lang-my { background: #D84315; }
</style>
</body>
</html>
