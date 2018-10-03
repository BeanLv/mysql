FROM ubuntu:14.04

ENV MYSQL_VERSION 5.7

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