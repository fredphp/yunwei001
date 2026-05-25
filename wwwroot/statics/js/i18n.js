/**
 * i18n.js - Frontend Internationalization System
 * Provides a global __() function for JavaScript-side translations.
 * Supports 3 languages: zh-cn (Chinese), en-us (English), my-mm (Myanmar)
 *
 * Usage:
 *   __('key')                    - Simple translation
 *   __('key', {min: 1, max: 100}) - Translation with parameter substitution
 *
 * Language is controlled by backend admin settings.
 * The PHP-generated I18N_LANG variable determines the language.
 */

// Language is set by PHP from backend admin config
var I18N_LANG = typeof I18N_LANG !== 'undefined' ? I18N_LANG : 'zh-cn';

// Normalize language code
var I18N_VALID_LANGS = ['zh-cn', 'en-us', 'my-mm'];
if (I18N_VALID_LANGS.indexOf(I18N_LANG) === -1) {
    I18N_LANG = 'zh-cn';
}

// Language packs for all 3 languages
var I18N_PACKS = {

    'zh-cn': {
        // === Period/Status Messages ===
        'period_betting':        '期正在投注中',
        'period_sealed':         '期已经封盘',
        'period_about_open':     '期即将开奖，现在封盘',
        'drawing':               '开奖中...',
        'already_sealed':        '已封盘',
        'betting':               '投注中',

        // === Lottery Terms ===
        'last_2_digits':         '取后2位',
        'fan':                   '番',
        'crown':                 '冠亚',
        'crown_big_small_odd_even': '冠亚大/小/单/双',
        'dragon_tiger':          '龙/虎',
        'sum':                   '总和',
        'sum_big_small_odd_even':'总和大/小/单/双',
        'special_code':          '特码',

        // === Ball Labels ===
        'ball_1':                '第一球',
        'ball_2':                '第二球',
        'ball_3':                '第三球',
        'ball_4':                '第四球',
        'ball_5':                '第五球',
        'ball_6':                '第六球',
        'ball_7':                '第七球',
        'ball_8':                '第八球',
        'ball_9':                '第九球',
        'ball_10':               '第十球',

        // === Big/Small/Odd/Even ===
        'big':                   '大',
        'small':                 '小',
        'odd':                   '单',
        'even':                  '双',
        'big_small_odd_even':    '大/小/单/双',
        'big_odd':               '大单',
        'big_even':              '大双',
        'small_odd':             '小单',
        'small_even':            '小双',
        'extreme_big':           '极大',
        'extreme_small':         '极小',

        // === Lottery Combination Terms ===
        'leopard':               '豹子',
        'straight':              '顺子',
        'pair':                  '对子',
        'half_straight':         '半顺',
        'mixed_six':             '杂六',

        // === Position Terms ===
        'first_three':           '前三',
        'middle_three':          '中三',
        'last_three':            '后三',

        // === Color Waves ===
        'red_wave':              '红波',
        'green_wave':            '绿波',
        'blue_wave':             '蓝波',
        'red_big':               '红大',
        'red_small':             '红小',
        'red_odd':               '红单',
        'red_even':              '红双',
        'blue_big':              '蓝大',
        'blue_small':            '蓝小',
        'blue_odd':              '蓝单',
        'blue_even':             '蓝双',
        'green_big':             '绿大',
        'green_small':           '绿小',
        'green_odd':             '绿单',
        'green_even':            '绿双',

        // === Animal/Zodiac Terms ===
        'poultry_beast':         '家禽/野兽',
        'poultry':               '家禽',
        'beast':                 '野兽',
        'zodiac_ox':             '牛',
        'zodiac_chicken':        '鸡',
        'zodiac_goat':           '羊',
        'zodiac_pig':            '猪',
        'zodiac_dog':            '狗',
        'zodiac_horse':          '马',
        'zodiac_snake':          '蛇',
        'zodiac_rat':            '鼠',
        'zodiac_tiger':          '虎',
        'zodiac_rabbit':         '兔',
        'zodiac_dragon':         '龙',
        'zodiac_monkey':         '猴',
        'zodiac_animals':        '牛/鸡/羊/猪/狗/马/蛇/鼠/虎/兔/龙/猴',

        // === Position/Head/Tail Terms ===
        'head_0':                '0头',
        'head_1':                '1头',
        'head_2':                '2头',
        'head_3':                '3头',
        'head_4':                '4头',
        'tail_0':                '0尾',
        'tail_1':                '1尾',
        'tail_2':                '2尾',
        'tail_3':                '3尾',
        'tail_4':                '4尾',
        'tail_5':                '5尾',
        'tail_6':                '6尾',
        'tail_7':                '7尾',
        'tail_8':                '8尾',
        'tail_9':                '9尾',

        // === PK10 Specific ===
        'crown_army':            '冠军',
        'runner_up':             '亚军',
        'third_place':           '第三名',
        'fourth_place':          '第四名',
        'fifth_place':           '第五名',
        'sixth_place':           '第六名',
        'seventh_place':         '第七名',
        'eighth_place':          '第八名',
        'ninth_place':           '第九名',
        'tenth_place':           '第十名',
        'corner_1_2':            '1-2角',
        'corner_2_3':            '2-3角',
        'corner_3_4':            '3-4角',
        'corner_4_1':            '4-1角',

        // === Combination Sum Terms ===
        'sum_big':               '合数大',
        'sum_small':             '合数小',
        'sum_odd':               '合数单',
        'sum_even':              '合数双',

        // === Dialog/Alert Messages ===
        'no_period_yet':         '尚未取得期数...',
        'select_play_method':    '请选择玩法',
        'bet_amount_range':      '投注金额在{min}~{max}之间',
        'confirm_bet_cancel':    '确定投注',
        'cancel':                '取消',
        'go_login_cancel':       '前往登录',
        'server_error_retry':    '服务器请求失败，请重试...',
        'bet_return':            '投注',
        'return_btn':            '返回',
        'select_bet_hint':       '选择玩法，点击金额投注',
        'selected_n_methods':    '已选择 {n} 注玩法',

        // === Global.js Dialog Titles/Buttons ===
        'info':                  '信息',
        'confirm':               '确认',

        // === Other UI Labels ===
        'period':                '期',
        'seal':                  '封盘',
        'history_lottery':       '历史开奖',
        'more':                  '更多',
        'road_map':              '摊路',
        'loading':               '加载中...',
        'quick_order':           '快捷下单',
        'bet_amount_label':      '投注金额：',
        'bet_btn':               '投注',
        'reset_btn':             '重置',
        'how_to_play':           '怎么玩？',
        'total_amount':          '总金额：',
        'sum_big_short':         '合大',
        'sum_small_short':       '合小',
        'harmony':               '和',

        // === Missing Keys (from game_chat.html) ===
        'period_sealed_msg':     '期封盘中...',
        'drawing_lottery':       '开奖中',
        'betting_in_progress':   '投注中',
        'fan_unit':              '番',
        'champion_runner_up':    '冠亚',
        'dragon':                '龙',
        'tiger':                 '虎',
        'tie':                   '和',
        'total_sum':             '总和',
        'already_selected':      '已选择',
        'selected_methods':      '注玩法',
        'please_select_method':  '请选择玩法',
        'server_request_failed': '服务器请求失败，请重试...',
        'confirm_bet':           '确定投注',
        'go_login':              '前往登录',
        // === Banker System ===
        'banker':                '庄',
        'banker_label':          '庄',
        'banker_already_exists': '已有庄家',
        'banker_exists':         '庄家已存在',
        'banker_limit_reached':  '庄家额度已满',
        'banker_limit_reached_no_bet': '庄家额度不足，无法下注',
        'banker_min_amount':     '庄家最低金额',
        'banker_over_limit':     '庄家超额',
        'banker_remaining_limit':'庄家剩余额度',
        'current_period_has_banker': '当期已有庄家',
        'method_has_banker_no_bet': '该玩法已有庄家，不可下注',
        'please_place_chip':     '请下注',

        // === Status / Order ===
        'sealed_now':            '已封盘',
        'wait_settlement_demo':  '等待结算',
        'wait_lottery':          '等待开奖',
        'betting_closed':        '已封盘',
        'bet_success':           '投注成功',
        'bet_failed':            '投注失败',
        'insufficient_balance':  '余额不足',
        'invalid_amount':        '无效金额',
        'invalid_params':        '无效参数',
        'not_logged_in':         '未登录',
        'not_logged_in_please_login': '未登录，请登录',
        'captcha_correct':       '验证码正确',
        'success':               '成功',
        'system_maintenance':    '系统维护中',
        'deposit_failed':        '充值失败',
        'withdraw_success':      '提现成功',
        'withdraw_failed':       '提现失败',
        'wait_pay':              '等待支付',
        'online_deposit':        '在线充值',
        'manual_deposit':        '人工充值',
        'agent_deposit':         '代理充值',
        'wait_process':          '等待处理',
        'processing':            '处理中',
        'gambling_warning':      '理性投注，切勿沉迷',
        'period_no':             '期号',
        'period_bet_order':      '期注单',
        'total_amount_label':    '总金额：',

        // === Transaction Labels ===
        'profit':                '盈亏',
        'red_packet':            '红包',
        'refund_order':          '退款',
        'balance_change':        '余额变动',
        'actual':                '实际',
        'service_fee':           '手续费',
        'order_no':              '订单号',
        'value':                 '值',
        'points':                '分',
        'no_data':               '暂无数据',
        // === Missing Action Keys ===
        'bet':                   '投注',
        'deposit':               '充值',
        'go_back':               '返回',
        'go_to_login':           '前往登录',
        'pay_now':               '立即支付',
        'withdraw':              '提款',

        // === Error Page Keys ===
        'page_not_exist':        '您当前访问的页面不存在！',
        'kefu_offline_tip':      '客服系统暂未开放，请稍后再试或返回首页。',
        'game_data_empty':       '游戏数据为空，请稍后再试！',
        'game_not_exist':        '游戏不存在！',
        'game_data_error':       '游戏数据异常，请联系客服！',
        'template_not_exist':    '模板文件不存在！',
        'username_not_exist':    '用户名不存在！'
    },

    'en-us': {
        // === Period/Status Messages ===
        'period_betting':        ' period is open for betting',
        'period_sealed':         ' period is sealed',
        'period_about_open':     ' period is about to draw, now sealed',
        'drawing':               'Drawing...',
        'already_sealed':        'Sealed',
        'betting':               'Betting',

        // === Lottery Terms ===
        'last_2_digits':         'Last 2 Digits',
        'fan':                   'Fan',
        'crown':                 'Crown & Runner-up',
        'crown_big_small_odd_even': 'Crown Big/Small/Odd/Even',
        'dragon_tiger':          'Dragon/Tiger',
        'sum':                   'Sum',
        'sum_big_small_odd_even':'Sum Big/Small/Odd/Even',
        'special_code':          'Special Code',

        // === Ball Labels ===
        'ball_1':                'Ball 1',
        'ball_2':                'Ball 2',
        'ball_3':                'Ball 3',
        'ball_4':                'Ball 4',
        'ball_5':                'Ball 5',
        'ball_6':                'Ball 6',
        'ball_7':                'Ball 7',
        'ball_8':                'Ball 8',
        'ball_9':                'Ball 9',
        'ball_10':               'Ball 10',

        // === Big/Small/Odd/Even ===
        'big':                   'Big',
        'small':                 'Small',
        'odd':                   'Odd',
        'even':                  'Even',
        'big_small_odd_even':    'Big/Small/Odd/Even',
        'big_odd':               'Big Odd',
        'big_even':              'Big Even',
        'small_odd':             'Small Odd',
        'small_even':            'Small Even',
        'extreme_big':           'Extreme Big',
        'extreme_small':         'Extreme Small',

        // === Lottery Combination Terms ===
        'leopard':               'Leopard',
        'straight':              'Straight',
        'pair':                  'Pair',
        'half_straight':         'Half Straight',
        'mixed_six':             'Mixed Six',

        // === Position Terms ===
        'first_three':           'First 3',
        'middle_three':          'Middle 3',
        'last_three':            'Last 3',

        // === Color Waves ===
        'red_wave':              'Red Wave',
        'green_wave':            'Green Wave',
        'blue_wave':             'Blue Wave',
        'red_big':               'Red Big',
        'red_small':             'Red Small',
        'red_odd':               'Red Odd',
        'red_even':              'Red Even',
        'blue_big':              'Blue Big',
        'blue_small':            'Blue Small',
        'blue_odd':              'Blue Odd',
        'blue_even':             'Blue Even',
        'green_big':             'Green Big',
        'green_small':           'Green Small',
        'green_odd':             'Green Odd',
        'green_even':            'Green Even',

        // === Animal/Zodiac Terms ===
        'poultry_beast':         'Poultry/Beast',
        'poultry':               'Poultry',
        'beast':                 'Beast',
        'zodiac_ox':             'Ox',
        'zodiac_chicken':        'Chicken',
        'zodiac_goat':           'Goat',
        'zodiac_pig':            'Pig',
        'zodiac_dog':            'Dog',
        'zodiac_horse':          'Horse',
        'zodiac_snake':          'Snake',
        'zodiac_rat':            'Rat',
        'zodiac_tiger':          'Tiger',
        'zodiac_rabbit':         'Rabbit',
        'zodiac_dragon':         'Dragon',
        'zodiac_monkey':         'Monkey',
        'zodiac_animals':        'Ox/Chicken/Goat/Pig/Dog/Horse/Snake/Rat/Tiger/Rabbit/Dragon/Monkey',

        // === Position/Head/Tail Terms ===
        'head_0':                '0s',
        'head_1':                '10s',
        'head_2':                '20s',
        'head_3':                '30s',
        'head_4':                '40s',
        'tail_0':                'Tail 0',
        'tail_1':                'Tail 1',
        'tail_2':                'Tail 2',
        'tail_3':                'Tail 3',
        'tail_4':                'Tail 4',
        'tail_5':                'Tail 5',
        'tail_6':                'Tail 6',
        'tail_7':                'Tail 7',
        'tail_8':                'Tail 8',
        'tail_9':                'Tail 9',

        // === PK10 Specific ===
        'crown_army':            '1st Place',
        'runner_up':             '2nd Place',
        'third_place':           '3rd Place',
        'fourth_place':          '4th Place',
        'fifth_place':           '5th Place',
        'sixth_place':           '6th Place',
        'seventh_place':         '7th Place',
        'eighth_place':          '8th Place',
        'ninth_place':           '9th Place',
        'tenth_place':           '10th Place',
        'corner_1_2':            '1-2 Corner',
        'corner_2_3':            '2-3 Corner',
        'corner_3_4':            '3-4 Corner',
        'corner_4_1':            '4-1 Corner',

        // === Combination Sum Terms ===
        'sum_big':               'Sum Big',
        'sum_small':             'Sum Small',
        'sum_odd':               'Sum Odd',
        'sum_even':              'Sum Even',

        // === Dialog/Alert Messages ===
        'no_period_yet':         'Period not available yet...',
        'select_play_method':    'Please select a play method',
        'bet_amount_range':      'Bet amount must be between {min}~{max}',
        'confirm_bet_cancel':    'Confirm Bet',
        'cancel':                'Cancel',
        'go_login_cancel':       'Go to Login',
        'server_error_retry':    'Server request failed, please retry...',
        'bet_return':            'Bet',
        'return_btn':            'Return',
        'select_bet_hint':       'Select play method, click amount to bet',
        'selected_n_methods':    '{n} method(s) selected',

        // === Global.js Dialog Titles/Buttons ===
        'info':                  'Info',
        'confirm':               'Confirm',

        // === Other UI Labels ===
        'period':                ' Period',
        'seal':                  'Sealed',
        'history_lottery':       'History',
        'more':                  'More',
        'road_map':              'Road Map',
        'loading':               'Loading...',
        'quick_order':           'Quick Order',
        'bet_amount_label':      'Bet Amount: ',
        'bet_btn':               'Bet',
        'reset_btn':             'Reset',
        'how_to_play':           'How to Play?',
        'total_amount':          'Total: ',
        'sum_big_short':         'S.Big',
        'sum_small_short':       'S.Small',
        'harmony':               'Tie',

        // === Missing Keys (from game_chat.html) ===
        'period_sealed_msg':     ' period sealing...',
        'drawing_lottery':       'Drawing',
        'betting_in_progress':   'Betting',
        'fan_unit':              ' Fan',
        'champion_runner_up':    'Crown & Runner-up',
        'dragon':                'Dragon',
        'tiger':                 'Tiger',
        'tie':                   'Tie',
        'total_sum':             'Total Sum',
        'already_selected':      'Selected',
        'selected_methods':      ' method(s)',
        'please_select_method':  'Please select a play method',
        'server_request_failed': 'Server request failed, please retry...',
        'confirm_bet':           'Confirm Bet',
        'go_login':              'Go to Login',
        // === Banker System ===
        'banker':                'Banker',
        'banker_label':          'Banker',
        'banker_already_exists': 'Banker already exists',
        'banker_exists':         'Banker exists',
        'banker_limit_reached':  'Banker limit reached',
        'banker_limit_reached_no_bet': 'Banker limit reached, cannot bet',
        'banker_min_amount':     'Banker minimum amount',
        'banker_over_limit':     'Banker over limit',
        'banker_remaining_limit':'Banker remaining limit',
        'current_period_has_banker': 'Current period already has a banker',
        'method_has_banker_no_bet': 'This method has a banker, cannot bet',
        'please_place_chip':     'Please place a bet',

        // === Status / Order ===
        'sealed_now':            'Sealed',
        'wait_settlement_demo':  'Waiting for settlement',
        'wait_lottery':          'Waiting for draw',
        'betting_closed':        'Betting closed',
        'bet_success':           'Bet placed successfully',
        'bet_failed':            'Bet failed',
        'insufficient_balance':  'Insufficient balance',
        'invalid_amount':        'Invalid amount',
        'invalid_params':        'Invalid parameters',
        'not_logged_in':         'Not logged in',
        'not_logged_in_please_login': 'Not logged in, please login',
        'captcha_correct':       'Captcha correct',
        'success':               'Success',
        'system_maintenance':    'System maintenance',
        'deposit_failed':        'Deposit failed',
        'withdraw_success':      'Withdrawal successful',
        'withdraw_failed':       'Withdrawal failed',
        'wait_pay':              'Pending Payment',
        'online_deposit':        'Online Deposit',
        'manual_deposit':        'Manual Deposit',
        'agent_deposit':         'Agent Deposit',
        'wait_process':          'Pending',
        'processing':            'Processing',
        'gambling_warning':      'Bet responsibly',
        'period_no':             'Period No.',
        'period_bet_order':      'Period bet order',
        'total_amount_label':    'Total: ',

        // === Transaction Labels ===
        'profit':                'Profit',
        'red_packet':            'Red Packet',
        'refund_order':          'Refund',
        'balance_change':        'Balance Change',
        'actual':                'Actual',
        'service_fee':           'Service Fee',
        'order_no':              'Order No.',
        'value':                 'Value',
        'points':                'Points',
        'no_data':               'No data',
        // === Missing Action Keys ===
        'bet':                   'Bet',
        'deposit':               'Deposit',
        'go_back':               'Back',
        'go_to_login':           'Go to Login',
        'pay_now':               'Pay Now',
        'withdraw':              'Withdraw',

        // === Error Page Keys ===
        'page_not_exist':        'The page you are looking for does not exist!',
        'kefu_offline_tip':      'Customer service is temporarily unavailable. Please try again later or return to homepage.',
        'game_data_empty':       'Game data is empty, please try again later!',
        'game_not_exist':        'Game does not exist!',
        'game_data_error':       'Game data error, please contact customer service!',
        'template_not_exist':    'Template file does not exist!',
        'username_not_exist':    'Username does not exist!'
    },

    'my-mm': {
        // === Period/Status Messages ===
        'period_betting':        ' ကာလပေါက်စရာရှိနေသည်',
        'period_sealed':         ' ကာလပိတ်သွားပါပြီ',
        'period_about_open':     ' ကာလမကြာမီဖွင့်မည်၊ ယခုပိတ်သွားပါပြီ',
        'drawing':               'ထွက်နေသည်...',
        'already_sealed':        'ပိတ်သွားပါပြီ',
        'betting':               'လောင်းကစားနေသည်',

        // === Lottery Terms ===
        'last_2_digits':         'နောက်ဆုံး ၂ လုံး',
        'fan':                   'ဖန်',
        'crown':                 'ချန်ပီယံ/ဒုတိယ',
        'crown_big_small_odd_even': 'ချန်ပီယံ ကြီး/ငယ်/မ/စုံ',
        'dragon_tiger':          'နဂါး/ကျား',
        'sum':                   'စုစုပေါင်း',
        'sum_big_small_odd_even':'စုစုပေါင်း ကြီး/ငယ်/မ/စုံ',
        'special_code':          'အထူးကုတ်',

        // === Ball Labels ===
        'ball_1':                'ဘောလုံး ၁',
        'ball_2':                'ဘောလုံး ၂',
        'ball_3':                'ဘောလုံး ၃',
        'ball_4':                'ဘောလုံး ၄',
        'ball_5':                'ဘောလုံး ၅',
        'ball_6':                'ဘောလုံး ၆',
        'ball_7':                'ဘောလုံး ၇',
        'ball_8':                'ဘောလုံး ၈',
        'ball_9':                'ဘောလုံး ၉',
        'ball_10':               'ဘောလုံး ၁၀',

        // === Big/Small/Odd/Even ===
        'big':                   'ကြီး',
        'small':                 'ငယ်',
        'odd':                   'မ',
        'even':                  'စုံ',
        'big_small_odd_even':    'ကြီး/ငယ်/မ/စုံ',
        'big_odd':               'ကြီး မ',
        'big_even':              'ကြီး စုံ',
        'small_odd':             'ငယ် မ',
        'small_even':            'ငယ် စုံ',
        'extreme_big':           'အကြီးဆုံး',
        'extreme_small':         'အငယ်ဆုံး',

        // === Lottery Combination Terms ===
        'leopard':               'ကျားသစ်',
        'straight':              'အစဉ်',
        'pair':                  'စုံတွဲ',
        'half_straight':         'ထက်ဝက်အစဉ်',
        'mixed_six':             'ရောနှောခြောက်',

        // === Position Terms ===
        'first_three':           'ရှေ့ ၃ လုံး',
        'middle_three':          'အလယ် ၃ လုံး',
        'last_three':            'နောက် ၃ လုံး',

        // === Color Waves ===
        'red_wave':              'နီလှိုင်း',
        'green_wave':            'စိမ်းလှိုင်း',
        'blue_wave':             'ပြာလှိုင်း',
        'red_big':               'နီ ကြီး',
        'red_small':             'နီ ငယ်',
        'red_odd':               'နီ မ',
        'red_even':              'နီ စုံ',
        'blue_big':              'ပြာ ကြီး',
        'blue_small':            'ပြာ ငယ်',
        'blue_odd':              'ပြာ မ',
        'blue_even':             'ပြာ စုံ',
        'green_big':             'စိမ်း ကြီး',
        'green_small':           'စိမ်း ငယ်',
        'green_odd':             'စိမ်း မ',
        'green_even':            'စိမ်း စုံ',

        // === Animal/Zodiac Terms ===
        'poultry_beast':         'တိရစ္ဆာန်/သားရဲ',
        'poultry':               'တိရစ္ဆာန်',
        'beast':                 'သားရဲ',
        'zodiac_ox':             'နွား',
        'zodiac_chicken':        'ကြက်',
        'zodiac_goat':           'ဆိတ်',
        'zodiac_pig':            'ဝက်',
        'zodiac_dog':            'ခွေး',
        'zodiac_horse':          'မြင်း',
        'zodiac_snake':          'မြွေ',
        'zodiac_rat':            'ကြွက်',
        'zodiac_tiger':          'ကျား',
        'zodiac_rabbit':         'ယုန်',
        'zodiac_dragon':         'နဂါး',
        'zodiac_monkey':         'မျောက်',
        'zodiac_animals':        'နွား/ကြက်/ဆိတ်/ဝက်/ခွေး/မြင်း/မြွေ/ကြွက်/ကျား/ယုန်/နဂါး/မျောက်',

        // === Position/Head/Tail Terms ===
        'head_0':                '၀ ဆယ်',
        'head_1':                '၁ ဆယ်',
        'head_2':                '၂ ဆယ်',
        'head_3':                '၃ ဆယ်',
        'head_4':                '၄ ဆယ်',
        'tail_0':                'ပေါက် ၀',
        'tail_1':                'ပေါက် ၁',
        'tail_2':                'ပေါက် ၂',
        'tail_3':                'ပေါက် ၃',
        'tail_4':                'ပေါက် ၄',
        'tail_5':                'ပေါက် ၅',
        'tail_6':                'ပေါက် ၆',
        'tail_7':                'ပေါက် ၇',
        'tail_8':                'ပေါက် ၈',
        'tail_9':                'ပေါက် ၉',

        // === PK10 Specific ===
        'crown_army':            'ပထမဆု',
        'runner_up':             'ဒုတိယဆု',
        'third_place':           'တတိယဆု',
        'fourth_place':          'စတုတ္ထဆု',
        'fifth_place':           'ပဉ္စမဆု',
        'sixth_place':           'ဆဋ္ဌမဆု',
        'seventh_place':         'သတ္တမဆု',
        'eighth_place':          'အဋ္ဌမဆု',
        'ninth_place':           'နဝမဆု',
        'tenth_place':           'ဒသမဆု',
        'corner_1_2':            '၁-၂ ထောင့်',
        'corner_2_3':            '၂-၃ ထောင့်',
        'corner_3_4':            '၃-၄ ထောင့်',
        'corner_4_1':            '၄-၁ ထောင့်',

        // === Combination Sum Terms ===
        'sum_big':               'ပေါင်းစပ် ကြီး',
        'sum_small':             'ပေါင်းစပ် ငယ်',
        'sum_odd':               'ပေါင်းစပ် မ',
        'sum_even':              'ပေါင်းစပ် စုံ',

        // === Dialog/Alert Messages ===
        'no_period_yet':         'ကာလအား မရရှိသေးပါ...',
        'select_play_method':    'ကစားနည်းရွေးချယ်ပါ',
        'bet_amount_range':      'လောင်းကစားငွေ {min}~{max} အတွင်းဖြစ်ရပါမည်',
        'confirm_bet_cancel':    'အတည်ပြုလောင်းမည်',
        'cancel':                'မလုပ်တော့',
        'go_login_cancel':       'ဝင်ရောက်ရန်သွားမည်',
        'server_error_retry':    'ဆာဗာတွင်အခက်အခဲရှိနေသည်၊ ထပ်စမ်းကြည့်ပါ...',
        'bet_return':            'လောင်းမည်',
        'return_btn':            'ပြန်သွားမည်',
        'select_bet_hint':       'ကစားနည်းရွေးချယ်ပြီး ငွေပမာဏကိုနှိပ်ပါ',
        'selected_n_methods':    'ကစားနည်း {n} မျိုးရွေးချယ်ထားသည်',

        // === Global.js Dialog Titles/Buttons ===
        'info':                  'သတင်း',
        'confirm':               'အတည်ပြု',

        // === Other UI Labels ===
        'period':                ' ကာလ',
        'seal':                  'ပိတ်သွားပြီ',
        'history_lottery':       'ရာဇဝင်',
        'more':                  'ပိုမို',
        'road_map':              'လမ်းပုံ',
        'loading':               'တင်နေသည်...',
        'quick_order':           'မြန်မြန်မှာယူမည်',
        'bet_amount_label':      'လောင်းကစားငွေ: ',
        'bet_btn':               'လောင်းမည်',
        'reset_btn':             'ပြန်လည်သတ်မှတ်',
        'how_to_play':           'ဘယ်လိုကစားမလဲ?',
        'total_amount':          'စုစုပေါင်း: ',
        'sum_big_short':         'ပေါင်းကြီး',
        'sum_small_short':       'ပေါင်းငယ်',
        'harmony':               'သရေ',

        // === Missing Keys (from game_chat.html) ===
        'period_sealed_msg':     ' ကာလပိတ်နေသည်...',
        'drawing_lottery':       'ထွက်နေသည်',
        'betting_in_progress':   'လောင်းကစားနေသည်',
        'fan_unit':              'ဖန်',
        'champion_runner_up':    'ချန်ပီယံ/ဒုတိယ',
        'dragon':                'နဂါး',
        'tiger':                 'ကျား',
        'tie':                   'သရေ',
        'total_sum':             'စုစုပေါင်း',
        'already_selected':      'ရွေးချယ်ပြီး',
        'selected_methods':      ' နည်းလမ်း',
        'please_select_method':  'ကစားနည်းရွေးချယ်ပါ',
        'server_request_failed': 'ဆာဗာတွင်အခက်အခဲရှိနေသည်၊ ထပ်စမ်းကြည့်ပါ...',
        'confirm_bet':           'အတည်ပြုလောင်းမည်',
        'go_login':              'ဝင်ရောက်ရန်သွားမည်',
        // === ဘောက်ဆာစနစ် ===
        'banker':                'ဘောက်ဆာ',
        'banker_label':          'ဘောက်ဆာ',
        'banker_already_exists': 'ဘောက်ဆာရှိပြီးသားဖြစ်သည်',
        'banker_exists':         'ဘောက်ဆာရှိပြီးသားဖြစ်သည်',
        'banker_limit_reached':  'ဘောက်ဆာကန့်သတ်ရောက်ရှိပြီ',
        'banker_limit_reached_no_bet': 'ဘောက်ဆာကန့်သတ်ရောက်ရှိပြီ၊ ချိန်းမရပါ',
        'banker_min_amount':     'ဘောက်ဆာအနည်းဆုံးငွေပမာဏ',
        'banker_over_limit':     'ဘောက်ဆာကန့်သတ်ကျော်လွန်',
        'banker_remaining_limit':'ဘောက်ဆာကျန်ရှိသောကန့်သတ်',
        'current_period_has_banker': 'ယခုပွဲစဉ်တွင်ဘောက်ဆာရှိပြီးသားဖြစ်သည်',
        'method_has_banker_no_bet': 'ဤနည်းလမ်းတွင်ဘောက်ဆာရှိပြီး၊ ချိန်းမရပါ',
        'please_place_chip':     'ကျေးဇူးပြု၍ချိန်းပါ',

        // === အခြေအနေ / မှာယူမှု ===
        'sealed_now':            'ပိတ်သွားပါပြီ',
        'wait_settlement_demo':  'အချိန်းစစ်ဆေးမှုစောင့်ပါ',
        'wait_lottery':          'ထုတ်ရန်စောင့်ပါ',
        'betting_closed':        'ပိတ်သွားပါပြီ',
        'bet_success':           'ချိန်းအောင်မြင်ပါပြီ',
        'bet_failed':            'ချိန်းမအောင်မြင်ပါ',
        'insufficient_balance':  'လက်ကျန်ငွေမလုံလောက်ပါ',
        'invalid_amount':        'ငွေပမာဏမမှန်ကန်ပါ',
        'invalid_params':        'ပါရာမီတာမမှန်ကန်ပါ',
        'not_logged_in':         'ဝင်ရောက်မထားပါ',
        'not_logged_in_please_login': 'ဝင်ရောက်မထားပါ၊ ကျေးဇူးပြု၍ဝင်ရောက်ပါ',
        'captcha_correct':       'အတည်ပြုကုဒ်မှန်ကန်ပါသည်',
        'success':               'အောင်မြင်ပါသည်',
        'system_maintenance':    'စနစ်ပြင်ဆင်နေဆဲ',
        'deposit_failed':        'ငွေသွင်းမအောင်မြင်ပါ',
        'withdraw_success':      'ငွေထုတ်အောင်မြင်ပါပြီ',
        'withdraw_failed':       'ငွေထုတ်မအောင်မြင်ပါ',
        'wait_pay':              'ငွေပေးချေရန်စောင့်ဆိုင်းဆဲ',
        'online_deposit':        'အွန်လိုင်းငွေသွင်း',
        'manual_deposit':        'လက်အားငွေသွင်း',
        'agent_deposit':         'ကိုယ်စားလှယ်ငွေသွင်း',
        'wait_process':          'ဆောင်ရွက်ရန်စောင့်ဆိုင်းဆဲ',
        'processing':            'ဆောင်ရွက်နေဆဲ',
        'gambling_warning':      'သတိထား၍ချိန်းပါ',
        'period_no':             'ပွဲစဉ်အမှတ်',
        'period_bet_order':      'ပွဲစဉ်ချိန်းမှတ်တမ်း',
        'total_amount_label':    'စုစုပေါင်း: ',

        // === ငွေစာရင်းအရောင်းကွက်များ ===
        'profit':                'အမြတ်/ဆုံးရှုံး',
        'red_packet':            'လက်ဆောင်',
        'refund_order':          'ပြန်လည်ပေးအပ်',
        'balance_change':        'လက်ကျန်ပြောင်းလဲမှု',
        'actual':                'တကမ်း',
        'service_fee':           'ဝန်ဆောင်ခ',
        'order_no':              'မှာယူမှုအမှတ်',
        'value':                 'တန်ဖိုး',
        'points':                'ရမှတ်',
        'no_data':               'ဒေတာမရှိ',
        // === Missing Action Keys ===
        'bet':                   'ချိန်း',
        'deposit':               'ငွေသွင်း',
        'go_back':               'ပြန်သွား',
        'go_to_login':           'ဝင်ရောက်ရန်သွား',
        'pay_now':               'ယခုငွေပေးချေ',
        'withdraw':              'ငွေထုတ်',

        // === အမှားစာမျက်နှာ ===
        'page_not_exist':        'သင်ဝင်ရောက်လိုသောစာမျက်နှာမရှိပါ!',
        'kefu_offline_tip':      'ဝန်ဆောင်မှုစနစ်ယာယီပိတ်သိမ်းထားသည်၊ ကျေးဇူးပြု၍နောက်မှထပ်စမ်းကြည့်ပါ သို့မဟုတ် ပင်မစာမျက်နှာသို့ပြန်သွားပါ။',
        'game_data_empty':       'ဂိမ်းဒေတာမရှိပါ၊ ကျေးဇူးပြု၍နောက်မှထပ်စမ်းကြည့်ပါ!',
        'game_not_exist':        'ဂိမ်းမရှိပါ!',
        'game_data_error':       'ဂိမ်းဒေတာမမှန်ကန်ပါ၊ ဝန်ဆောင်မှုဌာနကိုဆက်သွယ်ပါ!',
        'template_not_exist':    'တမ်းပလိတ်ဖိုင်မရှိပါ!',
        'username_not_exist':    'အသုံးပြုသူအမည်မရှိပါ!'
    }
};

