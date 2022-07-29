-module(comm).
-behaviour(gen_server).

%% API
-export([start/1, stop/1, stop/0, get_state/0, start_link/0, msg/3,receive_next/1,get_state/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-define(SERVER, ?MODULE). 
-record(state, {sup_pid, profiles}).

% ======================================================================================
% API
% 
% ======================================================================================
start(Name) ->
	gen_server:call(?SERVER, {start, Name}).

msg(From, To, MSG) ->
	gen_server:call(?SERVER, {call, [From, To, MSG]}).

receive_next(Name) ->
	gen_server:call(?SERVER, {receive_next, Name}).

get_state(Name) ->
	gen_server:call(?SERVER, {get_state, Name}).

get_state() ->
	gen_server:call(?SERVER, get_state).

stop(Name) ->
	gen_server:call(?SERVER, {stop, Name}).

stop() ->
	gen_server:call(?SERVER, stop).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

% ======================================================================================
% COMEBACK
% 
% ======================================================================================
init(_Args) ->
	{ok, Sup_Pid} = profile_sup:start_link(),
	{ok, #state{sup_pid = Sup_Pid, profiles=[]}}.

handle_call(stop, _From, State) ->
	exit(State#state.sup_pid, normal),
	{stop, normal, stopped, State};

handle_call({get_state,Name}, _From, State) ->
	Check = [X || X <- State#state.profiles, X == Name],
	case Check of
		[] ->
			{reply, {error, no_profile}, State};
		[Name] ->
			Reply = profile:get_state(Name),
			{reply, Reply, State}
	end;

handle_call(get_state, _From, State) ->
	{reply, State, State};
	
handle_call({stop, Name}, _From, State) ->
	profile_sup:stop_child(Name),
	New_list = lists:delete(Name, State#state.profiles),
	{reply, {stopped, Name}, State#state{profiles = New_list}};

handle_call({start, Name}, _From, State) ->
	Check = [X || X <- State#state.profiles, X == Name],
	case Check of
		[] ->
			{ok, Pid} = profile_sup:start_child(Name),
			NewState = State#state{profiles = [Name | State#state.profiles]},
			{reply, {Name, Pid}, NewState};
		[Name] ->
			{reply, {error, already_exists}, State}
		end;

handle_call({receive_next, Name}, _From, State) ->
	Check = [X || X <- State#state.profiles, X == Name],
	case Check of
		[Name] ->
			Reply = profile:receive_next(Name),
			{reply, Reply, State};
		_ ->
			{reply, {error, no_profile}, State}
		end;

handle_call({call, [From, To, MSG]}, _From, State) ->
	Check = [{X, Y} || X <- State#state.profiles, Y <- State#state.profiles, X == From, Y == To],
	case Check of
		[{From, To}] ->
			Result = profile:call([From, To, MSG]),
			{reply, Result, State};
		_ ->
			{reply, {error, no_profile}, State}
		end;

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.
