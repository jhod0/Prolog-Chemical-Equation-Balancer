%% ==== Parsing functions ==== %%
%% Most of these are combinators

% Chains a list of parsers, giving their outputs as
% a list.
% If any parser fails, chain fails.
chain([], _, _, _) :- fail.
chain([P], In, Out, Rs) :-
    call(P, In, Out1, Rs),
    Out = [Out1].
chain([P|Ps], In, Out, Rs) :-
    call(P, In, Out1, Rs1),
    chain(Ps, Rs1, OutRs, Rs),
    Out = [Out1|OutRs].

% Like chain, but forgiving - when
% a parser fails, returns []
chain_maybe([], I, [], I).
chain_maybe([P|Ps], In, Out, Rs) :-
    call(P, In, Out1, Rs1) ->
    chain_maybe(Ps, Rs1, Outs, Rs),
    Out = [Out1|Outs];
    Out = [],
    Rs = In.

% Sequentially tries the parsers
% in a list, using the first one
% which works.
choice([], _, _, _) :- fail.
choice([P|Ps], In, Out, Rs) :-
    call(P, In, Out, Rs) ->
    true;
    choice(Ps, In, Out, Rs).

% Attempts a parse, and returns Default
% if it fails.
option(P, Default, In, Out, Rs) :-
    call(P, In, Out, Rs) ->
    true;
    Out = Default,
    Rs = In.

% Attempts a parse N times,
% fails if any parse fails.
times(0, _P, In, [], In).
times(N, P, In, Out, Rs) :-
    call(P, In, ThisOut, ThisRs),
    Next is N-1,
    times(Next, P, ThisRs, NOut, Rs),
    Out = [ThisOut|NOut].

% Some must work at least once
some(P, In, Out, Rs) :-
    call(P, In, O1, Rs1),
    many(P, Rs1, Outs, Rs),
    Out = [O1|Outs].

% Many may fail on the first try
many(P, In, Out, Rs) :-
    call(P, In, O1, Rs1) ->
    many(P, Rs1, Outs, Rs),
    Out = [O1|Outs];
    Rs = In,
    Out = [].

one(P, [I|Is], I, Is) :-
    call(P, I).

take(_P, [], [], []).
take(P, [A|As], Bs, Rs) :-
    call(P, A) ->
    take(P, As, Next, NRs),
    Bs = [A|Next],
    Rs = NRs;
    Bs = [],
    Rs = [A|As].

% Parses a list of Ps separated
% by Seps
interspersed(Sep, P, In, Out, Rs) :-
    call(P, In, V1, Rs1),
    ( call(Sep, Rs1, _Sval, Rs2) ->
        interspersed(Sep, P, Rs2, ROut, Rs),
        Out = [V1|ROut];
        Out = [V1],
        Rs = Rs1
    ).

parse_string(Ls, In, Ls, Rs) :-
    append(Ls, Rs, In).

parse_atom(A, In, Ls, Rs) :-
    atom_codes(A, Ls),
    append(Ls, Rs, In).

% Parses P surrounded at parentheses
parens(P, In, Out, Rs) :-
    chain([parse_atom('('), P, parse_atom(')')],
          In, [_, Out, _], Rs).

%% ==== Miscellaneous ==== %%
number_char_range(N, CMin, CMax) :-
    char_code(CMin, Min),
    char_code(CMax, Max),
    N =< Max,
    N >= Min.


space(32). %% Space " "
space(9).  %% Tab character

%% Reading Integers %%

digit(N) :- number_char_range(N, '0', '9').

codes_integer([], _) :- fail.
codes_integer(Cs, N) :-
    atom_codes(C, Cs),
    number_atom(N, C).

%% Parses an integer.
get_number(Ds, N, Rest) :-
    take(digit, Ds, Digs, Rs),
    ( Digs = [] ->
        fail;
        Rest = Rs,
        codes_integer(Digs, N) 
    ).

%% Letter helper functions
upper(N) :- number_char_range(N, 'A', 'Z').
lower(N) :- number_char_range(N, a, z).
