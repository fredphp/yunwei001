/*
Navicat MySQL Data Transfer

Source Server         : localhost_3306
Source Server Version : 50553
Source Host           : localhost:3306
Source Database       : fantan_db

Target Server Type    : MYSQL
Target Server Version : 50553
File Encoding         : 65001

Date: 2019-09-28 11:49:58
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `bc_account`
-- ----------------------------
DROP TABLE IF EXISTS `bc_account`;
CREATE TABLE `bc_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` int(11) NOT NULL COMMENT 'UID',
  `money` decimal(10,2) NOT NULL COMMENT '金额',
  `countmoney` decimal(10,2) NOT NULL COMMENT '变动后的金额',
  `type` tinyint(1) NOT NULL COMMENT '类型0充值1提现2投注3盈利4退单',
  `addtime` int(11) NOT NULL COMMENT '时间',
  `comment` varchar(200) NOT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_account
-- ----------------------------

-- ----------------------------
-- Table structure for `bc_admin`
-- ----------------------------
DROP TABLE IF EXISTS `bc_admin`;
CREATE TABLE `bc_admin` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `username` char(20) NOT NULL,
  `mobile` varchar(50) NOT NULL,
  `password` char(32) NOT NULL,
  `encrypt` char(6) DEFAULT NULL,
  `lastlogin` int(10) DEFAULT NULL,
  `ip` char(15) DEFAULT NULL,
  `issuper` tinyint(1) NOT NULL COMMENT '管理员类型权限',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_admin
-- ----------------------------
INSERT INTO `bc_admin` VALUES ('1', 'admin', '', '076e36504bcb642dbad47ca949c9f250', 'b9cf16', '1569642543', '192.168.240.1', '1');

-- ----------------------------
-- Table structure for `bc_cash`
-- ----------------------------
DROP TABLE IF EXISTS `bc_cash`;
CREATE TABLE `bc_cash` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` int(11) NOT NULL COMMENT 'UID',
  `agent` int(11) NOT NULL COMMENT '上级代理人UID',
  `agents` int(11) NOT NULL DEFAULT '0' COMMENT '总代理人UID',
  `money` decimal(10,2) NOT NULL COMMENT '金额',
  `service` decimal(10,2) NOT NULL COMMENT '服务费',
  `from` varchar(200) NOT NULL COMMENT '提现账号信息',
  `state` tinyint(1) NOT NULL COMMENT '状态0等待处理1正在处理2提现完成3提现失败',
  `addtime` int(11) NOT NULL COMMENT '申请时间',
  `endtime` int(11) NOT NULL COMMENT '完成时间',
  `comment` varchar(200) NOT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_cash
-- ----------------------------

-- ----------------------------
-- Table structure for `bc_game`
-- ----------------------------
DROP TABLE IF EXISTS `bc_game`;
CREATE TABLE `bc_game` (
  `id` mediumint(5) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(50) NOT NULL COMMENT '游戏名称',
  `fptime` mediumint(5) NOT NULL COMMENT '提前封盘秒',
  `data` text NOT NULL COMMENT '游戏配置数据',
  `template` varchar(50) NOT NULL COMMENT '模板名称',
  `state` tinyint(1) NOT NULL COMMENT '1启用',
  `sort` mediumint(5) NOT NULL COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `sort` (`sort`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_game
-- ----------------------------
INSERT INTO `bc_game` VALUES ('1', '重庆时时彩(番摊)', '200', 'a:1:{i:0;s:246:\"1L2@2.90\r\n2L3@2.90\r\n3L4@2.90\r\n4L1@2.90\r\n1L4@2.90\r\n2L1@2.90\r\n3L2@2.90\r\n4L3@2.90\r\n1L3@2.90\r\n2L4@2.90\r\n3L1@2.90\r\n4L2@2.90\r\n12J@1.95\r\n23J@1.95\r\n34J@1.95\r\n41J@1.95\r\nZ1@1.95\r\nZ2@1.95\r\nZ3@1.95\r\nZ4@1.95\r\nF1@3.85\r\nF2@3.85\r\nF3@3.85\r\nF4@3.85\r\nD@1.95\r\nS@1.95\";}', 'fantan', '1', '1');
INSERT INTO `bc_game` VALUES ('2', '广东快乐十分(番摊)', '200', 'a:1:{i:0;s:246:\"1L2@2.90\r\n2L3@2.90\r\n3L4@2.90\r\n4L1@2.90\r\n1L4@2.90\r\n2L1@2.90\r\n3L2@2.90\r\n4L3@2.90\r\n1L3@2.90\r\n2L4@2.90\r\n3L1@2.90\r\n4L2@2.90\r\n12J@1.95\r\n23J@1.95\r\n34J@1.95\r\n41J@1.95\r\nZ1@1.95\r\nZ2@1.95\r\nZ3@1.95\r\nZ4@1.95\r\nF1@3.85\r\nF2@3.85\r\nF3@3.85\r\nF4@3.85\r\nD@1.95\r\nS@1.95\";}', 'fantan', '1', '2');
INSERT INTO `bc_game` VALUES ('3', '重庆幸运农场(番摊)', '260', 'a:1:{i:0;s:246:\"1L2@2.90\r\n2L3@2.90\r\n3L4@2.90\r\n4L1@2.90\r\n1L4@2.90\r\n2L1@2.90\r\n3L2@2.90\r\n4L3@2.90\r\n1L3@2.90\r\n2L4@2.90\r\n3L1@2.90\r\n4L2@2.90\r\n12J@1.95\r\n23J@1.95\r\n34J@1.95\r\n41J@1.95\r\nZ1@1.95\r\nZ2@1.95\r\nZ3@1.95\r\nZ4@1.95\r\nF1@3.85\r\nF2@3.85\r\nF3@3.85\r\nF4@3.85\r\nD@1.95\r\nS@1.95\";}', 'fantan', '1', '3');
INSERT INTO `bc_game` VALUES ('4', 'PC蛋蛋(番摊)', '40', 'a:1:{i:0;s:221:\"1L2@2.90\n2L3@2.90\n3L4@2.90\n4L1@2.90\n1L4@2.90\n2L1@2.90\n3L2@2.90\n4L3@2.90\n1L3@2.90\n2L4@2.90\n3L1@2.90\n4L2@2.90\n12J@1.95\n23J@1.95\n34J@1.95\n41J@1.95\nZ1@1.95\nZ2@1.95\nZ3@1.95\nZ4@1.95\nF1@3.85\nF2@3.85\nF3@3.85\nF4@3.85\nD@1.95\nS@1.95\";}', 'fantan', '1', '4');
INSERT INTO `bc_game` VALUES ('5', '加拿大28(番摊)', '40', 'a:1:{i:0;s:221:\"1L2@2.90\n2L3@2.90\n3L4@2.90\n4L1@2.90\n1L4@2.90\n2L1@2.90\n3L2@2.90\n4L3@2.90\n1L3@2.90\n2L4@2.90\n3L1@2.90\n4L2@2.90\n12J@1.95\n23J@1.95\n34J@1.95\n41J@1.95\nZ1@1.95\nZ2@1.95\nZ3@1.95\nZ4@1.95\nF1@3.85\nF2@3.85\nF3@3.85\nF4@3.85\nD@1.95\nS@1.95\";}', 'fantan', '1', '5');
INSERT INTO `bc_game` VALUES ('6', '北京赛车(PK10)', '200', 'a:1:{i:0;s:1586:\"GYDA@2.14\r\nGYX@1.78\r\nGYD@1.78\r\nGYS@2.14\r\nGY3@42\r\nGY4@42\r\nGY5@21\r\nGY6@21\r\nGY7@13.8\r\nGY8@13.8\r\nGY9@10.3\r\nGY10@10.3\r\nGY11@8.6\r\nGY12@10.3\r\nGY13@10.3\r\nGY14@13.8\r\nGY15@13.8\r\nGY16@21\r\nGY17@21\r\nGY18@42\r\nGY19@42\r\n1DA@1.98\r\n1X@1.98\r\n1D@1.98\r\n1S@1.98\r\n1L@1.98\r\n1H@1.98\r\n2DA@1.98\r\n2X@1.98\r\n2D@1.98\r\n2S@1.98\r\n2L@1.98\r\n2H@1.98\r\n3DA@1.98\r\n3X@1.98\r\n3D@1.98\r\n3S@1.98\r\n3L@1.98\r\n3H@1.98\r\n4DA@1.98\r\n4X@1.98\r\n4D@1.98\r\n4S@1.98\r\n4L@1.98\r\n4H@1.98\r\n5DA@1.98\r\n5X@1.98\r\n5D@1.98\r\n5S@1.98\r\n5L@1.98\r\n5H@1.98\r\n6DA@1.98\r\n6X@1.98\r\n6D@1.98\r\n6S@1.98\r\n7DA@1.98\r\n7X@1.98\r\n7D@1.98\r\n7S@1.98\r\n8DA@1.98\r\n8X@1.98\r\n8D@1.98\r\n8S@1.98\r\n9DA@1.98\r\n9X@1.98\r\n9D@1.98\r\n9S@1.98\r\n10DA@1.98\r\n10X@1.98\r\n10D@1.98\r\n10S@1.98\r\n1A1@9.8\r\n1A2@9.8\r\n1A3@9.8\r\n1A4@9.8\r\n1A5@9.8\r\n1A6@9.8\r\n1A7@9.8\r\n1A8@9.8\r\n1A9@9.8\r\n1A10@9.8\r\n2A1@9.8\r\n2A2@9.8\r\n2A3@9.8\r\n2A4@9.8\r\n2A5@9.8\r\n2A6@9.8\r\n2A7@9.8\r\n2A8@9.8\r\n2A9@9.8\r\n2A10@9.8\r\n3A1@9.8\r\n3A2@9.8\r\n3A3@9.8\r\n3A4@9.8\r\n3A5@9.8\r\n3A6@9.8\r\n3A7@9.8\r\n3A8@9.8\r\n3A9@9.8\r\n3A10@9.8\r\n4A1@9.8\r\n4A2@9.8\r\n4A3@9.8\r\n4A4@9.8\r\n4A5@9.8\r\n4A6@9.8\r\n4A7@9.8\r\n4A8@9.8\r\n4A9@9.8\r\n4A10@9.8\r\n5A1@9.8\r\n5A2@9.8\r\n5A3@9.8\r\n5A4@9.8\r\n5A5@9.8\r\n5A6@9.8\r\n5A7@9.8\r\n5A8@9.8\r\n5A9@9.8\r\n5A10@9.8\r\n6A1@9.8\r\n6A2@9.8\r\n6A3@9.8\r\n6A4@9.8\r\n6A5@9.8\r\n6A6@9.8\r\n6A7@9.8\r\n6A8@9.8\r\n6A9@9.8\r\n6A10@9.8\r\n7A1@9.8\r\n7A2@9.8\r\n7A3@9.8\r\n7A4@9.8\r\n7A5@9.8\r\n7A6@9.8\r\n7A7@9.8\r\n7A8@9.8\r\n7A9@9.8\r\n7A10@9.8\r\n8A1@9.8\r\n8A2@9.8\r\n8A3@9.8\r\n8A4@9.8\r\n8A5@9.8\r\n8A6@9.8\r\n8A7@9.8\r\n8A8@9.8\r\n8A9@9.8\r\n8A10@9.8\r\n9A1@9.8\r\n9A2@9.8\r\n9A3@9.8\r\n9A4@9.8\r\n9A5@9.8\r\n9A6@9.8\r\n9A7@9.8\r\n9A8@9.8\r\n9A9@9.8\r\n9A10@9.8\r\n10A1@9.8\r\n10A2@9.8\r\n10A3@9.8\r\n10A4@9.8\r\n10A5@9.8\r\n10A6@9.8\r\n10A7@9.8\r\n10A8@9.8\r\n10A9@9.8\r\n10A10@9.8\";}', 'pk10', '1', '1');
INSERT INTO `bc_game` VALUES ('7', '重庆时时彩', '200', 'a:1:{i:0;s:846:\"ZHDA@1.98\r\nZHX@1.98\r\nZHD@1.98\r\nZHS@1.98\r\nZHL@1.98\r\nZHH@1.98\r\nZHHE@8.88\r\n1DA@1.98\r\n1X@1.98\r\n1D@1.98\r\n1S@1.98\r\n2DA@1.98\r\n2X@1.98\r\n2D@1.98\r\n2S@1.98\r\n3DA@1.98\r\n3X@1.98\r\n3D@1.98\r\n3S@1.98\r\n4DA@1.98\r\n4X@1.98\r\n4D@1.98\r\n4S@1.98\r\n5DA@1.98\r\n5X@1.98\r\n5D@1.98\r\n5S@1.98\r\n1A0@9.9\r\n1A1@9.9\r\n1A2@9.9\r\n1A3@9.9\r\n1A4@9.9\r\n1A5@9.9\r\n1A6@9.9\r\n1A7@9.9\r\n1A8@9.9\r\n1A9@9.9\r\n2A0@9.9\r\n2A1@9.9\r\n2A2@9.9\r\n2A3@9.9\r\n2A4@9.9\r\n2A5@9.9\r\n2A6@9.9\r\n2A7@9.9\r\n2A8@9.9\r\n2A9@9.9\r\n3A0@9.9\r\n3A1@9.9\r\n3A2@9.9\r\n3A3@9.9\r\n3A4@9.9\r\n3A5@9.9\r\n3A6@9.9\r\n3A7@9.9\r\n3A8@9.9\r\n3A9@9.9\r\n4A0@9.9\r\n4A1@9.9\r\n4A2@9.9\r\n4A3@9.9\r\n4A4@9.9\r\n4A5@9.9\r\n4A6@9.9\r\n4A7@9.9\r\n4A8@9.9\r\n4A9@9.9\r\n5A0@9.9\r\n5A1@9.9\r\n5A2@9.9\r\n5A3@9.9\r\n5A4@9.9\r\n5A5@9.9\r\n5A6@9.9\r\n5A7@9.9\r\n5A8@9.9\r\n5A9@9.9\r\nQBZ@75\r\nQSZ@14.58\r\nQDZ@3.38\r\nQBS@1.9\r\nQZL@2.7\r\nZBZ@75\r\nZSZ@14.58\r\nZDZ@3.38\r\nZBS@1.9\r\nZZL@2.7\r\nHBZ@75\r\nHSZ@14.58\r\nHDZ@3.38\r\nHBS@1.9\r\nHZL@2.7\";}', 'cqssc', '1', '2');
INSERT INTO `bc_game` VALUES (8,'广东快乐十分',30,'a:1:{i:0;s:1828:\"ZHDA@1.98\nZHX@1.98\nZHD@1.98\nZHS@1.98\n1DA@1.98\n1X@1.98\n1D@1.98\n1S@1.98\n2DA@1.98\n2X@1.98\n2D@1.98\n2S@1.98\n3DA@1.98\n3X@1.98\n3D@1.98\n3S@1.98\n4DA@1.98\n4X@1.98\n4D@1.98\n4S@1.98\n5DA@1.98\n5X@1.98\n5D@1.98\n5S@1.98\n6DA@1.98\n6X@1.98\n6D@1.98\n6S@1.98\n7DA@1.98\n7X@1.98\n7D@1.98\n7S@1.98\n8DA@1.98\n8X@1.98\n8D@1.98\n8S@1.98\n1A1@19.6\n1A2@19.6\n1A3@19.6\n1A4@19.6\n1A5@19.6\n1A6@19.6\n1A7@19.6\n1A8@19.6\n1A9@19.6\n1A10@19.6\n1A11@19.6\n1A12@19.6\n1A13@19.6\n1A14@19.6\n1A15@19.6\n1A16@19.6\n1A17@19.6\n1A18@19.6\n1A19@19.6\n1A20@19.6\n2A1@19.6\n2A2@19.6\n2A3@19.6\n2A4@19.6\n2A5@19.6\n2A6@19.6\n2A7@19.6\n2A8@19.6\n2A9@19.6\n2A10@19.6\n2A11@19.6\n2A12@19.6\n2A13@19.6\n2A14@19.6\n2A15@19.6\n2A16@19.6\n2A17@19.6\n2A18@19.6\n2A19@19.6\n2A20@19.6\n3A1@19.6\n3A2@19.6\n3A3@19.6\n3A4@19.6\n3A5@19.6\n3A6@19.6\n3A7@19.6\n3A8@19.6\n3A9@19.6\n3A10@19.6\n3A11@19.6\n3A12@19.6\n3A13@19.6\n3A14@19.6\n3A15@19.6\n3A16@19.6\n3A17@19.6\n3A18@19.6\n3A19@19.6\n3A20@19.6\n4A1@19.6\n4A2@19.6\n4A3@19.6\n4A4@19.6\n4A5@19.6\n4A6@19.6\n4A7@19.6\n4A8@19.6\n4A9@19.6\n4A10@19.6\n4A11@19.6\n4A12@19.6\n4A13@19.6\n4A14@19.6\n4A15@19.6\n4A16@19.6\n4A17@19.6\n4A18@19.6\n4A19@19.6\n4A20@19.6\n5A1@19.6\n5A2@19.6\n5A3@19.6\n5A4@19.6\n5A5@19.6\n5A6@19.6\n5A7@19.6\n5A8@19.6\n5A9@19.6\n5A10@19.6\n5A11@19.6\n5A12@19.6\n5A13@19.6\n5A14@19.6\n5A15@19.6\n5A16@19.6\n5A17@19.6\n5A18@19.6\n5A19@19.6\n5A20@19.6\n6A1@19.6\n6A2@19.6\n6A3@19.6\n6A4@19.6\n6A5@19.6\n6A6@19.6\n6A7@19.6\n6A8@19.6\n6A9@19.6\n6A10@19.6\n6A11@19.6\n6A12@19.6\n6A13@19.6\n6A14@19.6\n6A15@19.6\n6A16@19.6\n6A17@19.6\n6A18@19.6\n6A19@19.6\n6A20@19.6\n7A1@19.6\n7A2@19.6\n7A3@19.6\n7A4@19.6\n7A5@19.6\n7A6@19.6\n7A7@19.6\n7A8@19.6\n7A9@19.6\n7A10@19.6\n7A11@19.6\n7A12@19.6\n7A13@19.6\n7A14@19.6\n7A15@19.6\n7A16@19.6\n7A17@19.6\n7A18@19.6\n7A19@19.6\n7A20@19.6\n8A1@19.6\n8A2@19.6\n8A3@19.6\n8A4@19.6\n8A5@19.6\n8A6@19.6\n8A7@19.6\n8A8@19.6\n8A9@19.6\n8A10@19.6\n8A11@19.6\n8A12@19.6\n8A13@19.6\n8A14@19.6\n8A15@19.6\n8A16@19.6\n8A17@19.6\n8A18@19.6\n8A19@19.6\n8A20@19.6\";}','gdkl',1,3);;
INSERT INTO `bc_game` VALUES ('9', 'PC蛋蛋 13/14玩法', '60', 'a:1:{i:0;s:327:\"DA@1.97\r\nX@1.97\r\nD@1.97\r\nS@1.97\r\nDD@4.2\r\nDS@4.6\r\nXD@4.6\r\nXS@4.2\r\nJD@13\r\nJX@13\r\nBZ@60\r\nHB@2.9\r\nLVB@2.9\r\nLB@2.9\r\nS0@500\r\nS1@100\r\nS2@50\r\nS3@40\r\nS4@30\r\nS5@20\r\nS6@17\r\nS7@16\r\nS8@15\r\nS9@15\r\nS10@14\r\nS11@14\r\nS12@12\r\nS13@12\r\nS14@12\r\nS15@12\r\nS16@14\r\nS17@14\r\nS18@15\r\nS19@15\r\nS20@16\r\nS21@17\r\nS22@20\r\nS23@30\r\nS24@40\r\nS25@50\r\nS26@100\r\nS27@500\";}', 'pc28', '1', '4');
INSERT INTO `bc_game` VALUES ('10', '加拿大28 13/14玩法', '60', 'a:1:{i:0;s:327:\"DA@1.97\r\nX@1.97\r\nD@1.97\r\nS@1.97\r\nDD@4.2\r\nDS@5.0\r\nXD@5.0\r\nXS@4.2\r\nJD@13\r\nJX@13\r\nBZ@60\r\nHB@2.9\r\nLVB@2.9\r\nLB@2.9\r\nS0@500\r\nS1@100\r\nS2@50\r\nS3@40\r\nS4@30\r\nS5@20\r\nS6@17\r\nS7@16\r\nS8@15\r\nS9@15\r\nS10@14\r\nS11@14\r\nS12@12\r\nS13@12\r\nS14@12\r\nS15@12\r\nS16@14\r\nS17@14\r\nS18@15\r\nS19@15\r\nS20@16\r\nS21@17\r\nS22@20\r\nS23@30\r\nS24@40\r\nS25@50\r\nS26@100\r\nS27@500\";}', 'pc28', '1', '5');
INSERT INTO `bc_game` VALUES ('11', '北京赛车(牌九)', '30', 'a:1:{i:0;s:0:\"\";}', 'pkpj', '1', '6');
INSERT INTO `bc_game` VALUES ('12', '重庆六博', '200', 'a:1:{i:0;s:1524:\"S1@46@5-1000\nS2@46@5-1000\nS3@46@5-1000\nS4@46@5-1000\nS5@46@5-1000\nS6@46@5-1000\nS7@46@5-1000\nS8@46@5-1000\nS9@46@5-1000\nS10@46@5-1000\nS11@46@5-1000\nS12@46@5-1000\nS13@46@5-1000\nS14@46@5-1000\nS15@46@5-1000\nS16@46@5-1000\nS17@46@5-1000\nS18@46@5-1000\nS19@46@5-1000\nS20@46@5-1000\nS21@46@5-1000\nS22@46@5-1000\nS23@46@5-1000\nS24@46@5-1000\nS25@46@5-1000\nS26@46@5-1000\nS27@46@5-1000\nS28@46@5-1000\nS29@46@5-1000\nS30@46@5-1000\nS31@46@5-1000\nS32@46@5-1000\nS33@46@5-1000\nS34@46@5-1000\nS35@46@5-1000\nS36@46@5-1000\nS37@46@5-1000\nS38@46@5-1000\nS39@46@5-1000\nS40@46@5-1000\nS41@46@5-1000\nS42@46@5-1000\nS43@46@5-1000\nS44@46@5-1000\nS45@46@5-1000\nS46@46@5-1000\nS47@46@5-1000\nS48@46@5-1000\nS49@46@5-1000\nNIU@11@10-5000\nJI@11@10-5000\nYANG@11@10-5000\nZHU@11@10-5000\nGOU@9@10-5000\nMA@11@10-5000\nSHE@11@10-5000\nSHU@11@10-5000\nHU@11@10-5000\nTU@11@10-5000\nLONG@11@10-5000\nHOU@11@10-5000\nDA@1.9@10-20000\nX@1.9@10-20000\nD@1.9@10-20000\nS@1.9@10-20000\nDD@3.8@10-20000\nDS@3.8@10-20000\nXD@3.8@10-20000\nXS@3.8@10-20000\nJQ@1.9@10-20000\nYS@1.9@10-20000\nHSDA@1.9@10-10000\nHSX@1.9@10-10000\nHSD@1.9@10-10000\nHSS@1.9@10-10000\nHB@2.7@10-10000\nHDA@6@10-10000\nHX@4@10-10000\nHD@5@10-10000\nHS@5@10-10000\nLVB@2.8@10-10000\nLVDA@5@10-10000\nLVX@6@10-10000\nLVD@5@10-10000\nLVS@5@10-10000\nLB@2.8@10-10000\nLDA@5@10-10000\nLX@6@10-10000\nLD@5@10-10000\nLS@5@10-10000\nT0@4.6@10-20000\nT1@4.6@10-20000\nT2@4.6@10-20000\nT3@4.6@10-20000\nT4@4.6@10-20000\nW0@11@10-20000\nW1@9@10-20000\nW2@9@10-20000\nW3@9@10-20000\nW4@9@10-20000\nW5@9@10-20000\nW6@9@10-20000\nW7@9@10-20000\nW8@9@10-20000\nW9@9@10-20000\";}', 'liubo', '1', '7');
INSERT INTO `bc_game` VALUES ('13', '极速28(番摊)', '30', 'a:1:{i:0;s:221:\"1L2@2.90\n2L3@2.90\n3L4@2.90\n4L1@2.90\n1L4@2.90\n2L1@2.90\n3L2@2.90\n4L3@2.90\n1L3@2.90\n2L4@2.90\n3L1@2.90\n4L2@2.90\n12J@1.95\n23J@1.95\n34J@1.95\n41J@1.95\nZ1@1.95\nZ2@1.95\nZ3@1.95\nZ4@1.95\nF1@3.85\nF2@3.85\nF3@3.85\nF4@3.85\nD@1.95\nS@1.95\";}', 'fantan', '1', '6');
INSERT INTO `bc_game` VALUES ('14', '极速时时彩(番摊)', '30', 'a:1:{i:0;s:221:\"1L2@2.90\n2L3@2.90\n3L4@2.90\n4L1@2.90\n1L4@2.90\n2L1@2.90\n3L2@2.90\n4L3@2.90\n1L3@2.90\n2L4@2.90\n3L1@2.90\n4L2@2.90\n12J@1.95\n23J@1.95\n34J@1.95\n41J@1.95\nZ1@1.95\nZ2@1.95\nZ3@1.95\nZ4@1.95\nF1@3.85\nF2@3.85\nF3@3.85\nF4@3.85\nD@1.95\nS@1.95\";}', 'fantan', '1', '7');

-- ----------------------------
-- Table structure for `bc_haoma`
-- ----------------------------
DROP TABLE IF EXISTS `bc_haoma`;
CREATE TABLE `bc_haoma` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `gameid` mediumint(5) NOT NULL DEFAULT '0' COMMENT '游戏ID',
  `qishu` bigint(11) NOT NULL COMMENT '期数',
  `sendtime` int(11) NOT NULL DEFAULT '0' COMMENT '开奖时间',
  `haoma` varchar(50) NOT NULL DEFAULT '' COMMENT '开奖号码',
  `account` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否全部结算',
  PRIMARY KEY (`id`),
  KEY `haoma` (`haoma`),
  KEY `qishu` (`qishu`),
  KEY `gameid` (`gameid`)
) ENGINE=MyISAM AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_haoma
-- ----------------------------
INSERT INTO `bc_haoma` VALUES ('1', '1', '20190928022', '1569641400', '9,9,6,8,9', '1');
INSERT INTO `bc_haoma` VALUES ('2', '1', '20190928023', '1569642600', '', '0');
INSERT INTO `bc_haoma` VALUES ('3', '7', '20190928022', '1569641400', '9,9,6,8,9', '1');
INSERT INTO `bc_haoma` VALUES ('4', '7', '20190928023', '1569642600', '', '0');
INSERT INTO `bc_haoma` VALUES ('5', '3', '20190928023', '1569642105', '12,3,18,16,17,7,14,1', '1');
INSERT INTO `bc_haoma` VALUES ('6', '4', '976391', '1569642000', '7,4,2', '1');
INSERT INTO `bc_haoma` VALUES ('7', '12', '20190928022', '1569641400', '9,9,6,8,9', '1');
INSERT INTO `bc_haoma` VALUES ('8', '3', '20190928024', '1569642705', '', '0');
INSERT INTO `bc_haoma` VALUES ('9', '4', '976392', '1569642300', '6,1,2', '1');
INSERT INTO `bc_haoma` VALUES ('10', '12', '20190928023', '1569642600', '', '0');
INSERT INTO `bc_haoma` VALUES ('11', '9', '976391', '1569642000', '7,4,2', '1');
INSERT INTO `bc_haoma` VALUES ('12', '9', '976392', '1569642300', '6,1,2', '1');
INSERT INTO `bc_haoma` VALUES ('13', '13', '456124', '1569642150', '4,2,0', '1');
INSERT INTO `bc_haoma` VALUES ('14', '13', '456125', '1569642300', '1,6,4', '1');
INSERT INTO `bc_haoma` VALUES ('15', '14', '684488', '1569642210', '8,1,9,5,6', '1');
INSERT INTO `bc_haoma` VALUES ('16', '14', '684489', '1569642300', '6,3,1,5,7', '1');
INSERT INTO `bc_haoma` VALUES ('17', '2', '20190928008', '1569642085', '2,19,13,14,12,7,5,8', '1');
INSERT INTO `bc_haoma` VALUES ('18', '2', '20190928009', '1569643285', '', '0');
INSERT INTO `bc_haoma` VALUES ('19', '8', '20190928008', '1569642085', '2,19,13,14,12,7,5,8', '0');
INSERT INTO `bc_haoma` VALUES ('20', '8', '20190928009', '1569643285', '', '0');
INSERT INTO `bc_haoma` VALUES ('21', '5', '2479493', '1569642150', '0,1,2', '1');
INSERT INTO `bc_haoma` VALUES ('22', '5', '2479494', '1569642360', '3,9,7', '1');
INSERT INTO `bc_haoma` VALUES ('23', '10', '2479493', '1569642150', '0,1,2', '1');
INSERT INTO `bc_haoma` VALUES ('24', '10', '2479494', '1569642360', '3,9,7', '1');
INSERT INTO `bc_haoma` VALUES ('25', '6', '739474', '1569641440', '2,4,1,9,10,5,6,3,8,7', '1');
INSERT INTO `bc_haoma` VALUES ('26', '6', '739475', '1569642640', '', '0');
INSERT INTO `bc_haoma` VALUES ('27', '11', '739474', '1569641440', '2,4,1,9,10,5,6,3,8,7', '1');
INSERT INTO `bc_haoma` VALUES ('28', '11', '739475', '1569642640', '', '0');
INSERT INTO `bc_haoma` VALUES ('29', '13', '456126', '1569642450', '6,2,3', '1');
INSERT INTO `bc_haoma` VALUES ('30', '14', '684490', '1569642390', '1,0,4,7,2', '1');
INSERT INTO `bc_haoma` VALUES ('31', '4', '0', '0', '0', '1');
INSERT INTO `bc_haoma` VALUES ('32', '4', '1', '300', '', '0');
INSERT INTO `bc_haoma` VALUES ('33', '9', '0', '0', '0', '1');
INSERT INTO `bc_haoma` VALUES ('34', '9', '1', '300', '', '0');
INSERT INTO `bc_haoma` VALUES ('35', '5', '0', '0', '0', '1');
INSERT INTO `bc_haoma` VALUES ('36', '5', '1', '210', '', '0');
INSERT INTO `bc_haoma` VALUES ('37', '10', '0', '0', '0', '1');
INSERT INTO `bc_haoma` VALUES ('38', '10', '1', '210', '', '0');
INSERT INTO `bc_haoma` VALUES ('39', '14', '684491', '1569642480', '3,0,8,5,4', '1');
INSERT INTO `bc_haoma` VALUES ('40', '5', '2479495', '1569642570', '', '0');
INSERT INTO `bc_haoma` VALUES ('41', '10', '2479495', '1569642570', '', '0');
INSERT INTO `bc_haoma` VALUES ('42', '13', '456127', '1569642600', '', '0');
INSERT INTO `bc_haoma` VALUES ('43', '4', '976393', '1569642600', '', '0');
INSERT INTO `bc_haoma` VALUES ('44', '9', '976393', '1569642600', '', '0');
INSERT INTO `bc_haoma` VALUES ('45', '14', '684492', '1569642570', '7,5,9,2,1', '1');
INSERT INTO `bc_haoma` VALUES ('46', '14', '684493', '1569642660', '', '0');

-- ----------------------------
-- Table structure for `bc_order`
-- ----------------------------
DROP TABLE IF EXISTS `bc_order`;
CREATE TABLE `bc_order` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` int(11) NOT NULL COMMENT 'UID',
  `agent` int(11) NOT NULL DEFAULT '0' COMMENT '代理人UID',
  `agents` int(11) NOT NULL DEFAULT '0' COMMENT '总代理人UID',
  `orderid` varchar(32) NOT NULL COMMENT '订单号',
  `gameid` mediumint(5) NOT NULL COMMENT '游戏ID',
  `qishu` varchar(15) NOT NULL COMMENT '期数',
  `money` decimal(10,2) NOT NULL COMMENT '订单金额',
  `account` decimal(10,2) NOT NULL COMMENT '结算',
  `wanfa` varchar(30) NOT NULL COMMENT '玩法',
  `addtime` int(11) NOT NULL COMMENT '下单时间',
  `endtime` int(11) NOT NULL COMMENT '结算时间',
  `tui` tinyint(1) NOT NULL COMMENT '是否退单1退单',
  `ban` tinyint(1) NOT NULL COMMENT '完成结算',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_order
-- ----------------------------

-- ----------------------------
-- Table structure for `bc_pay`
-- ----------------------------
DROP TABLE IF EXISTS `bc_pay`;
CREATE TABLE `bc_pay` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` int(11) NOT NULL COMMENT 'UID',
  `agent` int(11) NOT NULL COMMENT '上级代理人UID',
  `agents` int(11) NOT NULL DEFAULT '0' COMMENT '总代理人UID',
  `payid` varchar(32) NOT NULL COMMENT '订单ID',
  `money` decimal(10,2) NOT NULL COMMENT '金额',
  `state` tinyint(1) NOT NULL COMMENT '状态0等待支付1在线支付2手工订单',
  `comment` varchar(200) NOT NULL COMMENT '备注',
  `addtime` int(11) NOT NULL COMMENT '时间',
  `paytime` int(11) NOT NULL COMMENT '支付时间',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_pay
-- ----------------------------

-- ----------------------------
-- Table structure for `bc_session`
-- ----------------------------
DROP TABLE IF EXISTS `bc_session`;
CREATE TABLE `bc_session` (
  `sessionid` char(32) NOT NULL,
  `userid` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `ip` char(15) NOT NULL,
  `lastvisit` int(10) unsigned NOT NULL DEFAULT '0',
  `roleid` tinyint(3) unsigned DEFAULT '0',
  `groupid` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `m` char(20) NOT NULL,
  `c` char(20) NOT NULL,
  `a` char(20) NOT NULL,
  `data` char(255) NOT NULL,
  PRIMARY KEY (`sessionid`),
  KEY `lastvisit` (`lastvisit`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_session
-- ----------------------------

-- ----------------------------
-- Table structure for `bc_settings`
-- ----------------------------
DROP TABLE IF EXISTS `bc_settings`;
CREATE TABLE `bc_settings` (
  `name` varchar(32) NOT NULL DEFAULT '',
  `data` text NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_settings
-- ----------------------------
INSERT INTO `bc_settings` VALUES ('aliewm', '0926_1569477686_2878.png');
INSERT INTO `bc_settings` VALUES ('ann', '欢迎光临蚂蚁彩票网，感谢您为公益彩票做出贡献！');
INSERT INTO `bc_settings` VALUES ('card', '');
INSERT INTO `bc_settings` VALUES ('cash', '0');
INSERT INTO `bc_settings` VALUES ('code', '');
INSERT INTO `bc_settings` VALUES ('copyright', 'Copyright ©2019 蚂蚁彩票 All Rights Reserved.');
INSERT INTO `bc_settings` VALUES ('description', '蚂蚁彩票网是最大的代购平台、致力于让彩民更便捷地获取信息，找到所求。蚂蚁彩票网超过千万的注册用户，在这里你可以瞬间找到你所需要的服务。');
INSERT INTO `bc_settings` VALUES ('email', '123456@qq.com');
INSERT INTO `bc_settings` VALUES ('keywords', '');
INSERT INTO `bc_settings` VALUES ('lang', 'zh-cn');
INSERT INTO `bc_settings` VALUES ('maxcash', '50000');
INSERT INTO `bc_settings` VALUES ('money', '0');
INSERT INTO `bc_settings` VALUES ('pay', '1');
INSERT INTO `bc_settings` VALUES ('phone', '13800138000');
INSERT INTO `bc_settings` VALUES ('qq', '97887526');
INSERT INTO `bc_settings` VALUES ('remark', '');
INSERT INTO `bc_settings` VALUES ('send_money', '1-50000');
INSERT INTO `bc_settings` VALUES ('stamp', '￥');
INSERT INTO `bc_settings` VALUES ('stop', '0');
INSERT INTO `bc_settings` VALUES ('userfilter', '管理员,客服,system,系统,计划员, ,所有人');
INSERT INTO `bc_settings` VALUES ('username_type', 's2-20');
INSERT INTO `bc_settings` VALUES ('webname', '蚂蚁彩票');
INSERT INTO `bc_settings` VALUES ('weburl', 'http://www.myfaka.com/');
INSERT INTO `bc_settings` VALUES ('wxewm', '0926_1569477686_7117.png');
INSERT INTO `bc_settings` VALUES ('pop800', '465109');

-- ----------------------------
-- Table structure for `bc_user`
-- ----------------------------
DROP TABLE IF EXISTS `bc_user`;
CREATE TABLE `bc_user` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `aid` tinyint(3) NOT NULL DEFAULT '0' COMMENT '代理类别0无1一级2二级',
  `agent` int(11) NOT NULL COMMENT '上级代理人UID',
  `agents` int(11) NOT NULL DEFAULT '0' COMMENT '总代理人UID',
  `credit` int(11) NOT NULL COMMENT '积分',
  `pic` varchar(200) NOT NULL COMMENT '头像文件名',
  `name` varchar(20) NOT NULL COMMENT '真实姓名',
  `bank` varchar(50) NOT NULL COMMENT '银行名称',
  `card` varchar(30) NOT NULL COMMENT '银行账号',
  `weixin` varchar(50) NOT NULL COMMENT '微信号',
  `alipay` varchar(50) NOT NULL DEFAULT '' COMMENT '支付宝',
  `email` varchar(50) NOT NULL COMMENT 'Email',
  `qq` varchar(20) NOT NULL DEFAULT '' COMMENT 'QQ',
  `mobile` varchar(20) NOT NULL COMMENT '手机号',
  `send_money` varchar(50) NOT NULL COMMENT '投注金额限制',
  `agentconfig` text NOT NULL COMMENT '代理配置',
  `money` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '账户金额',
  `username` varchar(20) NOT NULL COMMENT '用户名',
  `nickname` varchar(20) NOT NULL COMMENT '昵称',
  `password` char(32) NOT NULL COMMENT '密码',
  `encrypt` char(6) NOT NULL COMMENT '密码附加',
  `logintime` int(11) NOT NULL DEFAULT '0' COMMENT '最后登录时间',
  `loginip` char(15) NOT NULL COMMENT '登录iP',
  `regtime` int(11) NOT NULL DEFAULT '0' COMMENT '注册时间',
  `lock` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否锁定1锁',
  PRIMARY KEY (`uid`),
  KEY `regtime` (`regtime`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of bc_user
-- ----------------------------
INSERT INTO `bc_user` VALUES ('1', '0', '0', '0', '0', '8', '测试', '', '', '', '', '123456@qq.com', '97887526', '13800138000', '', '', '1000.00', 'qq1234', '测试', '076e36504bcb642dbad47ca949c9f250', 'b9cf16', '1569642416', '192.168.240.1', '1553762372', '0');
INSERT INTO `bc_user` VALUES ('2', '1', '0', '0', '0', '', '代理', '', '', '', '', '', '', '', '', '', '0.00', 'daili', '代理', '98f577722c938ade87bb565425a605fe', '8ac8ab', '1569641838', '127.0.0.1', '1569475085', '0');
INSERT INTO `bc_user` VALUES ('3', '0', '0', '0', '0', '', '小七', '', '', '', '', '', '', '', '', '', '0.00', 'xiao7', '', '748adabbc4e39cb5e3782f463045ec1f', '13efec', '1569476122', '192.168.240.1', '1569475987', '0');
