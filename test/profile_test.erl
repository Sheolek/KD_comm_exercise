-module(profile_test).
-include_lib("eunit/include/eunit.hrl").

-define(NAME1, ala).
-define(NAME2, ola).
% -define(NAME3, error).

start_test() ->
	profile:start_link(?NAME1),
	profile:start_link(?NAME2).

default_info_test() ->
	?NAME1 ! wiadom.

default_cast_test() ->
	gen_server:cast(?NAME1, wiadom).

send_msg_test() ->
	profile:call([?NAME1, ?NAME2, "wiadom"]),
	{?NAME1, "wiadom"} = profile:receive_next(?NAME2).

get_state_test() ->
	{state, ?NAME1, []} = profile:get_state(?NAME1).

stop_test() ->
	stopped = profile:stop(?NAME1),
	stopped = profile:stop(?NAME2).