# 一款 PHP Chr 编码转换脚本

import re

# 定义解码函数，用于将 Chr 编码转换为字符串
def decode_chr(chr_values):
    # 提取出所有的数字（不区分大小写的 chr(数字)）
    numbers = re.findall(r'chr\((\d+)\)', chr_values, flags=re.IGNORECASE)  # 添加了 flags=re.IGNORECASE
    
    # 将每个提取到的数字转换为字符，并返回拼接的字符串
    return ''.join([chr(int(number)) for number in numbers])

# 定义编码函数，用于将字符串转换为 Chr 编码
def encode_chr(string):
    # 获取字符串的每个字符的 ASCII 编码，并转换为 chr() 形式（小写）
    return '.'.join([f'chr({ord(c)})' for c in string])  # 使用小写 'chr'

# 主程序
def main():
    print("请选择操作：")
    print("1. 编码")
    print("2. 解码")
    print("3. 退出")

    while True:
        choice = input("请输入操作编号: ")

        if choice == '1':
            # 编码操作
            user_input = input("请输入要编码的字符串：")
            encoded_string = encode_chr(user_input)
            print("编码结果：", encoded_string)

        elif choice == '2':
            # 解码操作
            user_input = input("请输入 chr 编码（例如 chr(1).chr(2)...）：")
            decoded_string = decode_chr(user_input)
            print("解码结果：", decoded_string)

        elif choice.lower() == '3':
            print("程序已退出")
            break
        else:
            print("无效输入，请输入 1 或 2。")

# 执行主程序
if __name__ == "__main__":
    main()
