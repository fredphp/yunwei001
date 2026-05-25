-- ============================================================
-- 多语言数据库内容翻译系统 - 数据库迁移脚本
-- 创建 bc_translate 翻译表，并插入初始翻译数据
-- 执行方式: 在 MySQL 中 source 此文件，或通过管理后台执行
-- ============================================================

-- 创建翻译表
CREATE TABLE IF NOT EXISTS `bc_translate` (
	`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	`source_table` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '源表名（不含前缀），如 game, settings',
	`source_id` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '源记录ID或键名，如 1, webname',
	`field_name` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '字段名，如 name, value',
	`lang` VARCHAR(10) NOT NULL DEFAULT '' COMMENT '语言代码，如 en-us, my-mm',
	`value` TEXT COMMENT '翻译内容',
	PRIMARY KEY (`id`),
	UNIQUE KEY `idx_translate_unique` (`source_table`, `source_id`, `field_name`, `lang`),
	KEY `idx_translate_lookup` (`source_table`, `lang`),
	KEY `idx_translate_source` (`source_table`, `source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据库内容多语言翻译表';

-- ============================================================
-- 游戏名称翻译数据
-- ============================================================

INSERT INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
-- id=1: 重庆时时彩(番摊)
('game', '1', 'name', 'en-us', 'Chongqing Time Lottery (Fantan)'),
('game', '1', 'name', 'my-mm', 'ချုံကျင်းအချိန်စာရင်း (ဖန်တန်)'),
-- id=2: 广东快乐十分(番摊)
('game', '2', 'name', 'en-us', 'Guangdong Happy 10 (Fantan)'),
('game', '2', 'name', 'my-mm', 'ကွမ်းတုံပျော်ရွှင်မှု၁၀ (ဖန်တန်)'),
-- id=3: 重庆幸运农场(番摊)
('game', '3', 'name', 'en-us', 'Chongqing Lucky Farm (Fantan)'),
('game', '3', 'name', 'my-mm', 'ချုံကျင်းကံကောင်းခြံ (ဖန်တန်)'),
-- id=4: PC蛋蛋(番摊)
('game', '4', 'name', 'en-us', 'PC Egg (Fantan)'),
('game', '4', 'name', 'my-mm', 'PC ဥ (ဖန်တန်)'),
-- id=5: 加拿大28(番摊)
('game', '5', 'name', 'en-us', 'Canada 28 (Fantan)'),
('game', '5', 'name', 'my-mm', 'ကနေဒါ၂၈ (ဖန်တန်)'),
-- id=6: 北京赛车(PK10)
('game', '6', 'name', 'en-us', 'Beijing Racing (PK10)'),
('game', '6', 'name', 'my-mm', 'ပေကျင်းကားပြိုင် (PK10)'),
-- id=7: 重庆时时彩
('game', '7', 'name', 'en-us', 'Chongqing Time Lottery'),
('game', '7', 'name', 'my-mm', 'ချုံကျင်းအချိန်စာရင်း'),
-- id=8: 广东快乐十分
('game', '8', 'name', 'en-us', 'Guangdong Happy 10'),
('game', '8', 'name', 'my-mm', 'ကွမ်းတုံပျော်ရွှင်မှု၁၀'),
-- id=9: PC蛋蛋 13/14玩法
('game', '9', 'name', 'en-us', 'PC Egg 13/14'),
('game', '9', 'name', 'my-mm', 'PC ဥ ၁၃/၁၄'),
-- id=10: 加拿大28 13/14玩法
('game', '10', 'name', 'en-us', 'Canada 28 13/14'),
('game', '10', 'name', 'my-mm', 'ကနေဒါ၂၈ ၁၃/၁၄'),
-- id=11: 北京赛车(牌九)
('game', '11', 'name', 'en-us', 'Beijing Racing (Pai Gow)'),
('game', '11', 'name', 'my-mm', 'ပေကျင်းကားပြိုင် (ပိုင်ဂေါ)'),
-- id=12: 重庆六博
('game', '12', 'name', 'en-us', 'Chongqing Six Bet'),
('game', '12', 'name', 'my-mm', 'ချုံကျင်းခြောက်ချိန်း'),
-- id=13: 极速28(番摊)
('game', '13', 'name', 'en-us', 'Speed 28 (Fantan)'),
('game', '13', 'name', 'my-mm', 'အမြန်၂၈ (ဖန်တန်)'),
-- id=14: 极速时时彩(番摊)
('game', '14', 'name', 'en-us', 'Speed Time Lottery (Fantan)'),
('game', '14', 'name', 'my-mm', 'အမြန်အချိန်စာရင်း (ဖန်တန်)');

-- ============================================================
-- 系统设置翻译数据
-- source_id 使用设置项的 key 名称（如 webname, ann 等）
-- field_name 统一使用 'value'
-- ============================================================

-- 网站名称 (webname)
INSERT INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'webname', 'value', 'en-us', 'Ant Lottery'),
('settings', 'webname', 'value', 'my-mm', 'ပု radicallyထိုးစာရင်း');

-- 网站公告 (ann)
INSERT INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'ann', 'value', 'en-us', 'Welcome to Ant Lottery! Thank you for your contribution to public welfare!'),
('settings', 'ann', 'value', 'my-mm', 'ပု radicallyထိုးစာရင်းသို့ကြိုဆိုပါသည်၊ အများပိုင်ရာထိုးစာရင်းအတွက်ကျေးဇူးတင်ပါသည်!');

-- 版权信息 (copyright)
INSERT INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'copyright', 'value', 'en-us', 'Copyright 2019 Ant Lottery All Rights Reserved.'),
('settings', 'copyright', 'value', 'my-mm', 'မူပိုင်ခွင့် ၂၀၁၉ ပု radicallyထိုးစာရင်း လုပ်ပိုင်ခွင့်အားလုံးထိန်းသိမ်းသည်။');

-- 网站描述 (description)
INSERT INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'description', 'value', 'en-us', 'Ant Lottery is the largest proxy betting platform, dedicated to making it easier for players to get information and find what they need.'),
('settings', 'description', 'value', 'my-mm', 'ပု radicallyထိုးစာရင်းသည်အကြီးဆုံးကိုယ်စားလှယ်ထိုးစာရင်းပလက်ဖောင်းဖြစ်ပြီး ကစားသမားများအတွက်သတင်းအချက်အလက်ရယူရန်လွယ်ကူစေရန်ဆောင်ရွက်သည်။');
