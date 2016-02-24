%% Input/Output

get_line(Line) :-
    [NL|_] = "\n",
    get_code(C),
    (   member(C, [NL, -1]) ->
        Line = [];
        get_line(Rest),
        Line = [C|Rest]
    ).
