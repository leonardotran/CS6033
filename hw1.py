from collections import deque
import time
road_map = {
    'Arad': [('Zerind', 75), ('Sibiu', 140), ('Timisoara', 118)],
    'Zerind': [('Arad', 75), ('Oradea', 71)],
    'Oradea': [('Zerind', 71), ('Sibiu', 151)],
    'Sibiu': [('Arad', 140), ('Oradea', 151), ('Fagaras', 99), ('Rimnicu Vilcea', 80)],
    'Timisoara': [('Arad', 118), ('Lugoj', 111)],
    'Lugoj': [('Timisoara', 111), ('Mehadia', 70)],
    'Mehadia': [('Lugoj', 70), ('Drobeta', 75)],
    'Drobeta': [('Mehadia', 75), ('Craiova', 120)],
    'Craiova': [('Drobeta', 120), ('Rimnicu Vilcea', 146), ('Pitesti', 138)],
    'Rimnicu Vilcea': [('Sibiu', 80), ('Craiova', 146), ('Pitesti', 97)],
    'Fagaras': [('Sibiu', 99), ('Bucharest', 211)],
    'Pitesti': [('Rimnicu Vilcea', 97), ('Craiova', 138), ('Bucharest', 101)],
    'Bucharest': [('Fagaras', 211), ('Pitesti', 101), ('Giurgiu', 90), ('Urziceni', 85)],
    'Giurgiu': [('Bucharest', 90)],
    'Urziceni': [('Bucharest', 85), ('Hirsova', 98), ('Vaslui', 142)],
    'Hirsova': [('Urziceni', 98), ('Eforie', 86)],
    'Eforie': [('Hirsova', 86)],
    'Vaslui': [('Urziceni', 142), ('Iasi', 92)],
    'Iasi': [('Vaslui', 92), ('Neamt', 87)],
    'Neamt': [('Iasi', 87)]
}

def bfs(graph, start, goal):
    queue = [(start, [start])]
    visited = set()
    cities_visited = 0  

    while queue:
        (city, path) = queue.pop(0)
        if city in visited:
            continue

        cities_visited += 1 
        if city == goal:
            return path, cities_visited 

        visited.add(city)

        for neighbor, _ in graph[city]:
            if neighbor not in visited:
                queue.append((neighbor, path + [neighbor]))

    return None, cities_visited


def dfs(graph, start, goal):
    #TODO 
    print("2. DFS (Not Implemented) ")
def a_star(graph, start, goal):
    #TODO
    print("3. A* (Not Implemented)")
def greedy(graph, start, goal):
    #TODO
    print("4. Greedy (Not Implemented)")


def main_menu():
    while True:
        print("Welcome to the Romanian Road Map Search!")

        # Get start and destination cities
        start_city = input("Enter start city (NOTE: it's case sensitive): ")
        destination_city = input("Enter destination city (NOTE: it's case sensitive): ")

        if start_city not in road_map:
            print(f"Error: {start_city} is not in the road map.")
            continue
        elif destination_city not in road_map:
            print(f"Error: {destination_city} is not in the road map.")
            continue

        # Select algorithm
        print("\nSelect an algorithm:")
        print("1. BFS")
        print("2. DFS (Not Implemented) ")
        print("3. A* (Not Implemented)")
        print("4. Greedy (Not Implemented)")
        print("5. Exit")
        choice = input("Enter the number of the algorithm you want to use: ")

        if choice == '1':
            algorithm_name = "BFS"
            algorithm_func = bfs
        elif choice == '2':
            algorithm_name = "DFS"
            algorithm_func = dfs
        elif choice == '3':
            algorithm_name = "A*"
            algorithm_func = a_star
        elif choice == '4':
            algorithm_name = "Greedy"
            algorithm_func = greedy
        elif choice == '5':
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please enter a number between 1 and 5.")
            continue

        # Run selected algorithm
        start_time = time.time()
        result, cities_visited = algorithm_func(road_map, start_city, destination_city)
        end_time = time.time()

        if result:
            print(f"{algorithm_name} - Shortest path from {start_city} to {destination_city}: {result}")
        else:
            print(f"{algorithm_name} - No path found from {start_city} to {destination_city}")

        print(f"{algorithm_name} - Number of cities visited: {cities_visited}")
        print(f"{algorithm_name} - Execution time: {end_time - start_time:.6f} seconds")

if __name__ == "__main__":
    main_menu()
