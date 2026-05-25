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
define('MYFILE_PATH', dirname(__FILE__) . DIRECTORY_SEPARATOR);
include MYFILE_PATH . '/source/base.php';
$param = base :: load_sys_class('param');
$op = isset($_REQUEST['op']) && trim($_REQUEST['op']) ? trim($_REQUEST['op']) : exit('Operation can not be empty');
if (!preg_match('/([^a-z_]+)/i', $op) && file_exists('api' . DIRECTORY_SEPARATOR . $op . '.php')) {
	include 'api' . DIRECTORY_SEPARATOR . $op . '.php';
} else {
	exit('API handler does not exist');
} 

?>