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

%% API
-export([
    qrcode/1, qrcode/3,
    addSelectSizeOfModuleForQRCode/1,
    addSelectErrorCorrectionLevelForQRCode/1,
    addStoreQRCodeData/1,
    addPrintQRCode/0
]).

qrcode(Binary) ->
    qrcode(Binary, 'M', 4).
%% ECC:L/M/Q/H
%% ModuleSize:1-16
qrcode(Binary, ECC, ModuleSize) ->
    #qrcode{dimension = Dim, data = Data} = qrcode:encode(Binary, ECC),
    {Size, M} =
    case ModuleSize rem 2 of
        0 ->
            {ModuleSize div 2, 3};
        1 ->
            {ModuleSize, 0}
    end,
    ZeroSize =
    case (Dim * Size) rem 8 of
        0 -> 0;
        Zero -> 8 - Zero
    end,
    Pixels = get_pixels(Data, 0, Dim, Size, ZeroSize, <<>>),
    X = Dim * Size + ZeroSize,
    Y = Dim * Size,
    io:format("X:~p,Y:~p~n",[X,Y]),
    <<29, 118, 48, M, (X rem 256), (X div 256), (Y rem 256), (Y div 256), Pixels/binary>>.

%%get_pixels(<<>>, Dim, Dim, _Size, Acc) ->
%%    Acc;
%%get_pixels(Bin, Count, Dim, Size, Acc) ->
%%    <<RowBits:Dim/bits, Bits/bits>> = Bin,
%%    Row = get_pixels0(RowBits, Size, <<>>),
%%    FullRow = binary:copy(Row, 8*Size),
%%    get_pixels(Bits, Count + 1, Dim, Size, <<Acc/binary, FullRow/binary>>).
%%
%%get_pixels0(<<1:1, Bits/bits>>, Size, Acc) ->%Black
%%    Black = binary:copy(<<255>>, Size),
%%    get_pixels0(Bits, Size, <<Acc/binary, Black/binary>>);
%%get_pixels0(<<0:1, Bits/bits>>, Size, Acc) ->%White
%%    White = binary:copy(<<0>>, Size),
%%    get_pixels0(Bits, Size, <<Acc/binary, White/binary>>);
%%get_pixels0(<<>>, _Size, Acc) ->
%%    Acc.

get_pixels(<<>>, Dim, Dim, _Size, _ZeroSize, Acc) ->
    Acc;
get_pixels(Bin, Count, Dim, Size, ZeroSize, Acc) ->
    <<RowBits:Dim/bits, Bits/bits>> = Bin,
    Row = get_pixels0(RowBits, Size, <<>>),
    FullRow = binary:copy(<<Row/bits, 0:ZeroSize>>, Size),
    get_pixels(Bits, Count + 1, Dim, Size, ZeroSize, <<Acc/binary, FullRow/binary>>).

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
