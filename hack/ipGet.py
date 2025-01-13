import os
import sys
import socket

print('''
This script is used to get the IP address from domains.

Usage:
    python ipGet.py -d fileName.txt -o fileName.txt

Flags:
    -d fileName.txt    # The file contains the list of domains.
    -o fileName.txt    # The file where the IP address will be saved.
''')

# 检查传入参数的有效性
if len(sys.argv) >= 5:
    # 定义传入参数 -d 和 -o
    if sys.argv[1] == "-d" and sys.argv[3] == "-o":
        domain_list = sys.argv[2]
        ip_get = sys.argv[4]
    else:
        sys.exit(0)
else:
    sys.exit(0)

# 检查文件路径的有效性
if not os.path.isfile(domain_list):
    print('No such file or directory:', domain_list)
    sys.exit(0)

# 以只读模式打开域名文件
domain_read = open(domain_list, 'r', encoding='utf-8')
# 清空结果文件
result_write = open(ip_get, 'w', encoding='utf-8')
result_write.close()
# 以追加模式打开结果文件
result_write = open(ip_get, 'a', encoding='utf-8')

# 逐行读取域名文件的内容
for line in domain_read:
    # 格式化读取的内容
    test_domain = line.strip()
    print(' ')
    print('Testing:', test_domain)
    # 尝试获取域名的 IP
    try:
        ip_address = socket.gethostbyname(test_domain)
    # 若无法获取 IP 则跳过
    except socket.gaierror:
        continue
    # 将 IP 追加到结果文件
    result_write.write(ip_address + '\n')

print(' ')
print('The IP address have been saved to:', ip_get)