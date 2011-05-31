% Channel Server

-module(chanserv).
-export([new/0, chanserv/1, find/2]).

new() -> spawn_link(fun() -> chanserv(dict:new()) end).

chanserv(Channels) ->
    process_flag(trap_exit, true),
    receive
        % Channel lookup
        {get, Name, Pid} ->
            {Channel, NewChannels} = find_or_create(Channels, Name),
            Pid ! {self(), Channel},
            chanserv(NewChannels);

        % A channel became empty, so let's reap it
        {'EXIT', _, {empty, Name}} ->
            chanserv(dict:erase(Name, Channels));

        % Just ignore it
        _ -> chanserv(Channels)
    end.

find_or_create(Channels, Name) ->
    case dict:find(Name, Channels) of
        % We found an existing channel
        {ok, Channel} -> {Channel, Channels};

        % No existing channel of that name. Make one
        _ ->
            Pid = channel:new(Name),
            NewChannels = dict:store(Name, Pid, Channels),
            {Pid, NewChannels}
    end.


find(Chanserv, Name) ->
    Chanserv ! {get, Name, self()},
    receive
        {Chanserv, Channel} -> Channel
    end.

