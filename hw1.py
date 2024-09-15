from collections import deque

def bfs(graph, start, goal):
    queue = [(start, [start])]
    visited = set()

    while queue:
        (city, path) = queue.pop(0)
        if city in visited:
            continue

        if city == goal:
            return path

        visited.add(city)

        for neighbor, _ in graph[city]:
            if neighbor not in visited:
                queue.append((neighbor, path + [neighbor]))

    return "No path found"

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
if __name__ == "__main__":
    print("Welcome to the Romanian Road Map Search!")
    start_city = input("Enter start city (NOTE: it's case sensitive): ")
    destination_city = input("Enter destination city (NOTE: it's case sensitive): ")

    if start_city not in road_map:
        print(f"Error: {start_city} is not in the road map.")
    elif destination_city not in road_map:
        print(f"Error: {destination_city} is not in the road map.")
    else:
        result = bfs(road_map, start_city, destination_city)
        print(f"Shortest path from {start_city} to {destination_city}: {result}")
