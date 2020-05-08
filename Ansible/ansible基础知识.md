# Ansible基础知识

* ansible是什么？
    >  Ansible是一款批量管理工具，不用安装agent就可以远程操作各个机器做任何事情。

    - 可以用户管理那些资源？
   1.  管理docker机器
   2.  用Vagrant管理虚拟机器
   3.  管理物理机[这里主要讲物理机]。

* 如何使用？
   1. Ad-Hoc command。通过命令行的形式去执行操作
   2. Playbook 。同过写好yaml文件统一去执行操作

```
# 范例
$ vi hello_world.yml
---

- name: say 'hello world'
  hosts: all
  tasks:

    - name: echo 'hello world'
      command: echo 'hello world'
      register: result

    - name: print stdout
      debug:
        msg: ""

$ ansible-playbook hello_world.yml
```



* 常用模块
1. 命令

    > 命令  模块是个可以在远端上执行指令的指令模组（Commands Modules），Linux Shell的指令都可以透过它使用。但它不支持变数（变量）和<、>、|、;、&等特殊运算

```
1. 重新开机。

- name: Reboot at now
 command: /sbin/shutdown -r now

2. 当某个档案不存在时才执行该指令。

- name: create .ssh directory
 command: mkdir .ssh creates=.ssh/

3. 先切换目录再执行指令。

- name: cat /etc/passwd
 command: cat passwd
 args:
   chdir: /etc

```

2. 复制

    > copy  module是从本地复制档案到远端的档案模组（Files Modules），其类似的Linux指令为  scp。

```
1. 复制ssh public key到远端（ chmod 644 /target/file）。

- name: copy ssh public key to remote node
 copy:
   src: files/id_rsa.pub
   dest: /home/docker/.ssh/authorized_keys
   owner: docker
   group: docker
   mode: 0644

2. 复制ssh public key到远端（ chmod u=rw,g=r,o=r /target/file）。

- name: copy ssh public key to remote node
 copy:
   src: files/id_rsa.pub
   dest: /home/docker/.ssh/authorized_keys
   owner: docker
   group: docker
   mode: "u=rw,g=r,o=r"

3. 复制nginx vhost设定档到远端，并备份原有的档案。

- name: copy nginx vhost and backup the original
 copy:
   src: files/ironman.conf10.64.104.44
10.64.104.45
10.64.104.46
   dest: /etc/nginx/sites-available/default
   owner: root
   group: root
   mode: 0644
   backup: yes

```

3. 文件

    > 文件 模块会在远端建立和删除档案（文件），目录（目录），软连结（符号连接）的档案模组（文件的模块）。其类似的Linux的的的指令为  chown 、chown、ln、mkdir  和  touch。

```
1. 建立档案（ touch），并设定档案权限为644。

    - name: touch a file, and set the permissions
     file:
       path: /etc/motd
       state: touch
       mode: "u=rw,g=r,o=r"

2.  建立目录（ mkdir），并设定档案拥有者为docker。

    - name: create a directory, and set the permissions
     file:
       path: /home/docker/.ssh/
       state: directory
       owner: docker
       mode: "700"

3.   建立软连结（ ln）。

    - name: create a symlink file
     file:
       src: /tmp
       dest: /home/docker/tmp
       state: link

```

4. 服务

    > service  module是个用来管ansible_python_version理远端系统服务的系统模组（System Modules）。其类似的Linux指令为  service 。

```
1. 启用nginx的的。

- name: start nginx service
 service:
   name: nginx
   state: started

2. 停止nginx的的。

- name: stop nginx service
 service:
   name: nginx
   state: stopped

3. 重开网路服务。

- name: restart network service
 service:
   name: network
   state: restarted
   args: eth0
```

5. Template模块

    > 可以用作模板，设置变量给不同的环境部署不同的东西
