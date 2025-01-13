#!/bin/bash
# Docker Compose 的安装脚本

install_docker_compose() {
    echo "准备安装 Docker Compose"

    # 定义重试次数和变量初始化
    MAX_ATTEMPTS=3                 # 最大重试次数
    attempt=0                      # 当前尝试次数
    cpu_arch=$(uname -m)           # 获取当前 CPU 架构
    success=false                  # 标志变量，用于判断是否成功
    save_path="/usr/local/bin"     # 安装路径

    # 根据 CPU 架构选择下载链接
    case $cpu_arch in
        "arm64" | "aarch64") # 适配 ARM 架构
            url="https://raw.gitcode.com/msmoshang/arl_files/blobs/91c90fdb2223045dcac604736d5428d1ae40d018/docker-compose-linux-aarch64"
            ;;
        "x86_64") # 适配 x86 架构
            url="https://raw.gitcode.com/msmoshang/arl_files/blobs/72eb38523db2f2c0b9645b2597d3ed9c9e778c7e/docker-compose-linux-x86_64"
            ;;
        *) # 不支持的架构处理
            echo "不支持的 CPU 架构: $cpu_arch"
            exit 1
            ;;
    esac

    # 检查 Docker Compose 是否已安装或是否损坏
    if ! command -v docker-compose &> /dev/null || [ -z "$(docker-compose --version)" ]; then
        echo "Docker Compose 未安装或安装不完整，开始安装..."
        
        # 下载和安装 Docker Compose，重试机制
        while [ $attempt -lt $MAX_ATTEMPTS ]; do
            attempt=$((attempt + 1))
            echo "尝试下载 Docker Compose (尝试次数: $attempt)..."
            
            # 下载文件
            wget --continue -q "$url" -O "$save_path/docker-compose"
            if [ $? -eq 0 ]; then
                chmod +x "$save_path/docker-compose" # 赋予执行权限
                version_check=$(docker-compose --version)
                if [ -n "$version_check" ]; then
                    success=true
                    echo "Docker Compose 安装成功，版本为：$version_check"
                    break
                else
                    echo "下载的文件不完整，删除并重新下载"
                    rm -f "$save_path/docker-compose"
                fi
            else
                echo "下载失败，正在尝试重新下载..."
            fi
        done

        # 检查重试后的结果
        if ! $success; then
            echo "多次尝试下载均失败，请检查网络连接或手动安装 Docker Compose"
            exit 1
        fi
    else
        # 已安装且版本可用
        echo "Docker Compose 已安装，版本为：$(docker-compose --version)"
    fi
}

# 执行安装函数
install_docker_compose
