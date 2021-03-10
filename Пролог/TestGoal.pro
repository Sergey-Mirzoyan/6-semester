domains
	lst = integer*. 
	
predicates	
	big(lst, integer, lst). 	% original, num, result
	odds(lst, lst). 		% original, result
	delete(lst, integer, lst).	% original, num, result	
	createSet(lst, lst). 		% original, result
	
clauses
	%1
	big([], _, []).
	big([H|T], Num, [H|RT]) :- Num < H, big(T, Num, RT), !.  
	big([_|T], Num, RT) :- big(T, Num, RT).
	
	%2
	odds([], []).
	odds([_], []).
	odds([_|[H|T]],[H|RT]) :- odds(T, RT).

	%3
	delete([], _, []).
	delete([Elem|T], Elem, RT) :- delete(T, Elem, RT), !.
	delete([H|T], Elem, [H|RT]) :- delete(T, Elem, RT).

	%4
	createSet([], []).
	createSet([H|T], [H|RT]) :- delete(T, H, Tmp), createSet(Tmp, RT).
	
goal
	%big([1, 2, 3, 4, 2, 1],5, Res).
	%odds([1, 2, 3, 4], Res).
	%delete([1, 2, 3, 3, 1, 3, 4], 3, Res).
	%createSet([1, 2, 3, 3, 1, 3, 4], Res).
	%createSet([1, 1, 1], Res).
