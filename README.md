# MYSQL 数据库镜像

基于 `MySQL Community 5.7` 构建镜像，在 `docker-entrypoint.sh` 中初始化数据库。

## 初始化
1. 容器启动时检查 `/var/lib/mysql/mysql` 是否为空，如果不为空表明数据库已经初始化。 直接执行 CMD。
2. 如果文件夹为空, 按下面步骤执行初始化:
   * 检查 `${MYSQL_USER}` 是否为空，如果没有设置 MYSQL 用户，不允许初始化，因为数据库需要一个连接用户。
   * 使用 `mysql` 在默认的 `/var/lib/mysql` 中安装数据库文件夹。
   * 遍历 `${MYSQL_HOME}` 目录下所有前缀为 `mysql.initdb.d` 的文件夹，逐行读取文件夹下 `.list` 文件指定的 `sql\sh` 脚本并执行它们。由于用的是 `while read` 逐行读取，所以 `.list` 文件最后必须多出一个空行，并且空行后的内容不会再读取。如果没有 `mysql.initdb.d*` 文件夹，则不运行任何脚本。
   * 设置 `root` 只能本地连接，密码是 `${MYSQL_ROOT_PASSWORD}`，不设置的话默认是空。
   * 用 `${MYSQL_USER}` 和 `${MYSQL_USER_PASSWORD}` 创建 MySQL 用户，密码不设置的话默认是空。
   * 删除 `test` 数据库。

### 示例:
```
   ${MYSQL_HOME}:
     - mysql.initdb.d
       - .list
       - schema.sql
     - mysql.initdb.d.sandbox
       - .list
       - data.sql
       - some.sh

   # 第一个 .list 中的文件内容为两行: schema.sql 和 空行；
   # sandbox 中的 .list 文件中的内容为三行: data.sql、some.sh 和 空行。

   初始化程序将依次执行: schema.sql、data.sql 和 some.sh 三个脚本
```

## MySQL 配置
1. 镜像默认使用 `mysql.conf.d` 中的文件作为配置。

## 如何使用该镜像

### 构建子镜像
1. 将数初始化脚本复制到一个或多个 `mysql.initdb.d.*` 文件夹中，在 `.list` 中设置执行顺序。
2. 将配置文件复制到 `mysql.conf.d` 中，覆盖或者新增原有配置。也可以在 build 的时候 RUN 命令修改原有的配置文件。
3. 可以将 `/var/lib/mysql` 映射到本地文件夹上，这样一来新的容器只在第一次启动的时候执行初始化，而且数据库数据也可以持久化到本地上。

### 利用 Docker Volume 映射文件夹，启动一个数据库
1. 不同于建子镜像。该方式将初始化脚本和配置文件映射到容器对应的文件夹下。容器在第一次运行的时候就会用这些文件初始化数据库。
2. 也可以不提供任何初始化脚本来启动一个空的数据库。
2. 同样的，也可以将 `/var/lib/mysql` 映射到本地文件夹上，达到持久化的目的。
3. 如果在本地已经有一个数据库文件夹(通常是出于备份目的), 可以启动一个新容器，将这个文件夹映射进去，继续使用里面的数据。但是要考虑自定义的 `mysql.conf.d` 没有备份的情况。

### 开发和测试
1. 如果不想在本地安装 MySQL，或者是需要多个 MySQL 服务对多个项目，可以利用 `docker-compose.yml` 启动一个容器，包含一个空的数据库和一下配置:
   * `${MYSQL_USER}` 默认为 test
   * `${MYSQL_USER_PASSWORD}` 默认为空
   * `${MYSQL_ROOT_PASSWORD}` 默认为空
   * `mysql.conf.d` 中的基本配置
   * 3307 端口映射到数据库 3306，要同时启动多个容器需要修改端口