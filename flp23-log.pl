/* 
 * @file flp_log.pl
 * @author Andrej Hýroš, <xhyros00@stud.fit.vutbr.cz>
 * @date 19th of April, 2024
 * @description This Prolog program implements algorithm to find every Hamilton cycle in
 * a given graph. Hamilton cycle is a cycle that visits every vertex in the
 * graph exactly once and returns to the starting vertex. The program provides
 * predicates to represent graphs, check for Hamilton cycles, and enumerate
 * all Hamilton cycles in a graph.
 * 
 * This program was done for an assignment for course Funcional and Logical Programming at
 * Brno University of Technology, Faculty of Information Technologies.
 */


:- dynamic edge/2.

% Following three predicates are taken from input2.pl file, which was included in the assignment.

% Read lines from input
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L).

% Checks, if character if EOF or EOL
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).

% Reade lines from input
read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).


%%% ===================================================
%	MAIN
%%% ===================================================

% this predicate main/0 acts as main function. It reads and parses input, 
% feeds it to the algorithm, and prints results.
main :-
		prompt(_, ''),
		read_lines(Lines),
		assertEdges(Lines),
		vertexList(Lines,[],VDuplicates),
		removeDuplicates(VDuplicates, [], Vertices),
		uniquePaths(Vertices, RESULT),
		printCycles(RESULT),
		halt.


%%% ===================================================
%	INPUT/OUTPUT LOGIC
%%% ===================================================

% Generates facts to the knowledge base
% Example: assertEdges([[a,,b] , [b,,c] , [c,,d]]) would assert: edge(a,b),edge(b,a),edge(b,c),edge(c,b),edge(c,d),edge(d,c)
% assertEdges(+List)
assertEdges([]).
assertEdges([[V1,_,V2|_]|T]) :-
    assertz(edge(V1, V2)), % create edges in both directions
    assertz(edge(V2, V1)),
	assertEdges(T).


% Saves every vertex from input to list. This list would include duplicates.
% Example: vertexList([[a,,b] , [b,,c] , [c,,d]]) would return [a,b,b,c,c,d]
% vertexList(+InputList, ?Intermediary, -Result)
vertexList([], Out, Out).
vertexList([[V1,_,V2|_]|In], Int, Out) :-
    vertexList(In, [V1,V2|Int], Out).


% Removes duplicates from list
% removeDuplicates(+List, ?Intermediary, -ResultList)
removeDuplicates([], Out, Out).
removeDuplicates([H|T], Int, Out) :-
    member(H,Int), % head exists in Intermediary list
    removeDuplicates(T,Int,Out).
removeDuplicates([H|T], Int, Out) :- % head does not exists in intm. list
    removeDuplicates(T, [H|Int], Out). % append it to intermediary


% Prints lines (list of list of characters) to output
% printHamiltonCycles(+List)
printCycles([]).
printCycles([H|T]) :-
    printCycle(H),
    write('\n'),
    printCycles(T).


% Prints list in specific way on output
% Example: printCycle([a,b,c,d,e]) would print 'a-b b-c c-d d-e '
% printCycle(+List)
printCycle([]).
printCycle([_|[]]).
printCycle([V1,V2|T]) :-
    write(V1-V2), % print verices in format `V1-V2`
    printSeparator([V1,V2|T], ' '), % ensures, that there is no trailing space at the end of the line
    printCycle([V2|T]).

% Prints separator only if there are more (or less, but that never utilized) then three two items in a list
% printSeparator(+List, +Separator)
printSeparator([_,_|[]], _).
printSeparator(_,S) :-
    write(S).


%%% ===================================================
%	GRAPH LOGIC
%%% ===================================================

% Checks if Item is present in List
% member(+Item, +List)
member(X,[X|_]).
member(X,[_|T])  :-  member(X,T).


% Checks, if ListA is subset of ListB
% subset(+ListA, +ListB)
subset([],_).
subset([H|T],L) :- member(H,L),subset(T,L).

% Not operator
% not(+Term)
not(P) :- P,!,fail;true.


% Creates all possible paths from vertex A to B, without visiting vertices V.
% path(+VertexA, +VertexB, +Visited, -Paths)
path(A,B,Paths,Paths) :- edge(A,B).
path(A,B,V,Paths) :- edge(A,X),B\=X,not(member(X,V)),path(X,B,[X|V],Paths).


% Returns all possible paths from vertex A to A that visit every vertex once
% everyVertexPath(+VertexA, ?Paths, +AllVertices)
everyVertexPath(A,P,AllVertices) :-
    path(A,A,[A],P),
    subset(AllVertices, P).


% Returns all hamilton cycles as a list [[startNode, ... , endNode = startNode], ...]
% uniquePaths(+AllVertices, -Result)
uniquePaths([V1|Vertices], Result) :- 
    findall(P,everyVertexPath(V1, P, [V1|Vertices]), Paths),
    prepend(Paths, V1, [], Prepended), % starting vertex omitted in returned path, so it must be prepended manually
    noMirrors(Prepended, [], Result).


% Constructs mirrored list (palindrome)
% mirror(+List, ?Intermediary, -Result)
mirror([],Out,Out).
mirror([H|T],Int,Out) :- mirror(T,[H|Int],Out).


% Prepends element to each list in list of lists
% prepend(+List, +Element, ?Intermediary, -Result)
prepend([], _, Out, Out).
prepend([H|In], Char, Int, Out) :-
    prepend(In, Char, [[Char|H]|Int], Out).


% Returs those items from list, whose mirror also is in that list
% noMirrors(+List, ?Intermediary, -Result)
noMirrors([], Out, Out).
noMirrors([H|T], Int, Out) :-
    mirror(H, [], Mirror), % creates mirror of list H
    member(Mirror,T), % checks, if mirror is present in original list
    noMirrors(T,Int,Out). % if it is, remove head from the list (it's mirror will stay in the list)
noMirrors([H|T], Int, Out) :-
    noMirrors(T, [H|Int], Out). % if it is not, keep it in the list