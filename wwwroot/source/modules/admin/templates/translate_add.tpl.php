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
        .translate-form select.input-text { width: 408px; }
        .translate-form .hint { color: #999; font-size: 12px; margin-top: 4px; }
        .preview-box { background: #f9f9f9; padding: 10px; border-radius: 4px; margin-top: 8px; border: 1px dashed #ddd; }
        .preview-box strong { color: #333; }
</style>

<div class="subnav">
        <h2 class="title-1">添加翻译</h2>
        <div class="content-menu">
                <a href="<?php echo ADMIN_PATH?>&c=translate"><em>翻译列表</em></a><span>|</span>
                <a href="javascript:;" class="on"><em>添加翻译</em></a>
        </div>
</div>

<div class="content-t">
        <form action="<?php echo ADMIN_PATH?>&c=translate&a=add" method="post" class="translate-form" id="myform">
                <table cellspacing="0" class="table_form">
                        <tbody>
                                <tr>
                                        <th>源表：</th>
                                        <td>
                                                <select name="source_table" id="source_table" class="input-text" onchange="loadSourceIds();">
                                                        <option value="">请选择...</option>
                                                        <?php foreach ($translatable_sources as $key => $label): ?>
                                                        <option value="<?php echo $key;?>"><?php echo $label;?></option>
                                                        <?php endforeach; ?>
                                                </select>
                                                <div class="hint">选择要翻译的数据来源</div>
                                        </td>
                                </tr>
                                <tr>
                                        <th>源ID：</th>
                                        <td>
                                                <select name="source_id" id="source_id" class="input-text">
                                                        <option value="">请先选择源表...</option>
                                                </select>
                                                <div class="hint" id="source_id_hint">选择源表后自动加载可选项</div>
                                        </td>
                                </tr>
                                <tr>
                                        <th>字段名：</th>
                                        <td>
                                                <select name="field_name" id="field_name" class="input-text">
                                                        <option value="name">name (名称)</option>
                                                        <option value="value">value (值)</option>
                                                </select>
                                                <div class="hint">游戏用 name，系统设置用 value</div>
                                        </td>
                                </tr>
                                <tr>
                                        <th>语言：</th>
                                        <td>
                                                <select name="lang" class="input-text">
                                                        <?php foreach ($lang_labels as $code => $label): ?>
                                                        <option value="<?php echo $code;?>"><?php echo $label;?></option>
                                                        <?php endforeach; ?>
                                                </select>
                                        </td>
                                </tr>
                                <tr>
                                        <th>中文原文：</th>
                                        <td>
                                                <div class="preview-box" id="original_box">
                                                        <span style="color:#999;">选择源表和源ID后自动显示</span>
                                                </div>
                                        </td>
                                </tr>
                                <tr>
                                        <th>翻译内容：</th>
                                        <td>
                                                <textarea name="value" class="input-text" rows="4" placeholder="请输入翻译内容..."></textarea>
                                        </td>
                                </tr>
                        </tbody>
                </table>
                <p class="mt20"></p>
                <input type="submit" class="button" name="dosubmit" value=" 提 交 " />
                <a href="<?php echo ADMIN_PATH?>&c=translate" class="button" style="background:#eee;text-decoration:none;color:#333;"> 返 回 </a>
        </form>
</div>

<script type="text/javascript">
        function loadSourceIds() {
                var sourceTable = $('#source_table').val();
                if (!sourceTable) {
                        $('#source_id').html('<option value="">请先选择源表...</option>');
                        $('#original_box').html('<span style="color:#999;">选择源表和源ID后自动显示</span>');
                        return;
                }

                // 自动设置字段名
                if (sourceTable == 'game') {
                        $('#field_name').val('name');
                } else if (sourceTable == 'settings') {
                        $('#field_name').val('value');
                } else {
                        $('#field_name').val('name');
                }

                // 加载源ID列表
                $.ajax({
                        url: '<?php echo ADMIN_PATH?>&c=translate&a=ajax_get_source&source_table=' + sourceTable,
                        type: 'GET',
                        dataType: 'json',
                        success: function(data) {
                                var html = '<option value="">请选择...</option>';
                                for (var i = 0; i < data.length; i++) {
                                        html += '<option value="' + data[i].id + '">' + data[i].name + '</option>';
                                }
                                $('#source_id').html(html);
                                $('#source_id_hint').text('共 ' + data.length + ' 个可选项');
                        },
                        error: function() {
                                $('#source_id').html('<option value="">加载失败</option>');
                        }
                });
        }

        // 选择源ID后显示中文原文
        $('#source_id').change(function() {
                var selectedText = $(this).find('option:selected').text();
                if ($(this).val()) {
                        $('#original_box').html('<strong>中文原文：</strong>' + selectedText);
                } else {
                        $('#original_box').html('<span style="color:#999;">选择源表和源ID后自动显示</span>');
                }
        });
</script>
</body>
</html>
