% Event dispatcher

-module(chanserv).
-export([new/0, enqueue/2, listen/2, remove/2]).

new() ->
    spawn(?MODULE, dispatcher, [{dict:new(), []}]).

dispatcher(State = {Channels, Clients}) ->
    receive
        {get_channel, Name}


get_channel(Dispatch, Name) ->
    Dispatch ! {self(), get_channel, Name},
    receive
        {Dispatch, Channel} -> Channel
    end.

enqueue(Dispatch, Channel, Message) ->
    Dispatch ! {self(), get_channel, Name},
    receive
        {Dispatch, Channel} -> Channel
    end.
    true.

listen(Dispatch, Channel, Callback) ->
    handle.

remove(Dispatch, Handle) ->
    true.
