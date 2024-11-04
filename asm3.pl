% Define roads and distances (road(Start, End, Cost))
road(arad, zerind, 75).
road(arad, sibiu, 140).
road(arad, timisoara, 118).
road(zerind, arad, 75).
road(zerind, oradea, 71).
road(oradea, zerind, 71).
road(oradea, sibiu, 151).
road(sibiu, arad, 140).
road(sibiu, oradea, 151).
road(sibiu, fagaras, 99).
road(sibiu, rimnicu_vilcea, 80).
road(timisoara, arad, 118).
road(timisoara, lugoj, 111).
road(lugoj, timisoara, 111).
road(lugoj, mehadia, 70).
road(mehadia, lugoj, 70).
road(mehadia, drobeta, 75).
road(drobeta, mehadia, 75).
road(drobeta, craiova, 120).
road(craiova, drobeta, 120).
road(craiova, rimnicu_vilcea, 146).
road(craiova, pitesti, 138).
road(rimnicu_vilcea, sibiu, 80).
road(rimnicu_vilcea, craiova, 146).
road(rimnicu_vilcea, pitesti, 97).
road(fagaras, sibiu, 99).
road(fagaras, bucharest, 211).
road(pitesti, rimnicu_vilcea, 97).
road(pitesti, craiova, 138).
road(pitesti, bucharest, 101).
road(bucharest, fagaras, 211).
road(bucharest, pitesti, 101).
road(bucharest, giurgiu, 90).
road(bucharest, urziceni, 85).
road(giurgiu, bucharest, 90).
road(urziceni, bucharest, 85).
road(urziceni, hirsova, 98).
road(urziceni, vaslui, 142).
road(hirsova, urziceni, 98).
road(hirsova, eforie, 86).
road(eforie, hirsova, 86).
road(vaslui, urziceni, 142).
road(vaslui, iasi, 92).
road(iasi, vaslui, 92).
road(iasi, neamt, 87).
road(neamt, iasi, 87).

% Define straight-line distances (SLD) to Bucharest
sld(arad, 366).
sld(zerind, 374).
sld(oradea, 380).
sld(sibiu, 253).
sld(timisoara, 329).
sld(lugoj, 244).
sld(mehadia, 241).
sld(drobeta, 242).
sld(craiova, 160).
sld(rimnicu_vilcea, 193).
sld(fagaras, 178).
sld(pitesti, 98).
sld(bucharest, 0).
sld(giurgiu, 77).
sld(urziceni, 80).
sld(hirsova, 151).
sld(eforie, 161).
sld(vaslui, 199).
sld(iasi, 226).
sld(neamt, 234).

% Configuration
:- dynamic max_visits/1.  % Declare dynamic predicate for visit limit configuration
max_visits(50).           % Set default maximum number of cities that can be visited

% Utility predicates for better performance
% Check if the move from the Current city to Next city is valid and returns the associated cost
valid_move(Current, Next, Cost) :-
    road(Current, Next, Cost),  % Check if there's a road between Current and Next
    \+ blacklisted(Next).        % Ensure the Next city is not blacklisted

blacklisted(_) :- fail.  % No cities are blacklisted by default; this predicate always fails

% Update the path cost and create a new path when moving to the next city
update_path_cost(Path, Cost, NextCity, StepCost, NewPath, NewCost) :-
    NewCost is Cost + StepCost,  % Calculate new total cost
    NewPath = [NextCity|Path].     % Create new path by adding the Next city

% Common helper for path validation
% Validate the generated path, ensuring it does not exceed limits
validate_path(Path, Cost, CitiesVisited, Max) :-
    length(Path, Len),            % Get the length of the path
    Len =< Max,                   % Check path length against maximum allowed
    CitiesVisited =< Max,         % Check number of cities visited
    Cost >= 0.                   % Ensure cost is non-negative

