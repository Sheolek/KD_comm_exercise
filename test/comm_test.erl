-module(comm_test).
-include_lib("eunit/include/eunit.hrl").

-define(NAME1, ala).
-define(NAME2, ola).
-define(NAME3, error).

start_test() ->
	{ok, _Pid} = comm:start_link().

start_child_test() ->
	{?NAME1, _Pid} = comm:start(?NAME1),
	?assertEqual({error, already_exists}, comm:start(?NAME1)),
	{?NAME2, _Pid2} = comm:start(?NAME2).

send_msg_test() ->
	comm:start(?NAME1),
	comm:start(?NAME2),
	ok = comm:msg(?NAME1, ?NAME2, "wiadomosc"),	
	{error, no_profile} = comm:msg(?NAME3, ?NAME2, "wiadomosc").

get_child_state_test() ->
	{state, ?NAME1, []} = comm:get_state(?NAME1),
	{error, no_profile} = comm:get_state(?NAME3).

receive_next_test() ->
	{?NAME1, "wiadomosc"} = comm:receive_next(?NAME2),
	{error, no_profile} = comm:receive_next(?NAME3).


get_state_test() ->
	{state, _SuPid, _Profiles} = comm:get_state().

stop_child_test() ->
	{stopped, ?NAME1} = comm:stop(?NAME1).

cast_test() ->
	gen_server:cast(comm, request).

call_test() ->
	ok = gen_server:call(comm, empty_call).

info_test() ->
	comm ! info.

stop_test() ->
	stopped = comm:stop().