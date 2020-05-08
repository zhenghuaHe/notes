# nginx 流量复制范例

```
server {
    listen    80;
    server_name api.t4.com;
    root /usr/share/nginx/html;
    access_log  /var/log/nginx/api.log  syslog;
    location / {
        mirror /t4 ;
        add_header 'Access-Control-Allow-Origin' $http_origin;
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,web-token,app-token,Authorization,Accept,Origin,Keep-Alive,User-Agent,X-Mx-ReqToken,X-Data-Type,X-Auth-Token,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass    http://172.16.1.202:30501;
    }
    location = /t4 {
        proxy_read_timeout 3s;
        internal;
        proxy_pass http://172.16.1.10:3000$request_uri;
    }


```
