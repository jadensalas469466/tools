#!/bin/bash

# 错误检测
set -e

# 获取链接的实际路径并切换到该目录
cd "$(dirname "$(readlink -f "$0")")"

# 使用说明
echo "
This script is used to get the IP address from domains.

Usage: proxy <ip:port>
"

# 清除代理
unset http_proxy
unset https_proxy
unset ftp_proxy
unset no_proxy

# 输出结果
if [ -z "$1" ]; then
    echo "Proxy is unset."
    exit 1
fi

# 保存命令行参数到变量
PROXY="$1"

# 配置代理
export http_proxy="http://$PROXY"
export https_proxy="http://$PROXY"
export ftp_proxy="http://$PROXY"
export no_proxy="localhost,127.0.0.1,::1"

# 输出结果
echo "Proxy set to: http://$PROXY"