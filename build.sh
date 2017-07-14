docker build --rm -t ftpserver .
docker run --name ftpserver-app -v /mnt/db/gongcheng/wwwroot/zuoping:/home/wanghao -p 20:20 -p 21:21 -p 30000:30000 -p 30001:30001 -p 30002:30002 -p 30003:30003 -p 30004:30004 -p 30005:30005 -p 30006:30006 -p 30007:30007 -p 30008:30008 -p 30009:30009 -d ftpserver
