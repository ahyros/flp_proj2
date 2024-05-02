# FLP - Logical project - Hamilton cycles 

- Author - Andrej Hýroš, xhyros00
- Academic year - 2023/2024
- Assignment - Hamilton cycles

## Solution description

A Hamilton cycle is a cycle that visits every vertex in the graph exactly once and returns to the starting vertex.

### Generating facts

Program uses `edge/2` predicate to represent graphs. After input is parsed into list of vertex pairs such as: `[[a,b], [b,c], [c,a]]`,
edges are generated using `assertz/1` predicate for both directions. In given example, following facts would be generated:

```
edge(a,b).
edge(b,a).
edge(b,c).
edge(c,b).
edge(a,c).
edge(c,a).
```
Also list of all vertices is created: `Vertices = [a,b,c]`.

### Finding Hamilton cycles

So now that knowledge base knows how given graph looks like, program can start searching for cycles. 
Core of the method is predicate `path/4`:

```
path(A,B,Paths,Paths) :- edge(A,B).
path(A,B,V,Paths) :- edge(A,X),B\=X,not(member(X,V)),path(X,B,[X|V],Paths).
```

Which for given vertices A (starting vertex) and B (goal vertex), finds every possible path from A to B 
that does not contain cycles. Cycle are avoided using `V` (for Visited) variable, which stores previously
visited vertices.\
Next step is done in `everyVertexPath/3` predicate, which further restricts possible paths to only those that visited
every vertex in given graph:

```
everyVertexPath(A,P,AllVertices) :-
    path(A,A,[A],P),
    subset(AllVertices, P).
```

This predicate searches for all paths from vertex A to A (Since starting vertex is irelevant for finding Hamilton cycles,
A is chosen arbitrarily as the first vertex in `Vertices`.) and returns only those that visit every vertex (This is 
checked by asking if all known vertices `Vertices` are subset of vertices that are part of found cycle.) 

So now every possible path from A to A that visits every vertex is calculated and stored in a list. However, this list
contains 'duplicate' paths, such as `[a,b,c,a]` and it's mirror `[a,c,b,a]` (these are different paths, but same cycles). These are filtered in `uniquePaths/2`
predicate. Specifically, by predicate `noMirrors/3`:

```
noMirrors([], Out, Out).
noMirrors([H|T], Int, Out) :-
    mirror(H, [], Mirror), % creates mirror of list H
    member(Mirror,T), % checks, if mirror is present in original list
    noMirrors(T,Int,Out). % if it is, remove head from the list (it's mirror will stay in the list)
noMirrors([H|T], Int, Out) :-
    noMirrors(T, [H|Int], Out). % if it is not, keep it in the list
```

Now what is left in the list are all unique Hamilton cycles, for example `[[k, n, m, l, k], [k, m, n, l, k], [k, n, l, m, k]]`.\
Only task left is to print these three paths/cycles in specific format to the standart output, which is boring task and
will not be further described.

### Main function
This subsection shows `main/0` predicates, which is entry point of the program, to give reader
idea about general flow of the program.
```
main :-
      prompt(_, ''),
      read_lines(Lines),                           % read from standart input
      assertEdges(Lines),                          % parse edges and assert them as facts
      vertexList(Lines,[],VDuplicates),            % create list of vertex from input (includes duplicates)
      removeDuplicates(VDuplicates, [], Vertices), % remove duplicates from vertex list
      uniquePaths(Vertices, RESULT),               % returns Hamilton cycles in RESULT
      printOutput(RESULT),                         % print found cycles in corect format
      halt.
```


## Usage

1. To compile program, run `make` in project directory. This will produce `flp23-log` binary.
2. To run program, run `./flp23-log < <example_input.in>`.\
   where `<example_input.in>` is text file containing graph representation as it was described in the assignement.
3. Run `make clean` to delete binary `flp23-log`.

## Input / Output formatting
Program expects certain formatting of input. Vertices are always denoted by capital letters of english alphabet.
Individual lines (one line - one edge in graph) are formatted such as `<V1> <V2>`. Separator is space character.
File should not end with new line.  
Example with 5 edges:
```
A B
A C
A D
B C
C D
```
Output example:
```
A-B A-C A-D
A-B A-C C-D
A-B A-D B-C
A-B A-D C-D
A-B B-C C-D
A-C A-D B-C
A-C B-C C-D
A-D B-C C-D
```






## Known problems
Program is not very optimal. As an example, a star graph with 9 vertices and 36 edges,
(all vertices are connected), which has 20160 unique Hamilton cycles took 2 minutes to solve
on my local machine and 1 minute on server provided by the university (Merlin).


## Examples
Three example input/output files are located in `ex` directory. These are:
- `example1.in` - This is the input which was provided with assignement itself.
- `example2.in` - Graph with 18 edges and 48 Hamilton cycles
- `example3.in` - Star graph with 36 edges and 20160 Hamilton cycles. Note, that this example takes significant
time to compute, as mentino in 'Known problems' section.

Coresponding output files are named `exampleX.out` and are also located in `ex` directory.