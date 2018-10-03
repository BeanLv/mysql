FROM ubuntu:14.04

ENV MYSQL_VERSION 5.7
ENV MYSQL_HOME /usr/local/mysql
ENV DOCKER_ENTRYPOINT /usr/local/bin/docker-entrypoint.sh

WORKDIR $MYSQL_HOME
COPY . $MYSQL_HOME/

#-----------------  Install MySQL  ---------------------------

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN export key="5072E1F5" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver pgp.mit.edu --recv-keys "$key" \
 && gpg --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg \
 && rm -r "$GNUPGHOME"

RUN echo "deb http://repo.mysql.com/apt/ubuntu trusty mysql-${MYSQL_VERSION}" > /etc/apt/sources.list.d/mysql.list

RUN export DEBIAN_FRONTEND="noninteractive" \
 && echo "mysql-community-server mysql-community-server/root-pass password " | debconf-set-selections \
 && echo "mysql-community-server mysql-community-server/re-root-pass password " | debconf-set-selections \
 && apt-get update && apt-get -y install mysql-server \
 && rm -rf /var/lib/apt/lists/*


#---------------------  Basic setup  -------------------------

RUN rm -rf /var/lib/mysql \
 && mkdir /var/lib/mysql \
 && chown -R mysql:mysql /var/lib/mysql \
 && chown -R mysql:mysql "${MYSQL_HOME}" \
 && echo "!includedir ${MYSQL_HOME}/mysql.conf.d" >> /etc/mysql/my.cnf

RUN mv docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh \
 && chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

CMD ["mysqld_safe", "--user", "mysql"]