%% Chemical Formula Balancer

:- include(chem_parser).



unique([], []).
unique([A|As], Us) :-
    unique(As, UAs),
    ( member(A, UAs) ->
        Us = UAs;
        Us = [A|UAs]
    ).

merge(L, R, M) :-
    append(L, R, A),
    unique(A, M).

chemical_elements(compound([]), []).
chemical_elements(compound([element(E)|Cs]), Es) :- 
    chemical_elements(compound(Cs), Rs),
    ( member(E, Rs) ->
        Es = Rs;
        Es = [E|Rs]
    ).
chemical_elements(compound([compound(L)|Cs]), Es) :-
    chemical_elements(compound(L), LEs),
    chemical_elements(compound(Cs), Rs),
    merge(LEs, Rs, Es).
chemical_elements(compound([number(C, _)|Cs]), Es) :-
    chemical_elements(compound([C]), L),
    chemical_elements(compound(Cs), Rs),
    merge(L, Rs, Es).

% Whether two compounds are made
% of the same elements
same_elements(A,A).
same_elements(Left, Right) :-
    chemical_elements(Left, LEs),
    chemical_elements(Right, REs),
    permutation(LEs, REs).