/**
 * Translation function
 * @param {string} key - Translation key
 * @param {object} [params] - Optional parameters for substitution, e.g. {min: 1, max: 100}
 * @returns {string} Translated text
 */

/**
 * Translate wanfa (play method) text from Chinese to current language
 * @param {string} wanfaText - Raw wanfa text like "大@冠军" or "冠亚大@冠亚"
 * @returns {string} Translated wanfa text
 */
function translateWanfa(wanfaText) {
    if (!wanfaText) return wanfaText;
    
    // Chinese to i18n key mapping
    var wanfaMap = {
        // PK10 Position terms
        '冠军': 'crown_army',
        '亚军': 'runner_up',
        '第三名': 'third_place',
        '第四名': 'fourth_place',
        '第五名': 'fifth_place',
        '第六名': 'sixth_place',
        '第七名': 'seventh_place',
        '第八名': 'eighth_place',
        '第九名': 'ninth_place',
        '第十名': 'tenth_place',
        '冠亚': 'crown',
        '冠亚军': 'crown',
        '总和': 'total_sum',
        
        // Big/Small/Odd/Even
        '大': 'big',
        '小': 'small',
        '单': 'odd',
        '双': 'even',
        
        // Dragon/Tiger
        '龙': 'dragon',
        '虎': 'tiger',
        '和': 'harmony',
        
        // Ball labels (时时彩/时时彩)
        '第一球': 'ball_1',
        '第二球': 'ball_2',
        '第三球': 'ball_3',
        '第四球': 'ball_4',
        '第五球': 'ball_5',
        '第六球': 'ball_6',
        '第七球': 'ball_7',
        '第八球': 'ball_8',
        '第九球': 'ball_9',
        '第十球': 'ball_10',
        
        // Combination terms
        '前三': 'first_three',
        '中三': 'middle_three',
        '后三': 'last_three',
        '豹子': 'leopard',
        '顺子': 'straight',
        '对子': 'pair',
        '半顺': 'half_straight',
        '杂六': 'mixed_six',
        
        // Color waves
        '红波': 'red_wave',
        '绿波': 'green_wave',
        '蓝波': 'blue_wave',
        
        // Special code
        '特码': 'special_code',
        
        // Poultry/Beast
        '家禽': 'poultry',
        '野兽': 'beast',
        '家禽/野兽': 'poultry_beast',
        
        // Zodiac animals
        '牛': 'zodiac_ox',
        '鸡': 'zodiac_chicken',
        '羊': 'zodiac_goat',
        '猪': 'zodiac_pig',
        '狗': 'zodiac_dog',
        '马': 'zodiac_horse',
        '蛇': 'zodiac_snake',
        '鼠': 'zodiac_rat',
        '虎': 'zodiac_tiger',
        '兔': 'zodiac_rabbit',
        '龙': 'zodiac_dragon',
        '猴': 'zodiac_monkey',
        
        // Composite terms (big/small + odd/even)
        '大单': 'big_odd',
        '大双': 'big_even',
        '小单': 'small_odd',
        '小双': 'small_even',
        '极大': 'extreme_big',
        '极小': 'extreme_small',
        
        // Sum composite
        '合数大': 'sum_big',
        '合数小': 'sum_small',
        '合数单': 'sum_odd',
        '合数双': 'sum_even',
        
        // Color + big/small/odd/even composites
        '红大': 'red_big',
        '红小': 'red_small',
        '红单': 'red_odd',
        '红双': 'red_even',
        '蓝大': 'blue_big',
        '蓝小': 'blue_small',
        '蓝单': 'blue_odd',
        '蓝双': 'blue_even',
        '绿大': 'green_big',
        '绿小': 'green_small',
        '绿单': 'green_odd',
        '绿双': 'green_even',
        
        // Head/Tail
        '0头': 'head_0',
        '1头': 'head_1',
        '2头': 'head_2',
        '3头': 'head_3',
        '4头': 'head_4',
        '0尾': 'tail_0',
        '1尾': 'tail_1',
        '2尾': 'tail_2',
        '3尾': 'tail_3',
        '4尾': 'tail_4',
        '5尾': 'tail_5',
        '6尾': 'tail_6',
        '7尾': 'tail_7',
        '8尾': 'tail_8',
        '9尾': 'tail_9',
        
        // FanTan specific terms
        '番1': 'fan_fan_1',
        '番2': 'fan_fan_2',
        '番3': 'fan_fan_3',
        '番4': 'fan_fan_4',
        '正1': 'fan_zheng_1',
        '正2': 'fan_zheng_2',
        '正3': 'fan_zheng_3',
        '正4': 'fan_zheng_4',
        '1念2': 'fan_1_nian_2',
        '1念3': 'fan_1_nian_3',
        '1念4': 'fan_1_nian_4',
        '2念1': 'fan_2_nian_1',
        '2念3': 'fan_2_nian_3',
        '2念4': 'fan_2_nian_4',
        '3念1': 'fan_3_nian_1',
        '3念2': 'fan_3_nian_2',
        '3念4': 'fan_3_nian_4',
        '4念1': 'fan_4_nian_1',
        '4念2': 'fan_4_nian_2',
        '4念3': 'fan_4_nian_3',
        '1-2角': 'corner_1_2',
        '2-3角': 'corner_2_3',
        '3-4角': 'corner_3_4',
        '4-1角': 'corner_4_1',
        
        // Crown/Runner-up composite
        '冠亚大': 'crown_big',
        '冠亚小': 'crown_small',
        '冠亚单': 'crown_odd',
        '冠亚双': 'crown_even',
    };
    
    // Composite mapping for terms like "冠亚和单双" etc
    var compositeMap = {
        '冠亚大/小/单/双': 'crown_big_small_odd_even',
        '大/小/单/双': 'big_small_odd_even',
        '龙/虎': 'dragon_tiger',
        '总和大/小/单/双': 'sum_big_small_odd_even',
        '总和龙/虎/和': 'sum_big_small_odd_even',
    };
    
    // Try composite map first
    if (compositeMap[wanfaText]) {
        return __(compositeMap[wanfaText]);
    }
    
    // Split by "@" separator
    var parts = wanfaText.split('@');
    var translated = [];
    
    for (var i = 0; i < parts.length; i++) {
        var part = parts[i];
        
        // Try direct mapping
        if (wanfaMap[part]) {
            translated.push(__(wanfaMap[part]));
        }
        // Try to handle composite terms like "冠亚大" by breaking them down
        else if (part.length > 1 && !/^\d+$/.test(part) && !/^\d+V\d+$/.test(part)) {
            var found = false;
            // Try the whole composite first
            if (wanfaMap[part]) {
                translated.push(__(wanfaMap[part]));
                found = true;
            }
            if (!found) {
                // Try splitting composite like "冠亚大" into "冠亚" + "大"
                for (var j = part.length; j > 0; j--) {
                    var prefix = part.substring(0, j);
                    var suffix = part.substring(j);
                    if (wanfaMap[prefix]) {
                        var t = __(wanfaMap[prefix]);
                        if (suffix && wanfaMap[suffix]) {
                            t += ' ' + __(wanfaMap[suffix]);
                        } else if (suffix) {
                            t += suffix;
                        }
                        translated.push(t);
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    translated.push(part);
                }
            }
        }
        else {
            // Numbers and V-patterns (1V10) stay as-is
            translated.push(part);
        }
    }
    
    return translated.join('@');
}

function __(key, params) {
    var lang = I18N_LANG;
    var pack = I18N_PACKS[lang] || I18N_PACKS['zh-cn'];
    var text = pack[key] || I18N_PACKS['zh-cn'][key] || key;
    if (params) {
        for (var k in params) {
            if (params.hasOwnProperty(k)) {
                text = text.replace(new RegExp('\\{' + k + '\\}', 'g'), params[k]);
            }
        }
    }
    return text;
}
