%% ==== Chemical formula analysis ==== %%
% Include the parsing utilities
:- include(parser).

%% Reads a single element
element(In, Elt, Rs) :-
    chain_maybe([one(upper), one(lower), one(lower)], 
                In, Code, Rs),
    Code \= [],
    atom_codes(Elt, Code).

%% ==== Reading Chemical Formulas ==== %%
primary(In, Out, Rs) :-
    element(In, Elt, Rs),
    Out = element(Elt).
primary(In, Out, Rs) :-
    parens(chem_compound, In, Out, Rs).

secondary(In, Out, Rs) :-
    chain_maybe([primary, get_number],
                In, Res, Rs),
    ( [P,N] = Res ->
        Out = number(P, N);
        [P] = Res,
        Out = P
    ).

chem_compound(In, Out, Rs) :-
    some(secondary, In, Secondaries, Rs),
    Out = compound(Secondaries).


%% ==== Reading Equations ==== %%
plus(In, "+", Rs) :-
    chain([take(space), parse_string("+"), take(space)],
          In, [_, "+", _], Rs).

equation(In, Out, Rs) :-
    interspersed(plus, chem_compound, In, Left, Rs1),
    chain([take(space), parse_string("->"), take(space)],
          Rs1, _, Rs2),
    interspersed(plus, chem_compound, Rs2, Right, Rs),
    Out = equation(Left,Right).
