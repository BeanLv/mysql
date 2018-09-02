1. 这只是一个占位文件，保证 mysql.initdb.d 这个文件夹不为空，会被 git 上传

2. 容器启动时，docker-enptripoint.sh 会检查 /usr/lib/mysql/mysql 
是否为空。如果为空，说明数据库还没有安装使用。于是启动 MySQL Server,
运行该文件夹下的 *.sql 和 *.sh 脚本，执行初始化操作

3. 参照镜像的 README 文件