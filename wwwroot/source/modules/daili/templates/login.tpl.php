<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <title>代理登陆</title>
        <meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no" />
        <link rel="Shortcut Icon" href="favicon.ico" />
        <link href="statics/css/global.css" rel="stylesheet" type="text/css" />
        <link href="statics/css/login.css" rel="stylesheet" type="text/css" />
</head>
<body>
<div class="login_box">
        <div class="login">
                <div class="title">代理登陆</div>
                <div class="login_ibox">
                        <form action="index.php?m=daili&c=login&a=logind" method="post" id="form">
                                <div class="input_box">
                                        <div class="input_caption">
                                                <img src="statics/images/user.png" class="input_caption_img">
                                        </div>
                                        <div class="input_value">
                                                <input type="text" id="input-u" name="username" value="" placeholder="输入代理用户名" />
                                        </div>
                                </div>
                                <div class="input_box">
                                        <div class="input_caption">
                                                <img src="statics/images/pwd.png" class="input_caption_img">
                                        </div>
                                        <div class="input_value">
                                                <input type="password" id="input-p" name="password" value="" placeholder="输入密码" />
                                        </div>
                                </div>
                                <div class="btn_box">
                                        <div class="input_box">
                                                <div class="input_caption">
                                                        <img src="statics/images/yzm.png" class="input_caption_img">
                                                </div>
                                                <div class="input_value">
                                                        <input type="text" id="input-c" name="code" value="" placeholder="验证码" />
                                                </div>
                                                <div class="input_value">
                                                        <img id='code_img' style='cursor:pointer;' title='看不清?点击换一张' onclick='this.src=this.src+"&"+Math.random()' src='api.php?op=checkcode&code_len=4&font_size=14&width=84&height=22&font=&font_color=&background=%23FFFFFF&charset=&rand=23063' />                                          </div>
                                        </div>
                                        <input class="login_btn" type="submit" value="登陆" />
                                </div>
                        </form>
                </div>
        </div>
</div>
</body>
</html>
