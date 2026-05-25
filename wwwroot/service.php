<?php
/**
 *  ┏┻━━━━━┻┓
 *  ┃　　　　　　  ┃
 *  ┃ ┳┛　  ┗┳ ┃
 *  ┃　　　┻　　  ┃
 *  ┗━┓　┏━━━┛
 *      ┃　┃神兽 保佑
 *      ┃　┃代码无BUG
 *      ┃　┗━━━━━━━━━┓
 *      ┃  资源驿站 zy13.net   ┣┓
 *      ┃　　 QQ:97887526　  ┏┛
 *      ┗━┓  ┏━━━┓  ┏┛
 *          ┗━┛      ┗━┛
 */ 
?>
<?php
// ========== 安全令牌验证 ==========
// 访问此页面需要在URL中带上 ?token=你的安全令牌
// 例如: http://yoursite.com/service.php?token=你的安全令牌
// 如果不提供正确token，将显示空白页面
define('SERVICE_TOKEN', 'g9FVgXM2XKjZH2SSITWaN4L6S5qEZgwy6RehiioXM10');
session_start();
$request_token = isset($_REQUEST['token']) ? trim($_REQUEST['token']) : '';
if ($request_token !== SERVICE_TOKEN) {
    // 安全模式：无token时返回空白，不暴露任何信息
    http_response_code(404);
    exit;
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
        <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
        <title>采集结算服务</title>
        <link rel="Shortcut Icon" href="favicon.ico" />
        <script type="text/javascript" src="statics/js/jquery-1.8.1.min.js"></script>
        <style type="text/css">
                body,ol,ul,h1,h2,h3,h4,h5,h6,p,th,td,dl,dd,form,fieldset,legend,input,textarea,select{margin:0;padding:0}
                body{font:12px"宋体","Arial Narrow",HELVETICA;background:#fff;-webkit-text-size-adjust:100%;}
                a{color:#2d374b;text-decoration:none}
                a:hover{color:#cd0200;text-decoration:underline}
                em{font-style:normal}
                li{list-style:none}
                img{border:0;vertical-align:middle}
                table{border-collapse:collapse;border-spacing:0}
                p{word-wrap:break-word}
                body {
                        padding: 10px;
                }
                .title h4 {
                        text-align: center;
                        line-height: 30px;
                        font-size: 16px;
                        background-color: #ededed;
                }
                .title h5 {
                        text-align: center;
                        line-height: 24px;
                        color: #fff;
                        background-color: #ffa5a5;
                }
                .list_box {
                        position: relative;
                        overflow: hidden;
                        margin-top: 10px;
                        padding: 1%;
                        background-color: #fcfcfc;
                }
                .list {
                        float: left;
                        width: 29.33%;
                        padding: 1%;
                        margin: 1%;
                        background-color: #ededed;
                }
                .list h4 {
                        line-height: 24px;
                }
                .list div p {
                        line-height: 18px;
                }
                .list div p#qishu {
                        color: #f00;
                }
                .list div p#haoma {
                        color: #07f;
                        font-size: 14px;
                        background-color: #ffa5a5;
                        line-height: 30px;
                        text-align: center;
                }
                .list div p#msg {
                        color: #999;
                        font-size: 12px;
                        background-color: #dfdfdf;
                        line-height: 20px;
                        height: 20px;
                        overflow: hidden;
                }
                .list div p#next {
                        text-align: right;
                }
                .list div p span#time {
                        color: #ff6600;
                        margin-right: 8px;
                }
        </style>
</head>
<body>
<div class="title">
        <h4>采集结算服务</h4>
        <h5>请勿关闭此服务，如发现异常请尝试重启页面</h5>
</div>
<div class="list_box">
        <div id="lottery_1" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
        <div id="lottery_2" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
        <div id="lottery_3" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
        <div id="lottery_4" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
        <div id="lottery_5" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
        <div id="lottery_6" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
        <div id="lottery_7" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
        <div id="lottery_8" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="qishu">第0期</p>
                        <p id="haoma">000</p>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求下一期</p>
                </div>
        </div>
