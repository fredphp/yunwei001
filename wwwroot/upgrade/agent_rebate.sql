-- ============================================================
-- 代理分成系统 - 数据库迁移脚本
-- 创建 bc_agent 代理配置表、bc_agent_rebate_log 分成记录表
-- 并在 bc_user 表新增 agent_id 字段关联代理配置
-- 执行方式: 在 MySQL 中 source 此文件，或通过管理后台执行
-- ============================================================

-- 1. 新建 bc_agent 代理配置表
CREATE TABLE IF NOT EXISTS `bc_agent` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '代理ID',
  `name` varchar(50) NOT NULL COMMENT '代理名称',
  `rebate` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '分成比例(%)，基于流水计算',
  `state` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态1启用0停用',
  `addtime` int(11) NOT NULL COMMENT '添加时间',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- 2. 新建 bc_agent_rebate_log 分成记录表
CREATE TABLE IF NOT EXISTS `bc_agent_rebate_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` int(11) NOT NULL COMMENT '下注用户UID',
  `agent_id` int(11) NOT NULL COMMENT '代理ID',
  `agent_uid` int(11) NOT NULL COMMENT '代理用户UID',
  `order_id` int(11) NOT NULL DEFAULT '0' COMMENT '注单ID',
  `order_money` decimal(10,2) NOT NULL COMMENT '下注金额(流水)',
  `rebate` decimal(5,2) NOT NULL COMMENT '分成比例(%)',
  `rebate_money` decimal(10,2) NOT NULL COMMENT '分成金额',
  `addtime` int(11) NOT NULL COMMENT '时间',
  PRIMARY KEY (`id`),
  KEY `agent_uid` (`agent_uid`),
  KEY `uid` (`uid`),
  KEY `addtime` (`addtime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- 3. 在 bc_user 表新增 agent_id 字段，关联 bc_agent 表
ALTER TABLE `bc_user` ADD COLUMN `agent_id` int(11) NOT NULL DEFAULT '0' COMMENT '代理配置ID(关联bc_agent表)' AFTER `agents`;