% Optimized BFS with early termination and better memory management
% Main BFS predicate that starts the search
bfs(Start, Goal, Path, Cost, CitiesVisited) :-
    max_visits(Max),  % Retrieve the maximum visit limit
    bfs_search([node(Start, [Start], 0)], Goal, [], Path, Cost, CitiesVisited, Max).

% Handle goal node detection in BFS
bfs_search([node(Goal, Path, Cost)|_], Goal, _, FinalPath, Cost, 1, _) :-
    reverse(Path, FinalPath).  % Reverse the path to present it correctly

% Continue BFS search for nodes
bfs_search([node(Current, Path, Cost)|Queue], Goal, Visited, FinalPath, FinalCost, CitiesVisited, Max) :-
    length(Visited, VisitedCount),  % Count visited cities
    VisitedCount < Max,              % Ensure we haven't exceeded the visit limit
    findall(
        node(Next, [Next|Path], NewCost),  % Generate all valid next nodes
        (valid_move(Current, Next, StepCost),  % Check if the move is valid
         \+ member(Next, Visited),  % Ensure the next city has not been visited
         NewCost is Cost + StepCost),  % Calculate the new cost
        Children  % Store valid moves
    ),
    append(Queue, Children, NewQueue),  % Add new nodes to the BFS queue
    bfs_search(NewQueue, Goal, [Current|Visited], FinalPath, FinalCost, CitiesVisited1, Max),  % Continue search
    CitiesVisited is CitiesVisited1 + 1.  % Increment visited city count

% Optimized DFS with cycle detection and depth limiting
% Main DFS predicate that starts the search
dfs(Start, Goal, Path, Cost, CitiesVisited) :-
    max_visits(Max),  % Retrieve the maximum visit limit
    MaxDepth = 20,    % Set a reasonable depth limit for the search
    dfs_search([node(Start, [Start], 0, 1)], Goal, [], Path, Cost, CitiesVisited, Max, MaxDepth).

% Handle goal node detection in DFS
dfs_search([node(Goal, Path, Cost, _)|_], Goal, _, FinalPath, Cost, 1, _, _) :-
    reverse(Path, FinalPath).  % Reverse the path to present it correctly

% Continue DFS search for nodes
dfs_search([node(Current, Path, Cost, Depth)|Stack], Goal, Visited, FinalPath, FinalCost, CitiesVisited, Max, MaxDepth) :-
    length(Visited, VisitedCount),  % Count visited cities
    VisitedCount < Max,              % Ensure we haven't exceeded the visit limit
    Depth < MaxDepth,                % Ensure we haven't exceeded the depth limit
    NextDepth is Depth + 1,          % Increment the depth for the next node
    findall(
        node(Next, [Next|Path], NewCost, NextDepth),  % Generate all valid next nodes
        (valid_move(Current, Next, StepCost),  % Check if the move is valid
         \+ member(Next, Visited),  % Ensure the next city has not been visited
         NewCost is Cost + StepCost),  % Calculate the new cost
        Children  % Store valid moves
    ),
    append(Children, Stack, NewStack),  % Add new nodes to the DFS stack
    dfs_search(NewStack, Goal, [Current|Visited], FinalPath, FinalCost, CitiesVisited1, Max, MaxDepth),  % Continue search
    CitiesVisited is CitiesVisited1 + 1.  % Increment visited city count

% Optimized A* with improved heuristic calculations and priority queue
% Main A* predicate that starts the search
a_star(Start, Goal, Path, Cost, CitiesVisited) :-
    max_visits(Max),  % Retrieve the maximum visit limit
    sld(Start, H0),   % Get initial heuristic for the starting city
    a_star_search([node(H0, Start, [Start], 0)], Goal, [], Path, Cost, CitiesVisited, Max).

% Handle goal node detection in A*
a_star_search([node(_, Goal, Path, Cost)|_], Goal, _, FinalPath, Cost, 1, _) :-
    reverse(Path, FinalPath).  % Reverse the path to present it correctly

