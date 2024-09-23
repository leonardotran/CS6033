from collections import deque
import time
import heapq
# Nem Mehta
# Loc Tran
# Orry Willems

#############       REFERENCES     ############# 

#https://github.com/aimacode/aima-python/blob/master/search.ipynb
#https://cyluun.github.io/blog/uninformed-search-algorithms-in-python
#https://www.geeksforgeeks.org/uniformed-search-algorithms-in-ai/

# Road map data
road_map = {
    'arad': [('zerind', 75), ('sibiu', 140), ('timisoara', 118)],
    'zerind': [('arad', 75), ('oradea', 71)],
    'oradea': [('zerind', 71), ('sibiu', 151)],
    'sibiu': [('arad', 140), ('oradea', 151), ('fagaras', 99), ('rimnicu vilcea', 80)],
    'timisoara': [('arad', 118), ('lugoj', 111)],
    'lugoj': [('timisoara', 111), ('mehadia', 70)],
    'mehadia': [('lugoj', 70), ('drobeta', 75)],
    'drobeta': [('mehadia', 75), ('craiova', 120)],
    'craiova': [('drobeta', 75), ('rimnicu vilcea', 146), ('pitesti', 138)],
    'rimnicu vilcea': [('sibiu', 80), ('craiova', 146), ('pitesti', 97)],
    'fagaras': [('sibiu', 99), ('bucharest', 211)],
    'pitesti': [('rimnicu vilcea', 97), ('craiova', 138), ('bucharest', 101)],
    'bucharest': [('fagaras', 211), ('pitesti', 101), ('giurgiu', 90), ('urziceni', 85)],
    'giurgiu': [('bucharest', 90)],
    'urziceni': [('bucharest', 85), ('hirsova', 98), ('vaslui', 142)],
    'hirsova': [('urziceni', 98), ('eforie', 86)],
    'eforie': [('hirsova', 86)],
    'vaslui': [('urziceni', 142), ('iasi', 92)],
    'iasi': [('vaslui', 92), ('neamt', 87)],
    'neamt': [('iasi', 87)]
}

# SLD values
sld = {
    'arad': 366, 'zerind': 374, 'oradea': 380, 'sibiu': 253, 'timisoara': 329,
    'lugoj': 244, 'mehadia': 241, 'drobeta': 242, 'craiova': 160, 'rimnicu vilcea': 193,
    'fagaras': 178, 'pitesti': 98, 'bucharest': 0, 'giurgiu': 77, 'urziceni': 80,
    'hirsova': 151, 'eforie': 161, 'vaslui': 199, 'iasi': 226, 'neamt': 234
}

#################################    BFS Algorithm       ################################
def bfs(road_map, start, goal):
    if start not in road_map or goal not in road_map:
        return None, 0, 0

    queue = deque([(start, [start], 0)])
    visited = set()
    cities_visited = 0

    while queue:
        city, path, cost = queue.popleft()
        if city in visited:
            continue
        cities_visited += 1
        visited.add(city)

        if city == goal:
            return path, cost, cities_visited  

        for neighbor, distance in road_map[city]:
            if neighbor not in visited:
                queue.append((neighbor, path + [neighbor], cost + distance))

    return None, 0, cities_visited

################################    DFS Algorithm   ################################
def dfs(graph, start, goal):
    stack = [(start, [start], 0)]
    visited = set()
    cities_visited = 0  

    while stack:
        (city, path, cost) = stack.pop()
        if city not in visited:
            visited.add(city)
            cities_visited += 1

            if city == goal:
                return path, cost, cities_visited

            for neighbor, distance in graph.get(city, []):
                stack.append((neighbor, path + [neighbor], cost + distance))

    return None, 0, cities_visited


################################    Greedy Algorithm   ################################
def greedy(graph, start, goal, heuristic_func):
    priority_queue = []
    heapq.heappush(priority_queue, (heuristic_func(start, goal, graph), start, [start]))

    visited = set()
    cities_visited = 0

    while priority_queue:
        heuristic, current_city, path = heapq.heappop(priority_queue)

        if current_city in visited:
            continue
        visited.add(current_city)
        cities_visited += 1

        if current_city == goal:
            return path, sum(graph[current_city][i][1] for i in range(len(path) - 1)), cities_visited

        neighbors = graph.get(current_city, [])
        for neighbor, _ in neighbors:
            if neighbor not in visited:
                heapq.heappush(priority_queue, (heuristic_func(neighbor, goal, graph), neighbor, path + [neighbor]))

    return None, 0, cities_visited


################################    A* Algorithm   ################################

def a_star(road_map, start, goal, heuristic_func):
    priority_queue = [(heuristic_func(start, goal, road_map), start, [start], 0)]
    visited = {}
    cities_visited = 0
    
    while priority_queue:
        f, current_city, path, g = heapq.heappop(priority_queue)
        if current_city == goal:
            return path, g, cities_visited
        
        if current_city in visited and visited[current_city] <= g:
            continue
        visited[current_city] = g
        cities_visited += 1
        
        for neighbor, distance in road_map[current_city]:
            new_g = g + distance
            h = heuristic_func(neighbor, goal, road_map)
            f = new_g + h
            if neighbor not in visited or visited[neighbor] > new_g:
                heapq.heappush(priority_queue, (f, neighbor, path + [neighbor], new_g))
    
    return None, None, cities_visited

################################    Heuristic   ################################
INF = float('inf')

def heuristic_with_bucharest(start, goal, road_map):
    heuristic_value = sld.get(start, INF)
    return heuristic_value

