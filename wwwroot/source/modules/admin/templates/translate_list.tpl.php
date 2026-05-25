<?php defined('IN_ADMIN') or exit('No permission resources.');
include $this -> admin_tpl('header');
?>
<style>
        .translate-filter { background: #f9f9f9; padding: 15px; border-radius: 4px; margin-bottom: 15px; border: 1px solid #e5e5e5; }
        .translate-filter select, .translate-filter input { margin-right: 8px; }
        .translate-table { width: 100%; border-collapse: collapse; }
        .translate-table th { background: #f0f0f0; padding: 8px 10px; text-align: left; font-weight: bold; border-bottom: 2px solid #ddd; white-space: nowrap; }
        .translate-table td { padding: 8px 10px; border-bottom: 1px solid #eee; }
        .translate-table tr:hover { background: #f5f8fc; }
        .badge { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 12px; color: #fff; }
        .badge-game { background: #4CAF50; }
        .badge-settings { background: #2196F3; }
        .badge-account_type { background: #FF9800; }
        .badge-cash_state { background: #9C27B0; }
        .badge-pay_state { background: #00BCD4; }
        .badge-game_state { background: #795548; }
        .badge-user_role { background: #607D8B; }
        .badge-lang-en { background: #0072C6; }
        .badge-lang-my { background: #D84315; }
        .value-cell { max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .pagination { padding: 10px 0; text-align: right; }
        .pagination a, .pagination span { display: inline-block; padding: 4px 10px; margin: 0 2px; border: 1px solid #ddd; border-radius: 3px; text-decoration: none; }
        .pagination span { background: #0072C6; color: #fff; border-color: #0072C6; }
        .pagination a:hover { background: #e8e8e8; }
        .btn { display: inline-block; padding: 5px 14px; border-radius: 3px; font-size: 13px; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #0072C6; color: #fff; border: 1px solid #005fa3; }
        .btn-primary:hover { background: #005fa3; }
        .btn-danger { background: #d9534f; color: #fff; border: 1px solid #c9302c; }
        .btn-danger:hover { background: #c9302c; }
        .btn-success { background: #5cb85c; color: #fff; border: 1px solid #4cae4c; }
        .btn-success:hover { background: #4cae4c; }
        .btn-sm { padding: 3px 8px; font-size: 12px; }
        .batch-bar { padding: 8px 0; background: #fffbe6; border: 1px solid #ffe58f; border-radius: 3px; margin-bottom: 10px; padding: 10px 15px; display: none; }
</style>

<div class="subnav">
        <h2 class="title-1">多语言翻译管理</h2>
        <div class="content-menu">
                <a href="javascript:;" class="on"><em>翻译列表</em></a><span>|</span>
                <a href="<?php echo ADMIN_PATH?>&c=translate&a=add"><em>添加翻译</em></a>
        </div>
</div>

<div class="content-t">
        <!-- 筛选区域 -->
        <form action="" method="get" class="translate-filter">
                <input type="hidden" name="m" value="admin" />
                <input type="hidden" name="c" value="translate" />
                <label>源表：</label>
                <select name="filter_table" class="input-text" style="width:160px;">
                        <option value="">全部</option>
                        <?php foreach ($source_tables as $st): ?>
                        <option value="<?php echo $st;?>" <?php if ($filter_table == $st) echo 'selected';?>><?php echo isset($table_labels[$st]) ? $table_labels[$st] : $st;?></option>
                        <?php endforeach; ?>
                </select>
                <label>语言：</label>
                <select name="filter_lang" class="input-text" style="width:130px;">
                        <option value="">全部</option>
                        <option value="en-us" <?php if ($filter_lang == 'en-us') echo 'selected';?>>English</option>
                        <option value="my-mm" <?php if ($filter_lang == 'my-mm') echo 'selected';?>>မြန်မာ</option>
                </select>
                <label>关键词：</label>
                <input type="text" name="filter_keyword" class="input-text" style="width:160px;" value="<?php echo htmlspecialchars($filter_keyword);?>" placeholder="搜索翻译内容..." />
                <button type="submit" class="btn btn-primary">筛选</button>
                <a href="<?php echo ADMIN_PATH?>&c=translate" class="btn" style="background:#eee;border:1px solid #ccc;">重置</a>
        </form>

        <!-- 批量操作栏 -->
        <div class="batch-bar" id="batchBar">
                已选 <span id="selectedCount">0</span> 条 &nbsp;
                <a href="javascript:;" onclick="batchDelete();" class="btn btn-danger btn-sm">批量删除</a>
                <a href="javascript:;" onclick="cancelSelect();" class="btn btn-sm" style="background:#eee;border:1px solid #ccc;">取消选择</a>
        </div>

        <!-- 数据表格 -->
        <table class="translate-table">
                <thead>
                        <tr>
                                <th width="30"><input type="checkbox" id="checkAll" onclick="toggleCheckAll(this);" /></th>
                                <th width="50">ID</th>
                                <th width="110">源表</th>
                                <th width="80">源ID</th>
                                <th width="70">字段</th>
                                <th width="80">语言</th>
                                <th>翻译内容</th>
                                <th width="120">操作</th>
                        </tr>
                </thead>
                <tbody>
                        <?php if (empty($list)): ?>
                        <tr><td colspan="8" style="text-align:center;padding:30px;color:#999;">暂无翻译数据，<a href="<?php echo ADMIN_PATH?>&c=translate&a=add">点击添加</a></td></tr>
                        <?php else: ?>
                        <?php foreach ($list as $item): ?>
                        <tr id="list_<?php echo $item['id'];?>">
                                <td><input type="checkbox" class="item-check" value="<?php echo $item['id'];?>" /></td>
                                <td><?php echo $item['id'];?></td>
                                <td>
                                        <span class="badge badge-<?php echo $item['source_table'];?>">
                                                <?php echo isset($table_labels[$item['source_table']]) ? $table_labels[$item['source_table']] : $item['source_table'];?>
                                        </span>
                                </td>
                                <td><?php echo htmlspecialchars($item['source_id']);?></td>
                                <td><?php echo htmlspecialchars($item['field_name']);?></td>
                                <td>
                                        <span class="badge <?php echo $item['lang'] == 'en-us' ? 'badge-lang-en' : 'badge-lang-my';?>">
                                                <?php echo isset($lang_labels[$item['lang']]) ? $lang_labels[$item['lang']] : $item['lang'];?>
                                        </span>
                                </td>
                                <td class="value-cell" title="<?php echo htmlspecialchars($item['value']);?>"><?php echo htmlspecialchars(mb_substr($item['value'], 0, 60, 'UTF-8'));?></td>
                                <td>
                                        <a href="<?php echo ADMIN_PATH?>&c=translate&a=edit&id=<?php echo $item['id'];?>" class="btn btn-primary btn-sm">编辑</a>
                                        <a href="javascript:;" onclick="delItem(<?php echo $item['id'];?>);" class="btn btn-danger btn-sm">删除</a>
                                </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php endif; ?>
                </tbody>
        </table>

        <!-- 分页 -->
        <?php if ($totalpages > 1): ?>
        <div class="pagination">
                <?php
                $url_base = ADMIN_PATH . "&c=translate&filter_table={$filter_table}&filter_lang={$filter_lang}&filter_keyword=" . urlencode($filter_keyword) . "&page=";
                if ($page > 1): ?>
                <a href="<?php echo $url_base . ($page - 1);?>">上一页</a>
                <?php endif; ?>
                <?php
                $start = max(1, $page - 3);
                $end = min($totalpages, $page + 3);
                for ($i = $start; $i <= $end; $i++): ?>
                <?php if ($i == $page): ?>
                <span><?php echo $i;?></span>
                <?php else: ?>
                <a href="<?php echo $url_base . $i;?>"><?php echo $i;?></a>
                <?php endif; ?>
                <?php endfor; ?>
                <?php if ($page < $totalpages): ?>
                <a href="<?php echo $url_base . ($page + 1);?>">下一页</a>
                <?php endif; ?>
                &nbsp; 共 <?php echo $total;?> 条，第 <?php echo $page;?>/<?php echo $totalpages;?> 页
        </div>
        <?php endif; ?>
</div>

<script type="text/javascript">
        // 删除单条
        function delItem(id) {
                if (!confirm('确认删除此翻译记录？')) return;
                $.ajax({
                        url: '<?php echo ADMIN_PATH?>&c=translate&a=del&id=' + id,
                        type: 'GET',
                        dataType: 'json',
                        success: function(e) {
                                if (e.run == 'yes') {
                                        $('#list_' + id).fadeOut(300, function(){ $(this).remove(); });
                                } else {
                                        alert(e.msg);
                                }
                        },
                        error: function() { alert('操作失败'); }
                });
        }

        // 全选/取消
        function toggleCheckAll(el) {
                $('.item-check').prop('checked', el.checked);
                updateBatchBar();
        }

        // 更新批量操作栏
        function updateBatchBar() {
                var count = $('.item-check:checked').length;
                $('#selectedCount').text(count);
                $('#batchBar').toggle(count > 0);
        }

        // 取消选择
        function cancelSelect() {
                $('.item-check').prop('checked', false);
                $('#checkAll').prop('checked', false);
                updateBatchBar();
        }

        // 批量删除
        function batchDelete() {
                var ids = [];
                $('.item-check:checked').each(function(){ ids.push($(this).val()); });
                if (ids.length == 0) { alert('请选择要删除的记录'); return; }
                if (!confirm('确认删除选中的 ' + ids.length + ' 条记录？')) return;
                $.ajax({
                        url: '<?php echo ADMIN_PATH?>&c=translate&a=delall',
                        type: 'POST',
                        data: { ids: ids.join(',') },
                        dataType: 'json',
                        success: function(e) {
                                if (e.run == 'yes') {
                                        for (var i = 0; i < ids.length; i++) {
                                                $('#list_' + ids[i]).fadeOut(300, function(){ $(this).remove(); });
                                        }
                                        cancelSelect();
                                } else {
                                        alert(e.msg);
                                }
                        },
                        error: function() { alert('操作失败'); }
                });
        }

        // 监听复选框变化
        $(document).on('change', '.item-check', updateBatchBar);
</script>
</body>
</html>
