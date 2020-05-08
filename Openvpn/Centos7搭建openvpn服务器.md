# centos7搭建openvpn服务器

yum install -y openssl-devel lzo-devel pam-devel automake pkgconfig makecache
yum install openvpn
yum install -y easy-rsa

cp -R /usr/share/easy-rsa/ /etc/openvpn/
cp /usr/share/doc/openvpn-2.4.7/sample/sample-config-files/server.conf /etc/openvpn/
cp -r /usr/share/doc/easy-rsa-3.0.3/vars.example /etc/openvpn/easy-rsa/3.0/vars
