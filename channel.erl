% A Channel

-module(channel).
-export([new/1, listen/1, send/2]).

new(Name) ->
    spawn_link(fun() -> channel(Name, sets:new()) end).

channel(Name, Listeners) ->
    process_flag(trap_exit, true),
    receive
        {listen, Pid} ->
            link(Pid),
            channel(Name, sets:add_element(Pid, Listeners));
        {send, Message, Pid} ->
            channel(Name, sets:filter(fun(E) ->
                            if
                                E =:= Pid -> true;
                                true -> E ! {chan, Name, Message}, true
                            end
                    end, Listeners));
        {'EXIT', Pid, _} ->
            NewListeners = sets:del_element(Pid, Listeners),
            case sets:size(NewListeners) of
                0 -> exit({empty, Name});
                _ -> channel(Name, NewListeners)
            end
    end.

listen(Channel) ->
    Channel ! {listen, self()}.

send(Channel, Message) ->
    Channel ! {send, Message, self()}.
