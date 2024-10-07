% Generates a list of N random integers between 0 and 99.
randomList(0, []).
randomList(N, [X|T]):-
 N > 0,
 random(0, 100, X), % Generate a random integer X between 0 and 99.
 Y is N - 1, % Decrease N by 1 to move towards the base case.
 randomList(Y, T). % Recursively call randomList to generate the rest of the list.
% Directive to create a dynamic predicate for lists.
:- dynamic list/1.
% Directive to generate a list of 50 random integers and assert it as a fact in the database.
:- randomList(50, L), assertz(list(L)).

%%%%%%%%%%%%%%%%%%%%%% START OF BUBBLE SORT %%%%%%%%%%%%%%%%%%%%%%

/*  Swaps the first two elements if they are not in order.
  [X, Y | T] represents the head of the list being compared and the tail T.
  If Y < X, they are swapped.*/

swap([X, Y | T], [Y, X | T]) :- Y < X.

/* (recursive case): Recursively processes the list, keeping the first element (H) 
   and attempting to swap elements in the tail.*/

swap([H | T], [H | T1]) :-
    swap(T, T1).

/* bubbleSort: Sorts a list L using the bubble sort algorithm.
 It applies the swap operation to the list. If a swap occurs, the cut (!) prevents 
 backtracking and bubbleSort is called again recursively to further sort the list.*/

bubbleSort(L, SL) :-
    swap(L, L1), % If a swap is made, recursively call bubbleSort on L1.
    !,           % Cut: Prevents further backtracking once a swap has occurred.
    bubbleSort(L1, SL).
bubbleSort(L, L). % Base case: If no swaps can be made, the list is sorted.

%%%%%%%%%%%%%%%%%%%%%% END OF BUBBLE SORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% START OF INSERTION SORT %%%%%%%%%%%%%%%%%%%%%%

/* ordered: Predicate to check if a list is ordered. 
 Base cases: An empty list or a list with one element is always ordered.
 */
ordered([]).
ordered([_X]). % A list with one element is ordered.

/*(recursive case): Recursively checks if the list is sorted.
   Compares the first two elements H1 and H2, and if H1 =< H2, 
   continues checking the rest of the list.
 */
ordered([H1, H2 | T]) :-
    H1 =< H2,
    ordered([H2 | T]).

/* lessThanOrEqual: Helper predicate to compare two numbers, A and B.
   True if A is less than or equal to B.*/

lessThanOrEqual(A, B) :- A =< B.

/* insert: Inserts an element X into its correct position in a sorted list.
   Base case: Inserting into an empty list simply returns a list with the element.*/

insert(X, [], [X]).

/* insert (recursive cases): 
   Case 1: If E is less than or equal to the head of the list (H), place E before H.
   Case 2: Recursively process the tail to insert E in the correct place.*/

insert(E, [H | T], [E, H | T]) :-
    ordered(T),         % Ensure the rest of the list is ordered.
    lessThanOrEqual(E, H),
    !.                  % Cut: Ensure this clause is used if the condition is met.

insert(E, [H | T], [H | T1]) :-
    ordered(T),         % Ensure the rest of the list is ordered.
    insert(E, T, T1).   % Recursively insert E into the tail of the list.

/* insertionSort: Sorts a list using the insertion sort algorithm.
   Base case: An empty list is already sorted.*/

insertionSort([], []).

/* insertionSort/2 (recursive case): Sorts the tail of the list and inserts the head 
 * element (H) into its correct position in the sorted tail (T1).*/

insertionSort([H | T], SORTED) :-
    insertionSort(T, T1),
    insert(H, T1, SORTED).

%%%%%%%%%%%%%%%%%%%%%% END OF INSERTION SORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% START OF MERGE SORT %%%%%%%%%%%%%%%%%%%%%%
/* mergeSort: Sorts a list using the merge sort algorithm.
  Base cases: An empty list or a single-element list is already sorted.*/

mergeSort([], []).
mergeSort([X], [X]).

/* mergeSort (recursive case): Splits the list into two halves, recursively sorts 
  both halves, and then merges the sorted halves back together.*/

mergeSort(L, SL) :-
    split_in_half(L, L1, L2),
    mergeSort(L1, S1),
    mergeSort(L2, S2),
    merge(S1, S2, SL).

/* split_in_half: Splits a list into two approximately equal parts.
  Base cases: An empty list is split into two empty lists, 
  and a single-element list is split into an empty list and a list with the element.*/
