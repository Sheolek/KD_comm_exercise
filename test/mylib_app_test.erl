-module(mylib_app_test).
-include_lib("eunit/include/eunit.hrl").

start_test() ->
	{ok, _Pid} = mylib_app:start([],[]).

stop_test() ->
	true = mylib_app:stop([]).