#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -d "/var/lib/mysql" ] && [ -n "$(ls /var/lib/mysql)" ] ; then
    echo -e "${GREEN}'/var/lib/mysql/mysql' 不为空，跳过初始化, 直接运行 $@${NC}"
    exec $@
    exit 0
fi

echo -e "${GREEN}初始化 MySQL${NC}"

MYSQL_HOME="${MYSQL_HOME}"
MYSQL_USER="${MYSQL_USER}"
MYSQL_USER_PASSWORD="${MYSQL_USER_PASSWORD}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"

chown -R mysql:mysql "${MYSQL_HOME}"
chown -R mysql:mysql "/var/lib/mysql"

mysqld --initialize-insecure --user=mysql


printf '1. 启动 MySQL'
mysqld --skip-networking --user mysql &
mysql_pid="$!"

until mysqladmin ping >/dev/null 2>&1; do
    printf '.'
    sleep 1s
done
echo


echo '2. 运行脚本:'
ls "${MYSQL_HOME}" | grep "^mysql\.initdb\.d" | sort | while read dir;
do
    while read script; do
        if [ -n "${script}" ] && [ "${script:0:1}" != '#' ]; then
            echo "   * ${dir}/${script}"
            case ${script} in
                *.sh)   .       "${MYSQL_HOME}/${dir}/${script}" ;;
                *.sql)  mysql < "${MYSQL_HOME}/${dir}/${script}" ;;
    esac
        fi
    done < "${MYSQL_HOME}/${dir}/.list"
done


echo '3. 设置 MySQL root 和 user, 删除 test 数据库'
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

echo -e "${GREEN}初始化完成! 关闭 MySQL${NC}"
kill -s TERM "${mysql_pid}"
wait "${mysql_pid}"


chown -R mysql:mysql "${MYSQL_HOME}"
chown -R mysql:mysql "/var/lib/mysql"

echo -e "${GREEN}MySQL 关闭! 运行 $@${NC}"
exec $@