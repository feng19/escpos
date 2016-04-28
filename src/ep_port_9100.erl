%%%-------------------------------------------------------------------
%%% @author pwf
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ep_port_9100).
-author("pwf").

-behaviour(gen_server).

-export([
    test/0,
    test_qrcode/0
]).
-export([
    send/1,
    start_link/2
]).

-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-define(SERVER, ?MODULE).

-record(state, {socket}).

test() ->
    start_link("192.168.1.249",9100).

test_qrcode() ->
    send(ep_esc_command:qrcode(<<"www.baidu.com">>)).
%%    send(ep_esc_command:addSelectErrorCorrectionLevelForQRCode(48)),
%%    send(ep_esc_command:addSelectSizeOfModuleForQRCode(3)),
%%    send(ep_esc_command:addStoreQRCodeData(iconv:convert(<<"utf8">>,<<"gbk">>,<<"www.baidu.com">>))),
%%    send(ep_esc_command:addPrintQRCode()).

send(Binary) ->
    gen_server:cast(?SERVER, Binary).

start_link(IP, Port) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [IP, Port], []).

init([IP, Port]) ->
    {ok, Socket} = gen_tcp:connect(IP, Port, [binary, {packet, 0}]),
    {ok, #state{socket = Socket}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(Binary, State) ->
    io:format("~p~n",[Binary]),
    gen_tcp:send(State#state.socket, Binary),
    {noreply, State}.

handle_info({tcp, _Socket, Data}, State) ->
    io:format("~p~n",[Data]),
    {noreply, State};
handle_info(_Info, State) ->
    io:format("~p~n",[_Info]),
    {stop, normal, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