</div>
<div class="list_box">
        <div id="service_1" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
        <div id="service_2" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
        <div id="service_3" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
        <div id="service_4" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
        <div id="service_5" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
        <div id="service_6" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
        <div id="service_7" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
        <div id="service_8" class="list">
                <h4>彩种</h4>
                <div>
                        <p id="msg"></p>
                        <p id="next"><span id="time">0</span>秒后请求结算</p>
                </div>
        </div>
</div>

<script type="text/javascript">
$(document).ready(function() {
        var t = Date.parse(new Date()); //当前时间戳
        var lottery_name = ['a', 'cqssc', 'gdkl', 'xync', 'pcdd', 'jnd28', 'pk10', 'teqdd', 'jsssc'];
        var service_token = '<?php echo md5(SERVICE_TOKEN . session_id()); ?>'; // 安全令牌
        var lottery_fun = function(id, t) {
                clearTimeout(window['timeend_'+id]);//结束执行
                $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        url: 'api.php?op=game_service&t=' + t,
                        data: {gameid:id,lotteryname:lottery_name[id],service_token:service_token},
                        success: function(data) {
                                //console.log(data);
                                if (data.state == 1) {
                                        $('#lottery_'+id+' h4').text(data.name);
                                        $('#lottery_'+id+' #qishu').text(data.last);
                                        $('#lottery_'+id+' #haoma').text(data.code);
                                        $('#lottery_'+id+' #msg').text(data.msg);
                                        window['time_'+id] = data.time;
                                        var t = Date.parse(new Date()); //当前时间戳
                                        if (data.time > 0) {
                                                setTimeout(function(){
                                                        lottery_fun(id, t);
                                                },data.time * 1000);
                                        }
                                        window['timeend_'+id] = setInterval(function(){
                                                window['time_'+id]--;
                                                $('#lottery_'+id+' #time').text(window['time_'+id]);
                                        },1000);
                                }
                        },
                        error: function() {
                                setTimeout(function() {
                                        var t = Date.parse(new Date());//当前时间戳
                                        lottery_fun(id, t);//5秒重试
                                }, 5000);
                        }
                });
        },service_fun = function(id, t) {
                clearTimeout(window['service_timeend_'+id]);//结束执行
                $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        url: 'api.php?op=game_service&t=' + t,
                        data: {gameid:id,lotteryname:lottery_name[id],account:1,service_token:service_token},
                        success: function(data) {
                                //console.log(data);
                                if (data.state == 1) {
                                        $('#service_'+id+' h4').text(data.name);
                                        $('#service_'+id+' #msg').text(data.msg);
                                        window['service_time_'+id] = data.time;
                                        var t = Date.parse(new Date()); //当前时间戳
                                        if (data.time > 0) {
                                                setTimeout(function(){
                                                        service_fun(id, t);
                                                },data.time * 1000);
                                        }
                                        window['service_timeend_'+id] = setInterval(function(){
                                                window['service_time_'+id]--;
                                                $('#service_'+id+' #time').text(window['service_time_'+id]);
                                        },1000);
                                }
                        },
                        error: function() {
                                setTimeout(function() {
                                        var t = Date.parse(new Date());//当前时间戳
                                        service_fun(id, t);//5秒重试
                                }, 5000);
                        }
                });
        };
        
        lottery_fun(1, t);
        lottery_fun(2, t);
        lottery_fun(3, t);
        lottery_fun(4, t);
        lottery_fun(5, t);
        lottery_fun(6, t);
        lottery_fun(7, t);
        lottery_fun(8, t);
        
        service_fun(1, t);
        service_fun(2, t);
        service_fun(3, t);
        service_fun(4, t);      
        service_fun(5, t);
        service_fun(6, t);
        service_fun(7, t);
        service_fun(8, t);
        console.log('执行');
});
</script>
</body>
</html>