
# Centos7搭建你Gitlab简要记录

```
yum makecache
yum install curl policycoreutils openssh-server openssh-clients
yum install postfix
systemctl enable postfix
systemctl start postfix
firewall-cmd --permanent --add-service=http
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh  -o script.rpm.sh
sh script.rpm.sh
yum clean all && yum makecache  #  如果有问题可以直接关掉yum文件里面的检查
yum install gitlab-ce

vim  /etc/gitlab/gitlab.rb   #  修改配置文件写自己的域名，如果需要自己设置数据存放路径也可以修改，默认存放：/var/opt/gitlab/git-data/repositories/
external_url 'http://testgit.mwteck.com'

gitlab-ctl reconfigure　　#  启动会自己执行脚本创建需要的一切，并且启动服务
gitlab-ctl restart
systemctl  enable  gitlab-runsvdir
```

* 访问 GitLab页面

如果没有域名，直接输入服务器ip和指定端口进行访问

初始账户: root:5iveL!fe　第一次登录修改密码




# FQA:
1. 数据存放在哪儿：
默认存放在/var/opt/gitlab/git-data/repositories/，可以通过修改配置文件修改
