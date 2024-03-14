-- 创建数据库
CREATE DATABASE IF NOT EXISTS fsm_data DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 切换到新创建的数据库
USE fsm_data;

-- 创建1分钟采集一次数据的表
CREATE TABLE IF NOT EXISTS fsm_session_data_1min (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL COMMENT '主机名',
    host_ip VARCHAR(255) NOT NULL COMMENT '主机IP',
    current_session INT NOT NULL COMMENT '当前会话数',
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '插入时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    remark TEXT COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='1分钟采集一次的并发量数据';

-- 创建5分钟采集一次数据的表
CREATE TABLE IF NOT EXISTS fsm_session_data_5min (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL COMMENT '主机名',
    host_ip VARCHAR(255) NOT NULL COMMENT '主机IP',
    current_session INT NOT NULL COMMENT '当前会话数',
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '插入时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    remark TEXT COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='5分钟采集一次的并发量数据';

--增加两个字段，一个字段是省份，一个是机房名称
ALTER TABLE fsm_session_data_5min
ADD COLUMN province VARCHAR(255) COMMENT '省份',
ADD COLUMN data_center VARCHAR(255) COMMENT '机房名称';

ALTER TABLE fsm_session_data_1min
ADD COLUMN province VARCHAR(255) COMMENT '省份',
ADD COLUMN data_center VARCHAR(255) COMMENT '机房名称';

--建表语句以以下为准
-- 创建5分钟采集一次数据的表
CREATE TABLE IF NOT EXISTS fsm_session_data_5min (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL COMMENT '主机名',
    host_ip VARCHAR(255) NOT NULL COMMENT '主机IP',
    current_session INT NOT NULL COMMENT '当前会话数',
    province VARCHAR(255) COMMENT '省份',
    data_center VARCHAR(255) COMMENT '机房名称',
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '插入时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    remark TEXT COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='5分钟采集一次的并发量数据';

-- 创建1分钟采集一次数据的表
CREATE TABLE IF NOT EXISTS fsm_session_data_1min (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL COMMENT '主机名',
    host_ip VARCHAR(255) NOT NULL COMMENT '主机IP',
    current_session INT NOT NULL COMMENT '当前会话数',
    province VARCHAR(255) COMMENT '省份',
    data_center VARCHAR(255) COMMENT '机房名称',
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '插入时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    remark TEXT COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='1分钟采集一次的并发量数据';