% Continue A* search for nodes
a_star_search([node(_, Current, Path, G)|Queue], Goal, Visited, FinalPath, FinalCost, CitiesVisited, Max) :-
    length(Visited, VisitedCount),  % Count visited cities
    VisitedCount < Max,              % Ensure we haven't exceeded the visit limit
    findall(
        node(F, Next, [Next|Path], NewG),  % Generate all valid next nodes
        (valid_move(Current, Next, StepCost),  % Check if the move is valid
         \+ member(Next, Visited),  % Ensure the next city has not been visited
         NewG is G + StepCost,  % Calculate the new cost from start
         sld(Next, H),  % Get heuristic for the Next city
         F is NewG + H),  % Calculate the total estimated cost (F)
        Children  % Store valid moves
    ),
    append(Queue, Children, UnsortedQueue),  % Add new nodes to the A* queue
    sort(1, @=<, UnsortedQueue, SortedQueue),  % Sort by F-value (first argument)
    a_star_search(SortedQueue, Goal, [Current|Visited], FinalPath, FinalCost, CitiesVisited1, Max),  % Continue search
    CitiesVisited is CitiesVisited1 + 1.  % Increment visited city count

% Improved test predicate with better formatting and timing
% Perform tests for the algorithms and print results
test_paths :-
    format('~n=== Performance Testing of Search Algorithms ===~n~n'),
    test_algorithm(bfs, 'BFS'),  % Test BFS
    test_algorithm(dfs, 'DFS'),  % Test DFS
    test_algorithm(a_star, 'A*').  % Test A*

% Helper predicate to test a specific algorithm and print results
test_algorithm(Algorithm, Name) :-
    format('~w Results:~n', [Name]),
    format('~`=t~60|~n'),  % Formatting line
    test_city(Algorithm, oradea),    % Test from Oradea to Bucharest
    test_city(Algorithm, timisoara),  % Test from Timisoara to Bucharest
    test_city(Algorithm, neamt),      % Test from Neamt to Bucharest
    format('~`=t~60|~n~n').  % Formatting line

% Helper predicate to test the city for a specific algorithm
test_city(Algorithm, City) :-
    get_time(Start),  % Record the start time
    call(Algorithm, City, bucharest, Path, Cost, Cities),  % Call the algorithm
    get_time(End),  % Record the end time
    Time is (End - Start) * 1000,  % Calculate the execution time in milliseconds
    format('From ~w:~n', [City]),
    format('Path: ~w~n', [Path]),  % Print the found path
    format('Cost: ~w~n', [Cost]),  % Print the total cost
    format('Cities visited: ~w~n', [Cities]),  % Print the number of cities visited
    format('Time: ~2f ms~n~n', [Time]).  % Print the execution time

% Helper predicate to analyze algorithm performance
% Collect performance data for each algorithm
analyze_performance(Start, Goal) :-
    findall(
        stats(Algo, Path, Cost, Cities, Time),
        (member(Algo-Name, [bfs-'BFS', dfs-'DFS', a_star-'A*']),  % List of algorithms
         get_time(T1),  % Start timing
         call(Algo, Start, Goal, Path, Cost, Cities),  % Run the algorithm
         get_time(T2),  % End timing
         Time is (T2 - T1) * 1000),  % Calculate elapsed time
        Results),
    format('Performance Analysis:~n'),
    format('~`=t~60|~n'),
    print_results(Results).  % Print all results in a formatted way

% Helper to print results
print_results([]).
print_results([stats(Algo, Path, Cost, Cities, Time)|Rest]) :-
    format('Algorithm: ~w~n', [Algo]),
    format('Path: ~w~n', [Path]),
    format('Cost: ~w~n', [Cost]),
    format('Cities visited: ~w~n', [Cities]),
    format('Time: ~2f ms~n', [Time]),
    format('~`=t~60|~n'),
    print_results(Rest).  % Recursive call to print the next result

