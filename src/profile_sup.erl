-module(profile_sup).

-behaviour(supervisor).

-export([start_link/0, start_child/1, stop_child/1]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_child(Name) ->
    supervisor:start_child(?SERVER, [Name]).

stop_child(Name) ->
    Pid = whereis(Name),
    supervisor:terminate_child(?SERVER, Pid).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => 0,
                 period => 1},
    Profiles = #{id => profile, 
                start => {profile, start_link, []},
                restart => permanent,
                shutdown => 60000,
                type => worker, 
                modules => [profile]},
    Children = [Profiles],
    {ok, {SupFlags, Children}}.