USE `mysql`;

DROP SCHEMA IF EXISTS `mysqltest`;
CREATE SCHEMA `mysqltest`;

USE `mysqltest`;

CREATE TABLE `testtable` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `whatever` varchar(1024) NULL COMMENT 'Whatever',
  PRIMARY KEY (id)
) ENGINE InnoDB COMMENT '测试表';