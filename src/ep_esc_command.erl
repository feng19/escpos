%%%-------------------------------------------------------------------
%%% @author pwf
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ep_esc_command).
-author("pwf").
-include_lib("qrcode/src/qrcode.hrl").
-include("ep_esc_command.hrl").

%%-on_load(init_iconv/0).

%% API
-compile([export_all]).

%%init_iconv() ->
%%    iconv:load_nif().

%% 加入跳格符
addHorTab() ->
    <<9>>.

%% 加入文字
addText(Binary) ->
    iconv:convert(<<"utf8">>, <<"gbk">>, Binary).

%% 打印并换行
addPrintAndLineFeed() ->
    <<10>>.

%% 设置字符右间距
addSetRightSideCharacterSpacing(N) ->
    <<?ESC, $ , N>>.

%% 设置打印模式
addSelectPrintModes(Font,Emphasized,Doubleheight,Doublewidth,Underline) ->
    addSelectPrintModes(Font+Emphasized+Doubleheight+Doublewidth+Underline).
addSelectPrintModes(N) ->
    <<?ESC, $!, N>>.

%% 设置绝对打印位置
addSetAbsolutePrintPosition(N) ->
    <<?ESC, $$, N:16/little>>.

%% 选择/取消下划线模式
addTurnUnderlineModeOnOrOff(UnderlineMode) ->
    <<?ESC, $-, UnderlineMode>>.

%% 设置为默认行间距,默认行间距为 3.75 mm 约 30 点
addSelectDefualtLineSpacing() ->
    <<?ESC, $2>>.

%% 设置行间距
addSetLineSpacing(N) ->
    <<?ESC, $3, N>>.

%% 初始化打印机
addInitializePrinter() ->
    <<?ESC, $@>>.

%% 是否加粗
addTurnEmphasizedModeOnOrOff(?EMPHA_SIZED_FALSE) ->
    <<?ESC, $E, 0>>;
addTurnEmphasizedModeOnOrOff(?EMPHA_SIZED_TRUE) ->
    <<?ESC, $E, 1>>.

%% 是否加重
addTurnDoubleStrikeOnOrOff(false) ->
    <<?ESC, $G, 0>>;
addTurnDoubleStrikeOnOrOff(true) ->
    <<?ESC, $G, 1>>.

%% 打印并走纸
addPrintAndFeedPaper(N) ->
    <<?ESC, $J, N>>.

%% 选择打印字符字体 12X24 或 9X17
addSelectCharacterFont(?FONT_A) ->
    <<?ESC, $M, 0>>;
addSelectCharacterFont(?FONT_B) ->
    <<?ESC, $M, 1>>.

%% 选择国际字符集
addSelectInternationalCharacterSet(Character) ->
    <<?ESC, $R, Character>>.

%% 打印二维码
qrcode(Binary) ->
    qrcode(Binary, 'M', 4).
%% ECC:L/M/Q/H  ModuleSize:1-16
qrcode(Binary, ECC, ModuleSize) ->
    #qrcode{dimension = Dim, data = Data} = qrcode:encode(Binary, ECC),
    {Size, M} =
    case ModuleSize rem 2 of
        0 ->
            {ModuleSize div 2, 3};
        1 ->
            {ModuleSize, 0}
    end,
    Pixels = get_pixels(Data, 0, Dim, Size, <<>>),
    X = Dim * Size,
    Y = X,
    ZeroSize =
    case (X * Y) rem 8 of
        0 -> 0;
        Zero -> 8 - Zero
    end,
    <<29, 118, 48, M, X:16/little, Y:16/little, Pixels/bits, 0:ZeroSize>>.

get_pixels(<<>>, Dim, Dim, _Size, Acc) ->
    Acc;
get_pixels(Bin, Count, Dim, Size, Acc) ->
    <<RowBits:Dim/bits, Bits/bits>> = Bin,
    Row = get_pixels0(RowBits, Size, <<>>),
    FullRow = list_to_bitstring(lists:duplicate(Size, Row)),
    get_pixels(Bits, Count + 1, Dim, Size, <<Acc/bits, FullRow/bits>>).

%% Black pixel
get_pixels0(<<1:1, Bits/bits>>, Size, Acc) when Size > 8 ->
    get_pixels0(<<1:1, Bits/bits>>, Size-8, <<Acc/bits, 255>>);
get_pixels0(<<1:1, Bits/bits>>, Size, Acc) ->
    get_pixels0(Bits, Size, <<Acc/bits, (255 bsr (8 - Size)):Size>>);
%% White pixel
get_pixels0(<<0:1, Bits/bits>>, Size, Acc) when Size > 8 ->
    get_pixels0(<<0:1, Bits/bits>>, Size-8, <<Acc/bits, 0>>);
get_pixels0(<<0:1, Bits/bits>>, Size, Acc) ->
    get_pixels0(Bits, Size, <<Acc/bits, 0:Size>>);
get_pixels0(<<>>, _Size, Acc) ->
    Acc.

%% size function 67
%% 1<= ModuleSize <= 16
addSelectSizeOfModuleForQRCode(ModuleSize) ->
    <<29, 40, 107, 3, 0, 49, 67, ModuleSize>>.

%% error correction function 69
%% 48<= ErrCorrect <= 51
addSelectErrorCorrectionLevelForQRCode(ErrCorrect) ->
    <<29, 40, 107, 3, 0, 49, 69, ErrCorrect>>.

%% save data function 80
addStoreQRCodeData(DataBin) ->
    Pl = byte_size(DataBin)+3,
    <<29, 40, 107, Pl, 0, 49, 80, 48, DataBin/binary>>.

%% print function 81
addPrintQRCode() ->
    <<29, 40, 107, 3, 0, 49, 81, 48>>.
