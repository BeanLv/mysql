#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

if [ -d "/var/lib/mysql/mysql" ]; then
    echo -e "${GREEN}MySQL data dir is not empty. Skip the initialization process${NC}"
    exit 0
fi


echo -e "${GREEN}Setup MySQL and run scripts to init db${NC}"
mysqld --initialize-insecure --user=mysql


printf ' ---> Start MySQL'
mysqld --skip-networking --user mysql &
mysql_pid="$!"

until mysqladmin ping >/dev/null 2>&1; do
    printf '.'
    sleep 1s
done
echo


echo ' ---> Run scripts:'
while read script; do
    if [ -n "$script" ] && [ "${script:0:1}" != '#' ]; then
        echo "    * ${script}"
        case $script in
            *.sh)   .       "${MYSQL_HOME}/mysql.initdb.d/${script}" ;;
            *.sql)  mysql < "${MYSQL_HOME}/mysql.initdb.d/${script}" ;;
        esac
    fi
done < "${MYSQL_HOME}/mysql.initdb.d/mysql.initdb.list"


echo -e "${GREEN}Succeed! Shutdown MySQL${NC}"
kill -s TERM "${mysql_pid}"
wait "${mysql_pid}"


exit $@