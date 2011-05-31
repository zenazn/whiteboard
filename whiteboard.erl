% Erlang Whiteboard by Carl Jackson

-module(whiteboard).
-export([start/0, stop/0]).

start() ->
    Chanserv = chanserv:new(),
    misultin:start_link(
        [
            {port, 8080},
            {loop, fun(Req) -> handle_http(Req, Chanserv) end},
            {ws_loop, fun(Ws) -> handle_ws(Ws, Chanserv) end}
        ]
    ).

stop() -> misultin:stop().

handle_http(Req, _) ->
    'GET' = Req:get(method),
    case Req:resource([lowercase, urldecode]) of
        ["whiteboard.js"] -> Req:file("whiteboard.js");
        ["style.css"] -> Req:file("style.css");
        [] -> Req:file("index.html");
        [_] -> Req:file("index.html");
        _ -> Req:file("404.html")
    end.

handle_ws(Ws, Chanserv) ->
    Name = string:to_lower(Ws:get(path)),
    Channel = chanserv:find(Chanserv, Name),
    channel:listen(Channel),
    receive
        {browser, Data} ->
            channel:send(Channel, Data),
            handle_ws(Ws, Chanserv);
        {chan, Name, Data} ->
            Ws:send(Data),
            handle_ws(Ws, Chanserv);
        _ -> handle_ws(Ws, Chanserv)
    after 30*1000 ->
            Ws:send("ping"),
            handle_ws(Ws, Chanserv)
    end.