intDiv(N,N1, R):- R is div(N,N1).
split_in_half([], _, _):- fail.
split_in_half([X],[],[X]).
split_in_half(L, L1, L2):-
	length(L, N),              % Calculate the length of the list.
    intDiv(N, 2, N1),          % Integer division to get the size of the first half (N1).
    length(L1, N1),            % Ensure that the first list (L1) has N1 elements.
    append(L1, L2, L).         % Combine the two lists (L1 and L2) to form the original list (L).


/* Base Case 1: If the first list is empty, the merged result is just the second list. */
merge([], L, L).

/* Base Case 2: If the second list is empty, the merged result is just the first list. */
merge(L, [], L).

/* merge (recursive cases):
  Case 1: If H1 (head of first list) is less than or equal to H2 (head of second list), 
  H1 is placed first, and merge continues with the rest of the lists.
  Case 2: Otherwise, H2 is placed first, and merge continues similarly.*/

merge([H1 | T1], [H2 | T2], [H1 | T]) :- H1 =< H2, merge(T1, [H2 | T2], T).
merge([H1 | T1], [H2 | T2], [H2 | T]) :- H2 < H1, merge([H1 | T1], T2, T).



%%%%%%%%%%%%%%%%%%%%%% END OF MERGE SORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% START OF QUICK SORT %%%%%%%%%%%%%%%%%%%%%%

/* split: Splits a list into two sublists: one with elements smaller than or 
  equal to the pivot (SMALL) and the other with elements larger than the pivot (BIG).
  Base case: An empty list results in two empty sublists.*/
split(_, [], [], []).

/* split(recursive cases): 
  Case 1: If the head (H) is smaller than or equal to the pivot (X), 
  add it to the SMALL list and continue splitting the tail.
  Case 2: If the head (H) is larger, add it to the BIG list.*/
split(X, [H | T], [H | SMALL], BIG) :- H =< X, split(X, T, SMALL, BIG).
split(X, [H | T], SMALL, [H | BIG]) :- X =< H, split(X, T, SMALL, BIG).

/* quickSort: Sorts a list using the quick sort algorithm.
   Base case: An empty list is already sorted.*/
quickSort([], []).

/* quickSort(recursive case): 
  Picks the first element (H) as the pivot, splits the remaining elements into 
  SMALL and BIG lists, recursively sorts both lists, and appends the sorted SMALL list, 
  pivot (H), and sorted BIG list.*/

quickSort([H | T], SL) :-
    split(H, T, SMALL, BIG),
    quickSort(SMALL, S),
    quickSort(BIG, B),
    append(S, [H | B], SL).

%%%%%%%%%%%%%%%%%%%%%% END OF QUICK SORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% START OF HYBRID SORT %%%%%%%%%%%%%%%%%%%%%%

% Hybrid sorting algorithm that switches between small and large sorting algorithms based on list size.

/* hybridSort: A hybrid sorting algorithm that switches between a "small" and a "big" sort
  based on the size of the list and a given threshold.
  Case 1: If the list length (N) is less than or equal to the threshold, it calls the
  "small" sorting algorithm (SmallSort) to sort the list.*/

hybridSort(LIST, SmallSort, _BigSort, Threshold, SLIST) :-
    length(LIST, N),              % Get the length of the list.
    N =< Threshold,               % Check if the list is small enough for SmallSort.
    call(SmallSort, LIST, SLIST). % Call the small sorting algorithm to sort the list.

/* hybridSort: 
  Case 2: If the list length (N) is greater than the threshold, it uses a "big" sorting 
  algorithm (BigSort) which divides the list into two parts, recursively applies 
  hybridSort on both parts, and then merges the sorted parts.*/

hybridSort(LIST, SmallSort, BigSort, Threshold, SLIST) :-
    length(LIST, N),              % Get the length of the list.
    N > Threshold,                % Check if the list is large enough for BigSort.
    split_in_half(LIST, L1, L2),  % Split the list into two approximately equal halves.
    hybridSort(L1, SmallSort, BigSort, Threshold, S1), % Recursively sort the first half.
    hybridSort(L2, SmallSort, BigSort, Threshold, S2), % Recursively sort the second half.
    merge(S1, S2, SLIST).         % Merge the two sorted halves together.

% Times the execution of a sorting algorithm.

/* time_sorting: Measures the execution time of a sorting algorithm and prints the result.
  It uses the built-in `statistics` to track the time before and after the sorting.
  The `call` predicate is used to invoke the sorting algorithm dynamically.*/