def heuristic_with_triangle_inequality(start, goal, road_map):
    neighbors_start = {neighbor for neighbor, _ in road_map[start]}
    neighbors_goal = {neighbor for neighbor, _ in road_map[goal]}
    
    common_neighbors = neighbors_start.intersection(neighbors_goal)
    
    if common_neighbors:
        min_common_neighbor_heuristic = min(sld.get(neighbor, INF) for neighbor in common_neighbors)
        heuristic_value = sld.get(start, INF) - min_common_neighbor_heuristic
    else:
        if neighbors_start:
            min_neighbor_heuristic = min(sld.get(neighbor, INF) for neighbor in neighbors_start)
            heuristic_value = sld.get(start, INF) - min_neighbor_heuristic
        else:
            heuristic_value = sld.get(start, INF)
    
    # print(f"Heuristic with Common Neighbor for {start}: {heuristic_value}")
    return heuristic_value

################################ GRAPHICAL USER INTERFACE FOR TERMINAL  ################################
def main_menu():
    while True:
        print("\n")
        print("\033[1;33mWelcome to Group 22 Romanian Road Map Search!\033[0m\n")

        start_city = input("\033[1;36mEnter start city: \033[0m").lower()
        destination_city = input("\033[1;36mEnter destination city: \033[0m").lower()

        if start_city not in road_map:
            print(f"\033[1;31mError: {start_city} is not in the road map.\033[0m")
            continue
        elif destination_city not in road_map:
            print(f"\033[1;31mError: {destination_city} is not in the road map.\033[0m")
            continue

        print("\033[1;36m\nSelect an algorithm:\033[0m")
        print("1. BFS")
        print("2. DFS")
        print("3. A*")
        print("4. Greedy")
        print("5. Exit")
        choice = input("\033[1;36mEnter the number of the algorithm you want to use: \033[0m")

        if choice == '1':
            algorithm_name = "BFS"
            algorithm_func = run_bfs
            heuristic_func = None  # No heuristic for BFS
        elif choice == '2':
            algorithm_name = "DFS"
            algorithm_func = run_dfs
            heuristic_func = None  # No heuristic for DFS
        elif choice == '3':
            print("\033[1;36mSelect a heuristic for A*:\033[0m")
            print("1. Heuristic with Bucharest")
            print("2. Heuristic with Common Neighbor")
            heuristic_choice = input("\033[1;36mEnter the number of the heuristic you want to use: \033[0m")

            if heuristic_choice == '1':
                heuristic_func = heuristic_with_bucharest
                heuristic_name = "Heuristic with Bucharest"
            elif heuristic_choice == '2':
                heuristic_func = heuristic_with_triangle_inequality
                heuristic_name = "Heuristic with Common Neighbor"
            else:
                print("\033[1;31mInvalid choice. Defaulting to Heuristic with Bucharest.\033[0m")
                heuristic_func = heuristic_with_bucharest
                heuristic_name = "Heuristic with Bucharest"

            algorithm_name = f"A* with {heuristic_name}"
            algorithm_func = run_a_star
        elif choice == '4':
            print("\033[1;36mSelect a heuristic for Greedy:\033[0m")
            print("1. Heuristic with Bucharest")
            print("2. Heuristic with Common Neighbor")
            heuristic_choice = input("\033[1;36mEnter the number of the heuristic you want to use: \033[0m")

            if heuristic_choice == '1':
                heuristic_func = heuristic_with_bucharest
                heuristic_name = "Heuristic with Bucharest"
            elif heuristic_choice == '2':
                heuristic_func = heuristic_with_triangle_inequality
                heuristic_name = "Heuristic with Common Neighbor"
            else:
                print("\033[1;31mInvalid choice. Defaulting to Heuristic with Bucharest.\033[0m")
                heuristic_func = heuristic_with_bucharest
                heuristic_name = "Heuristic with Bucharest"

            algorithm_name = f"Greedy with {heuristic_name}"
            algorithm_func = run_greedy
        elif choice == '5':
            print("\033[1;33mExiting...\033[0m")
            break
        else:
            print("\033[1;31mInvalid choice. Please enter a number between 1 and 5.\033[0m")
            continue

        print(f"\033[1;36mRunning {algorithm_name} algorithm...\033[0m")
        
        if algorithm_name.startswith("A*") or algorithm_name.startswith("Greedy"):
            path, cost, cities_visited = algorithm_func(start_city, destination_city, heuristic_func)
        else:
            path, cost, cities_visited = algorithm_func(start_city, destination_city)

        if path:
            print(f"\033[1;32mPath found: {' -> '.join(path)}\033[0m")
            print(f"\033[1;32mTotal cost: {cost}\033[0m")
            print(f"\033[1;32mCities visited: {cities_visited}\033[0m")
        else:
            print("\033[1;31mNo path found.\033[0m")


# Define run functions for each algorithm
def run_bfs(start, goal):
    start_time = time.time()
    result = bfs(road_map, start, goal)
    elapsed_time = time.time() - start_time
    print(f"\033[1;31mBFS execution time: {elapsed_time:.6e} seconds\033[0m")
    return result

def run_dfs(start, goal):
    start_time = time.time()
    result = dfs(road_map, start, goal)
    elapsed_time = time.time() - start_time
    print(f"\033[1;31mDFS execution time: {elapsed_time:.6e} seconds\033[0m")
    return result

def run_a_star(start, goal, heuristic_func):
    start_time = time.time()
    result = a_star(road_map, start, goal, heuristic_func)
    elapsed_time = time.time() - start_time
    print(f"\033[1;31mA* execution time: {elapsed_time:.6e} seconds\033[0m")
    return result

def run_greedy(start, goal, heuristic_func):
    start_time = time.time()  
    path, cost, cities_visited = greedy(road_map, start, goal, heuristic_func)
    end_time = time.time()  
    execution_time = end_time - start_time 
    print(f"Greedy execution time: {execution_time:.6e} seconds")  
    return path, cost, cities_visited

main_menu()