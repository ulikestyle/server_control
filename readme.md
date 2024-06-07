#配置说明
- config.yml 
  - sshuser: root #连接服务器的用户名
  - sshkeyfile: /Users/xxx/.ssh/id_rsa #连接服务器的sshkey路径位置
    
#需要操作的ip列表
- ip_list.txt #ip列表，一行一个

#需要执行的指令
- cmd.txt #一行或者多行(多行会自动合并)
