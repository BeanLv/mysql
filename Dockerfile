FROM 5824600/mysql-community:5.7

ENV MYSQL_HOME /usr/local/mysql

WORKDIR $MYSQL_HOME
COPY . $MYSQL_HOME/

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