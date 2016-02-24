%% Main program

:- include(chem).
:- include(io).


repl :-
    repeat,
    get_line(L),
    ( L = [] ->
        !;
        equation(L, Eq, _),
        format("~w~n", [Eq]),
        fail
    ).

:- initialization(repl).
