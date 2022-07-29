-module(profile).
-behaviour(gen_server).

%% API
-export([stop/1, start_link/1, call/1, receive_next/1, get_state/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-record(state, {name, msges = []}).

% ======================================================================================
% API
% 
% ======================================================================================
call([From, To, Msg]) ->
	gen_server:call(From, {call, [To, Msg]}).

receive_next(Name) ->
	gen_server:call(Name, receive_next).

stop(Name) ->
	gen_server:call(Name, stop).

start_link(Name) ->
	gen_server:start_link({local, Name}, ?MODULE, [Name], []).

get_state(Name) ->
	gen_server:call(Name, get_state).

% ======================================================================================
% COMEBACK
% 
% ======================================================================================
init([Name]) ->
	{ok, #state{name = Name, msges = []}}.

handle_call(stop, _From, State) ->
	{stop, normal, stopped, State};

handle_call(get_state, _From, State) ->
	{reply, State, State};

handle_call({call, [To, Msg]}, _From, State) ->
	To ! [State#state.name, Msg],
	{reply, ok, State};

handle_call(receive_next, _From, State) ->
	[H|T] = State#state.msges,
	{reply, H, State#state{msges = T}}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info([Name, Msg], State) ->
	% FIFO
	NewList = State#state.msges ++ [{Name, Msg}],
	% LIFO
	% NewList = [{Name, Msg}] ++ State#state.msges,
	{noreply, State#state{msges = NewList}};

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.