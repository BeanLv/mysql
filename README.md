# MYSQL 数据库镜像

基于 `MySQL 5.7` 构建镜像，在 `docker-entrypoint.sh` 中初始化数据库

## 初始化
1. 容器启动时检查 `/var/lib/mysql/mysql` 是否为空，如果不为空表明数据库已经初始化. 直接执行CMD.
2. 如果文件夹为空, 按下面步骤执行初始化:
   * 检查 `${MYSQL_USER}` 是否为空，如果没有设置 MYSQL 用户，不允许初始化，因为数据库需要一个连接用户.
   * 运行 `/usr/local/mysql/mysql.initdb.d` 中的脚本，初始化数据库。执行顺序在 `mysql.initdb.list` 中指定. 由于用的是 while read 逐行读取，最后必须多出一个空行，并且空行后的内容不会再读取.
   * 设置 root 只能本地连接，密码是 `${MYSQL_ROOT_PASSWORD}`，不设置的话默认是空.
   * 用 `${MYSQL_USER}` 和 `${MYSQL_USER_PASSWORD}` 创建MySQL用户，密码不设置的话默认是空.
   * 删除 test 数据库

## MySQL 配置
1. 镜像默认使用 `mysql.config.d` 中的文件作为配置.

# 构建子镜像
根据数据库初始化的方式，可以按照需要构建一个子镜像:
1. 将数据库初始化脚本复制到 `mysql.initdb.d` 中，在 `mysql.initdb.list` 中设置执行顺序
2. 将配置文件复制到 `mysql.conf.d` 中，覆盖或者新增原有配置. 也可以用 RUN 命令直接修改原有的配置文件.
3. 可以将 /var/lib/mysql 映射到本地文件夹上，这样一来新的容器只在第一次启动的时候执行初始化，而且数据库数据也可以持久化到本地上。

# 利用 Docker volume 映射文件夹，直接启动镜像
1. 不构建子镜像，直接使用基础镜像。将数据库初始化文件和配置文件映射到容器中.
2. 同样的，也可以将 /var/lib/mysql 映射到本地文件夹上.

# 利用现有的数据库文件夹启动镜像
1. 如果在本地已经有一个数据库文件夹，可以直接将这个文件夹映射进去，启动容器，继续使用里面的数据.

## 测试
1. `docker-compose.yml` 和 mysql.initdb.d.test 文件夹中的脚本是用来做测试用的，采用直接映射文件夹的方式启动镜像。启动时指定下面三个环境变量
   * `${MYSQL_USER}` 默认为 test
   * `${MYSQL_USER_PASSWORD}` 默认为空
   * `${MYSQL_ROOT_PASSWORD}` 默认为空
2. 容器启动后 MySQL `3306` 的端口映射到 `3307` 上