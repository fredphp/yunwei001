//layer图标 0:警告1:正确2:错误3:询问4:锁5:苦脸6:笑脸
/**
 * layer 函数封装，无确认提示AJAX操作
 * url 地址
 * types 无id=无动作,1=AJAX删除,2=AJAX替换
*/
function showmin(url, types, fun) {
        var loading = layer.load(2);
        $.get(url, '', function(sdata) {
                var data = $.parseJSON(sdata);
                layer.close(loading);
                if (data.status == 'y') {
                        if (data.id) {
                                if (types == 1) { //AJAX删除ID
                                        $('#' + data.id).detach();
                                } else if (types == 2) { //AJAX替换ID,数组
                                        var len = data.id.length;
                                        for (var i = 0; i < len; i++) {
                                                $('#' + data.id[i].id).html(data.id[i].htm);
                                        }
                                }
                        }
                        if (data.info) {
                                layer.msg(data.info, {
                                        icon: 6
                                });
                        }
                        if (fun) {
                                fun(data.rid);
                        }
                } else {
                        layer.msg(data.info, {
                                icon: 5
                        });
                }
        });
}
/**
 * 确认窗口 API
 * url 地址
 * msg 消息提示信息
 * type 类型0=AJAX删除,1=AJAX替换,2=确认跳转,3=表单提交
 * load 显示等待
 * re 成功是否刷新页面
 * 返回：run=失败成功,loading=关闭等待,msg=操作状态,id=操作信息ID
*/
function showwindow(url, msg, type, load, re) {
        layer.confirm(msg, {
                title: __('info'),
                btn: [__('confirm'), __('cancel')] //按钮
        }, function() {
                if (type == 3) { //表单提交
                        $('#' + url).submit(); //提交
                } else if (type == 2) { //确认跳转
                        location.href = url;
                } else { //AJAX
                        if (load == 1) var loading = layer.load(2);
                        $.get(url, '', function(sdata) {
                                var data = $.parseJSON(sdata);
                                if (load == 1) layer.close(loading);
                                if (data.run == 'yes') {
                                        if (data.id) {
                                                if (!type) { //AJAX删除ID
                                                        $('#' + data.id).detach();
                                                } else if (type == 1) { //AJAX替换ID,数组
                                                        var len = data.id.length;
                                                        for (var i = 0; i < len; i++) {
                                                                $('#' + data.id[i].id).html(data.id[i].htm);
                                                        }
                                                }
                                        }
                                        layer.msg(data.msg, {
                                                icon: 6
                                        });
                                        if (re) {
                                                setTimeout(function() {
                                                        location.reload();
                                                }, 1000);
                                        }
                                } else {
                                        layer.msg(data.msg, {
                                                icon: 5
                                        });
                                }
                        });
                }
        }, function() {

        });
}

/**
 * tips触发层
 * id 触发#id或.class
 * msg 消息提示信息
 * time 消失时间，毫秒
 * btn 0不显示关闭按钮
 * color 颜色
*/
function showtips(id, msg, time, btn, color) {
        layer.tips(msg, id, {
                tips: [1, color ? color : '#333C59'], //配置颜色
                time: time ? time : 3000,
                closeBtn: btn ? btn : 0 //显示关闭按钮
        });
}

/**
 * layer 弹出窗口函数封装
 * type 弹窗类型 0默认信息框 1页面层 2iframe层 3加载层 4tips层
 * data 对应弹窗类型的数据 1页面层元素 2URL 3html
 * title 窗口标题
 * w 窗口宽度
 * h 窗口高度
 * mm 最大化最小化按钮
 * shade 遮罩层
 * mw 最大宽度
 * mh 最大高度
 * index 自定义层
 * full 是否全屏
 * anim 0默认平滑放大 1从上掉落 2从最底部往上滑入 3从左滑入 4从左翻滚 5渐显 6抖动
 */
var win;
function showlayer(type, title, data, w, h, mm, shade, mw, mh, index, full, anim) {
        win = layer.open({
                type: type,
                content: data, //捕获的元素，注意：最好该指定的元素要存放在body最外层，否则可能被其它的相对元素所影响
                title: title ? title : false, //不显示标题
                area: w && h ? [w, h] : 'auto',
                maxmin: mm ? false : true, //默认开启最大化最小化按钮
                shade: shade ? shade : false, //显示遮罩层shade: 0.2 | shade: [0.2, '#000']
                shadeClose: true, //是否点击遮罩关闭
                maxWidth: mw ? mw : 800,
                maxHeight: mh ? mh : 500,
                zIndex: index ? index : layer.zIndex, //窗口层
                anim: anim ? anim : 0, //显示方式
                success: function(layero){ //层弹出后的成功回调方法
                        if (!index) layer.setTop(layero); //窗口置顶
                }
        });
        if (full) layer.full(win);
}

function placeholder(obj) {
        //浏览器不支持 placeholder 时才执行
        if (!('placeholder' in document.createElement('input'))) {
                if (obj) {
                        var DOM = $(obj);
                } else {
                        var DOM = $('body');
                }
                DOM.find('[placeholder]').each(function() {
                        var tag = $(this); //当前 input
                        tag.unbind('focus blur');// 解绑focus blur事件
                        var placeholder = tag.attr('placeholder'); //当前 placeholder
                        if (tag.val() == '') {
                                tag.css('color', '#999');
                                tag.val(placeholder);
                        }
                        tag.focus(function() {
                                if (this.value == placeholder) {
                                        this.value = '';
                                        this.style.color = '#444';
                                }
                        });
                        tag.blur(function() {
                                if (this.value == '') {
                                        this.value = placeholder;
                                        this.style.color = '#999';
                                }
                        });
                });
        }
}

//COOKIE
document.getCookie = function(sName) {
        var aCookie = document.cookie.split("; ");
        for (var i = 0; i < aCookie.length; i++) {
                var aCrumb = aCookie[i].split("=");
                if (sName == aCrumb[0]) return decodeURIComponent(aCrumb[1]);
        }
        return null;
}

document.setCookie = function(sName, sValue, sExpires) {
        var sCookie = sName + "=" + encodeURIComponent(sValue);
        if (sExpires != null) {
                sCookie += "; expires=" + sExpires;
        }
        document.cookie = sCookie;
}

document.removeCookie = function(sName, sValue) {
        document.cookie = sName + "=; expires=Fri, 31 Dec 1999 23:59:59 GMT;";
}