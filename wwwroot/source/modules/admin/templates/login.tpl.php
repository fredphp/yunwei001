<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8 />
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
	<title>后台登陆A天山</title>
	<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no" />
	<link rel="Shortcut Icon" href="favicon.ico" />
	<link href="statics/css/global.css" rel="stylesheet" type="text/css" />
	<link href="statics/css/login.css" rel="stylesheet" type="text/css" />
</head>
<body>
<div class="login_box">
	<div class="login">
		<div class="title">后台登陆</div>
		<div class="login_ibox">
			<form action="index.php?m=admin&c=login&a=logind" method="post" id="form">
				<div class="input_box">
					<div class="input_caption">
						<img src="statics/images/user.png" class="input_caption_img">
					</div>
					<div class="input_value">
						<input type="text" id="input-u" name="username" value="" placeholder="请输入用户名" />
					</div>
				</div>
				<div class="input_box">
					<div class="input_caption">
						<img src="statics/images/pwd.png" class="input_caption_img">
					</div>
					<div class="input_value">
						<input type="password" id="input-p" name="password" value="" placeholder="请输入密码" />
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
							<img id='code_img' style='cursor:pointer;' title='看不清楚?点击更换' onclick='this.src=this.src+"&"+Math.random()' src='api.php?op=checkcode&code_len=4&font_size=14&width=84&height=22&font=&font_color=&background=%23FFFFFF&charset=&rand=23228' />						</div>
					</div>
					<input class="login_btn" type="submit" value="登陆" />
				</div>
			</form>
		</div>
	</div>
</div>
</body>
