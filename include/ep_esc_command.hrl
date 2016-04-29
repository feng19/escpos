
-define(ESC, 27).

-define(FONT_A, 2#00000000). %% 标准ASCII码字体A (12 × 24)
-define(FONT_B, 2#00000001). %% 标准ASCII码字体B (9 × 17)
-define(EMPHA_SIZED_FALSE, 2#00000000). %% 取消加粗模式
-define(EMPHA_SIZED_TRUE, 2#00001000). %% 选择加粗模式
-define(DOUBLE_HEIGHT_FALSE, 2#00000000). %% 取消倍高模式
-define(DOUBLE_HEIGHT_TRUE, 2#00010000). %% 选择倍高模式
-define(DOUBLE_WIDTH_FALSE, 2#00000000). %% 取消倍宽模式
-define(DOUBLE_WIDTH_TRUE, 2#00100000). %% 选择倍宽模式
-define(UNDERLINE_FALSE, 2#00000000). %% 取消下划线模式
-define(UNDERLINE_TRUE, 2#10000000). %% 选择下划线模式

-define(UNDERLINEMODE_OFF, 0). %% 取消下划线模式
-define(UNDERLINEMODE_1DOT, 1). %% 选择下划线模式(1点宽)
-define(UNDERLINEMODE_2DOT, 2). %% 选择下划线模式(2点宽)

-define(CHARACTER_USA, 0). %%美国
-define(CHARACTER_FRANCE, 1). %%法国
-define(CHARACTER_GERMANY, 2). %%德国
-define(CHARACTER_UK, 3). %%英国
-define(CHARACTER_DENMARK_I, 4). %%丹麦
-define(CHARACTER_SWEDEN, 5). %% 瑞典
-define(CHARACTER_ITALY, 6). %%意大利
-define(CHARACTER_SPAIN_I, 7). %%西班牙
-define(CHARACTER_JAPAN, 8). %%日本
-define(CHARACTER_NORWAY, 9). %%挪威
-define(CHARACTER_DENMARK_II, 10). %%丹麦 II
-define(CHARACTER_SPAIN_II, 11). %%西班牙 II
-define(CHARACTER_LATIN_AMERCIA, 12). %%拉丁美洲
-define(CHARACTER_KOREAN, 13). %%韩国
-define(CHARACTER_SLOVENIA, 14). %%克罗地亚/斯罗维尼亚
-define(CHARACTER_CHINA, 15). %%中国

