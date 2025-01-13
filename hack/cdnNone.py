import os
import sys
import socket

print('''
This script is used to detect domains without CDN.

Usage:
    python cdnNone.py -d fileName.txt -o fileName.txt

Flags:
    -d fileName.txt    # The file contains the list of domains.
    -o fileName.txt    # The file where domains without CDN will be saved.
''')

# 检查传入参数的有效性
if len(sys.argv) >= 5:
    # 定义传入参数 -d 和 -o
    if sys.argv[1] == "-d" and sys.argv[3] == "-o":
        domain_list = sys.argv[2]
        cdn_none = sys.argv[4]
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
result_write = open(cdn_none, 'w', encoding='utf-8')
result_write.close()
# 以追加模式打开结果文件
result_write = open(cdn_none, 'a', encoding='utf-8')

# 逐行读取域名文件的内容
for line in domain_read:
    # 格式化读取的内容
    test_domain = line.strip()
    print(' ')
    print('Testing:', test_domain)
    # 尝试获取域名的 A 记录
    try:
        ip_address = socket.getaddrinfo(test_domain, None)
    # 若无法获取 A 记录则跳过
    except socket.gaierror:
        continue
    # 初始化计数器
    ip_count = 0
    # 初始化一个 set 集合用于去重
    unique_ip = set()
    # 从 A 记录中提取 IP 地址
    for ip_all in ip_address:
        test_ip = ip_all[4][0]
        print(test_ip)
        # 添加到 set 集合去重
        unique_ip.add(test_ip)
    # 统计 IP 出现的次数
    ip_count = len(unique_ip)
    # 将只有一个 IP 的域名追加到结果文件
    if ip_count == 1:
        result_write.write(test_domain + '\n')

print(' ')
print('The domains without CDN have been saved to:', cdn_none)