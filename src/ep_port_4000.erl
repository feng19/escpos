%%%-------------------------------------------------------------------
%%% @author pwf
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ep_port_4000).
-author("pwf").

-behaviour(gen_server).

-export([
    test/0,
    get_status/0,
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
    start_link("192.168.1.249",4000).

get_status() ->
    gen_server:cast(?SERVER, get_status).

start_link(IP, Port) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [IP, Port], []).

init([IP, Port]) ->
    {ok, Socket} = gen_tcp:connect(IP, Port, [binary, {packet, 0}]),

    {ok, #state{socket = Socket}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(get_status, State) ->
    gen_tcp:send(State#state.socket, <<16#1B,16#76>>),
    {noreply, State};
handle_cast(_Request, State) ->
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
