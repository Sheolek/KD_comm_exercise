KD_comm_exercise
================
The application has to main modules: comm.erl and profile.erl   
- comm.erl is responsible for the server part and also works as kind of a user interface.   
- profile.erl is responsible for the client part. Each new user is a new proccess which spins in a loop until stopped.   
   
There is a main app mylib_app.erl that is responsible for the start and stop of the application.   
   
There are also 2 supperisors(mylib_supp.erl and profile_sup.erl) that restart the server/profiles if they are stopped prematurely.  

Avaiable functions:
================
mylib_app:start(_StartType, _StartArgs) -> {ok, _Pid}
-----------------------------
Argumets don't matter, starts the application,    
  
return:    
Pid - comm supervisour pid.   

mylib_app:stop(_Args) -> true
-----------------------------
Argumets don't matter, stops the whole application, propagates to lower levels.   

comm:start(Name) -> {Name, Pid} | {error, aleady_exists}
-----------------------------

creates a Profile proccess with given Name,   
  
return:  
Name - given name of the proccess  
Pid - pid of the new created proccess   
returns {error, aleady_exists} if the profile with given Name already exists  

comm:msg(From, To, Msg) -> ok | {error, no_profile}
-----------------------------

sends the Msg from user with name From to user with name To,   
  
return:   
ok - if both of the profiles exist    
{error, no_profile} - if one of them doesn't exist   

comm:receive_next(Name) -> {From, Message} | {error, no_profile}
-----------------------------

gets the next message in queue in proccess with tha given Name,   
  
return:   
From - Name of the message the message is from,   
Message - the contents of the message   
returns {error, no_profile} if the profile with given Name doesn't exist  

comm:get_state() -> {state, SuPid, Profiles}
-----------------------------

gets the current state of the comm server  
  
return:  
SuPid - pid of the profiles supervisour  
Profiles - List of all registered profiles names  

comm:get_state(Name) -> {state, Name, Messages} | {error, no_profile}
-----------------------------

gets the current state of the profile with given Name  
   
return:  
Name - Name of the profile proccess  
Messages - List of messages in the queue in the format {From, Message}  

comm:stop(Name) -> {stopped, Name}
-----------------------------

stops the child proccess with given Name if exists.   
  
return:   
Name - name of the stopped proccess   
  
  
Rebar3 commands
==============================
All commands below are to be executed while in the main project folder (default: "KD_comm_exercise") (REBAR3 REQUIRED)
-----------

Build
-----
$ rebar3 do clean, compile  


To run tests
------------
rebar3 do clean, compile, eunit --dir=test, cover --verbose  


To start the app
----------------
rebar3 shell  

