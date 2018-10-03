#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -d "/var/lib/mysql/mysql" ]; then
    echo -e "${GREEN}MySQL数据文件夹不为空，跳过初始化, 执行 CMD${NC}"
    exec $@
    exit 0
fi


echo -e "${GREEN}初始化MySQL${NC}"

if [ -z "${MYSQL_USER}" ]; then
    echo -e "${RED}必须为MySQL设置一个连接用户，因为root只能用于本地连接${NC}"
    exit 1
fi

chown -R mysql:mysql "${MYSQL_HOME}"
chown -R mysql:mysql "/var/lib/mysql"

mysqld --initialize-insecure --user=mysql


printf ' ---> 启动MySQL'
mysqld --skip-networking --user mysql &
mysql_pid="$!"

until mysqladmin ping >/dev/null 2>&1; do
    printf '.'
    sleep 1s
done
echo


echo ' ---> 运行初始化脚本:'
while read script; do
    if [ -n "$script" ] && [ "${script:0:1}" != '#' ]; then
        echo "    * ${script}"
        case ${script} in
            *.sh)   .       "${MYSQL_HOME}/mysql.initdb.d/${script}" ;;
            *.sql)  mysql < "${MYSQL_HOME}/mysql.initdb.d/${script}" ;;
        esac
    fi
done < "${MYSQL_HOME}/mysql.initdb.d/mysql.initdb.list"

echo ' ---> 设置 MySQL root 和 user, 删除 test 数据库'
mysql <<-EOSQL
    USE \`mysql\`;
    DELETE FROM user WHERE host != 'localhost' OR user NOT IN ('mysql.session', 'mysql.sys', 'root');
    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
    GRANT ALL ON *.* TO 'root'@'localhost';
    CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
    GRANT ALL ON *.* TO '${MYSQL_USER}'@'%';
    DROP DATABASE IF EXISTS test;
    FLUSH PRIVILEGES;
EOSQL

echo -e "${GREEN}初始化完成! 关闭 MySQL, 执行 CMD${NC}"
kill -s TERM "${mysql_pid}"
wait "${mysql_pid}"


chown -R mysql:mysql "${MYSQL_HOME}"
chown -R mysql:mysql "/var/lib/mysql"


exec $@