time_sorting(LIST, SortPredicate, SortedList) :-
    statistics(walltime, [_ | [_]]),             % Start the timer by ignoring the first time value.
    call(SortPredicate, LIST, SortedList),       % Call the specified sorting algorithm.
    statistics(walltime, [_ | [ExecutionTime]]), % Capture the time after sorting.
    format('Timing ~w: Sorting took ~d ms.~n', [SortPredicate, ExecutionTime]), % Print the execution time.
    format('Sorted list: ~w~n', [SortedList]).  % Print the sorted list.

% Times the execution of a hybrid sorting algorithm.

/* time_hybrid_sort: Measures the execution time of the hybrid sorting algorithm.
  Similar to `time_sorting/3`, it uses `statistics/2` to capture the execution time
  and prints the result after sorting.*/

time_hybrid_sort(LIST, SmallSort, BigSort, Threshold, SLIST) :-
    hybridSort(LIST, SmallSort, BigSort, Threshold, SLIST), % Call the hybrid sorting algorithm.
    statistics(walltime, [_ | [ExecutionTime]]),            % Capture the time after sorting.
    format('Timing Hybrid Sort (~w, ~w): Hybrid sorting took ~d ms.~n', 
           [SmallSort, BigSort, ExecutionTime]),             % Print the execution time for hybrid sort.
    format('Sorted list: ~w~n', [SLIST]).                   % Print the sorted list.

% Times all basic sorting algorithms with a given list.

/* time_all_sorts_algorithm_lowThreshold: Compares the performance of different sorting algorithms 
   with a low threshold value for the hybrid sort. It prints the execution times for each algorithm.*/

time_all_sorts_algoritm_lowThreshold(LIST, T, SLIST) :-
    write('--------------------------------------------------------'), nl,
    write('Non Hybrid Sorting Algo'), nl, 
    write('--------------------------------------------------------'), nl,

    % Measure the runtime of individual sorting algorithms.
    write('Bubble Sort Runtime: '), 
    time_sorting(LIST, bubbleSort, SLIST), nl,
    
    write('Insertion Sort Runtime: '), 
    time_sorting(LIST, insertionSort, SLIST), nl,
    
    write('Merge Sort Runtime: '), 
    time_sorting(LIST, mergeSort, SLIST), nl,
    
    write('Quick Sort Runtime: '), 
    time_sorting(LIST, quickSort, SLIST), nl,

    write('--------------------------------------------------------'), nl,
    write('Testing with LOW Threshold value'), nl,
    write('--------------------------------------------------------'), nl,

    % Measure the runtime of hybrid sorting with different combinations of small and big sorts.
    write('Hybrid Sort 1 Runtime: '), 
    time_hybrid_sort(LIST, bubbleSort, mergeSort, T, SLIST), nl,

    write('Hybrid Sort 2 Runtime: '), 
    time_hybrid_sort(LIST, bubbleSort, quickSort, T, SLIST), nl,

    write('Hybrid Sort 3 Runtime: '), 
    time_hybrid_sort(LIST, insertionSort, mergeSort, T, SLIST), nl,

    write('Hybrid Sort 4 Runtime: '), 
    time_hybrid_sort(LIST, insertionSort, quickSort, T, SLIST), nl.

% Times all hybrid sorting algorithms with a high threshold.

/* time_all_sorts_algorithm_highThreshold: Similar to the low threshold function, 
   this compares the hybrid sorting algorithms but with a high threshold value.*/

time_all_sorts_algoritm_highThreshold(LIST, T, SLIST) :-
    write('--------------------------------------------------------'), nl,
    write('Testing with HIGH Threshold value'), nl,
    write('--------------------------------------------------------'), nl,

    % Measure the runtime of hybrid sorting with different combinations of small and big sorts.
    write('Hybrid Sort 1 Runtime: '), 
    time_hybrid_sort(LIST, bubbleSort, mergeSort, T, SLIST), nl,

    write('Hybrid Sort 2 Runtime: '), 
    time_hybrid_sort(LIST, bubbleSort, quickSort, T, SLIST), nl,

    write('Hybrid Sort 3 Runtime: '), 
    time_hybrid_sort(LIST, insertionSort, mergeSort, T, SLIST), nl,

    write('Hybrid Sort 4 Runtime: '), 
    time_hybrid_sort(LIST, insertionSort, quickSort, T, SLIST), nl.


%Script to run code: randomList(50, LIST), time_all_sorts_algoritm_lowThreshold(LIST, 5, SortedList), 
%time_all_sorts_algoritm_highThreshold(LIST, 55, SortedList).

