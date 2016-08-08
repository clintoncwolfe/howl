%% @doc Interface for howl-admin commands.
-module(howl_console).
-export([connections/1, stats/1]).
-ignore_xref([connections/1, stats/1]).


connections(["snarl"]) ->
    io:format("Snarl endpoints.~n"),
    print_endpoints(libsnarl:servers());

connections(["sniffle"]) ->
    io:format("Sniffle endpoints.~n"),
    print_endpoints(libsniffle:servers());

connections([]) ->
    case {connections(["snarl"]),
          connections(["sniffle"])} of
        {ok, ok} ->
            ok;
        _ ->
            error
    end.

stats([]) ->
    Codes = ['5xx', '4xx', '3xx', '2xx', '1xx', other],
    io:format("HTTP Code  Count~n"),
    io:format("---------- ---------~n"),
    [print_code(Code, get_code(Code)) || Code <- Codes].



print_endpoints(Es) ->
    io:format("Hostname            "
              "                    "
              " Node               "
              " Errors    ~n"),
    io:format("--------------------"
              "----------"
              " --------------------"
              " ---------------~n", []),
    [print_endpoint(E) || E <- Es],
    case [print_endpoint(E) || E <- Es] of
        [] ->
            error;
        _ ->
            ok
    end.

get_code(Code) ->
    folsom_metrics:get_metric_value({howl, http, codes, Code}).
print_code(Code, Count) ->
    io:format("~10s ~-9b~n", [Code, Count]).
print_endpoint({{Hostname, [{port, Port}, {ip, IP}]}, _, Fails}) ->
    HostPort = <<IP/binary, ":", Port/binary>>,
    io:format("~30s ~-24s ~9b~n", [Hostname, HostPort, Fails]).
