-- ============================================================
-- 多语言数据库内容翻译系统 - 完整翻译数据（中/英/缅甸）
-- 包含: 游戏名称 + 系统设置 所有可翻译内容
-- 执行方式: docker exec -i yunwei_mysql mysql -uroot -proot --default-character-set=utf8mb4 fantan_db < i18n_translate_full.sql
-- ============================================================

-- 创建翻译表（如已存在则跳过）
CREATE TABLE IF NOT EXISTS `bc_translate` (
        `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
        `source_table` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '源表名（不含前缀）',
        `source_id` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '源记录ID或键名',
        `field_name` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '字段名',
        `lang` VARCHAR(10) NOT NULL DEFAULT '' COMMENT '语言代码',
        `value` TEXT COMMENT '翻译内容',
        PRIMARY KEY (`id`),
        UNIQUE KEY `idx_translate_unique` (`source_table`, `source_id`, `field_name`, `lang`),
        KEY `idx_translate_lookup` (`source_table`, `lang`),
        KEY `idx_translate_source` (`source_table`, `source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据库内容多语言翻译表';

-- ============================================================
-- 清除旧翻译数据（如需重新导入）
-- ============================================================
-- DELETE FROM `bc_translate`;

-- ============================================================
-- 游戏名称翻译 (bc_game.name)
-- ============================================================
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
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
-- 系统设置翻译 (bc_settings)
-- source_id = 设置项name, field_name = 'value'
-- ============================================================

-- 网站名称 (webname)
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'webname', 'value', 'en-us', 'Ant Lottery'),
('settings', 'webname', 'value', 'my-mm', 'ပုရွက်ဆိတ်ထိုးစာရင်း');

-- 网站公告 (ann)
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'ann', 'value', 'en-us', 'Welcome to Ant Lottery! Thank you for your contribution to public welfare!'),
('settings', 'ann', 'value', 'my-mm', 'ပုရွက်ဆိတ်ထိုးစာရင်းသို့ကြိုဆိုပါသည်! အများပိုင်ရာထိုးစာရင်းအတွက်ကျေးဇူးတင်ပါသည်!');

-- 版权信息 (copyright)
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'copyright', 'value', 'en-us', 'Copyright ©2019 Ant Lottery All Rights Reserved.'),
('settings', 'copyright', 'value', 'my-mm', 'မူပိုင်ခွင့် ©၂၀၁၉ ပုရွက်ဆိတ်ထိုးစာရင်း လုပ်ပိုင်ခွင့်အားလုံးထိန်းသိမ်းသည်။');

-- 网站描述 (description)
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'description', 'value', 'en-us', 'Ant Lottery is the largest proxy betting platform, dedicated to making it easier for players to get information and find what they need.'),
('settings', 'description', 'value', 'my-mm', 'ပုရွက်ဆိတ်ထိုးစာရင်းသည်အကြီးဆုံးကိုယ်စားလှယ်ထိုးစာရင်းပလက်ဖောင်းဖြစ်ပြီး ကစားသမားများအတွက်သတင်းအချက်အလက်ရယူရန်လွယ်ကူစေရန်ဆောင်ရွက်သည်။');

-- 收款银行 (card)
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'card', 'value', 'en-us', ''),
('settings', 'card', 'value', 'my-mm', '');

-- 支付备注 (remark)
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'remark', 'value', 'en-us', ''),
('settings', 'remark', 'value', 'my-mm', '');

-- 网站关键字 (keywords)
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'keywords', 'value', 'en-us', 'Ant Lottery, Online Betting, Proxy Betting'),
('settings', 'keywords', 'value', 'my-mm', 'ပုရွက်ဆိတ်ထိုးစာရင်း, အွန်လိုင်းထိုးစာရင်း, ကိုယ်စားလှယ်ထိုးစာရင်း');

-- QQ客服 (qq) - 可翻译客服名称
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'qq', 'value', 'en-us', 'Customer Service'),
('settings', 'qq', 'value', 'my-mm', 'ဖောက်သည်ဝန်ဆောင်မှု');

-- 统计代码 (code) - 不需要翻译，但保持记录
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('settings', 'code', 'value', 'en-us', ''),
('settings', 'code', 'value', 'my-mm', '');

-- ============================================================
-- 账户备注翻译 (bc_account.comment)
-- 通用备注模板翻译
-- ============================================================
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('account_type', '0', 'name', 'en-us', 'Recharge'),
('account_type', '0', 'name', 'my-mm', 'ငွေသွင်း'),
('account_type', '1', 'name', 'en-us', 'Withdrawal'),
('account_type', '1', 'name', 'my-mm', 'ငွေထုတ်'),
('account_type', '2', 'name', 'en-us', 'Bet'),
('account_type', '2', 'name', 'my-mm', 'ထိုးစာရင်း'),
('account_type', '3', 'name', 'en-us', 'Win'),
('account_type', '3', 'name', 'my-mm', 'အနိုင်ရ'),
('account_type', '4', 'name', 'en-us', 'Refund'),
('account_type', '4', 'name', 'my-mm', 'ပြန်လည်ပေးအပ်');

-- ============================================================
-- 提现状态翻译
-- ============================================================
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('cash_state', '0', 'name', 'en-us', 'Pending'),
('cash_state', '0', 'name', 'my-mm', 'စောင့်ဆိုင်းဆဲ'),
('cash_state', '1', 'name', 'en-us', 'Processing'),
('cash_state', '1', 'name', 'my-mm', 'လုပ်ဆောင်နေဆဲ'),
('cash_state', '2', 'name', 'en-us', 'Completed'),
('cash_state', '2', 'name', 'my-mm', 'ပြီးမြောက်'),
('cash_state', '3', 'name', 'en-us', 'Failed'),
('cash_state', '3', 'name', 'my-mm', 'မအောင်မြင်');

-- ============================================================
-- 充值状态翻译
-- ============================================================
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('pay_state', '0', 'name', 'en-us', 'Unpaid'),
('pay_state', '0', 'name', 'my-mm', 'မပေးသေး'),
('pay_state', '1', 'name', 'en-us', 'Paid'),
('pay_state', '1', 'name', 'my-mm', 'ပေးပြီး');

-- ============================================================
-- 游戏状态翻译
-- ============================================================
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('game_state', '0', 'name', 'en-us', 'Stopped'),
('game_state', '0', 'name', 'my-mm', 'ရပ်တန့်'),
('game_state', '1', 'name', 'en-us', 'Active'),
('game_state', '1', 'name', 'my-mm', 'လုပ်ဆောင်နေ');

-- ============================================================
-- 用户角色翻译
-- ============================================================
REPLACE INTO `bc_translate` (`source_table`, `source_id`, `field_name`, `lang`, `value`) VALUES
('user_role', '0', 'name', 'en-us', 'Member'),
('user_role', '0', 'name', 'my-mm', 'အဖွဲ့ဝင်'),
('user_role', '1', 'name', 'en-us', 'Agent'),
('user_role', '1', 'name', 'my-mm', 'ကိုယ်စားလှယ်');
