import matplotlib.pyplot as plt
import random
from networkx.readwrite.json_graph import tree
import numpy as np
import networkx as nx
from numpy.core.overrides import verify_matching_signatures

MAX_N = 1000 + 24
INF = 1000 * 1000

# n = 339
file_name = "2.tsp"
cities = []

with open(file_name, "r") as data_file:
    for line in data_file:
        cities.append(list(map(float, line.split()))[1:])

n = len(cities)
dist = [[0 for _ in range(n)] for _ in range(n)]

mark = [-1 for _ in range(MAX_N)]
best_path = [0 for _ in range(MAX_N)]
best_cost = INF

def solve(vec, sz = 0, cst = 0, lst = -1):
    global best_cost
    global best_path
    global mark

    if sz == len(vec):
        if (cst < best_cost):
            best_cost = cst
            for v in vec:
                best_path[v] = mark[v]
        return
    for v in vec:
        if (mark[v] == -1):
            mark[v] = sz
            if lst == -1:
                solve(vec, sz+1, cst, v)
            else:
                solve(vec, sz+1, cst + dist[lst][v], v)
            mark[v] = -1
    return

def sub(vec):
    global mark
    for v in vec:
        mark[v] = -1
    global best_cost
    best_cost = INF
    
    solve(vec)
    return best_cost

# n_class = max(n // 6, 6)
# n_class = max (n//2, 10)
n_class = n
size = [0 for _ in range(n_class)]
som_mat = [[0, 0] for _ in range(n_class)]

cls = [-1 for _ in range(n)]

def initialize(min, max):
    for i in range(n_class):
        som_mat[i][0] = random.random() * (max - min + 1) - min
        som_mat[i][1] = random.random() * (max - min + 1) - min

alpha = 0.9
neighbor = 3

def train(n):
    for i in range(n):
        v = cities[i]
        best_class = -1
        best_dist = INF
        for j in range(n_class):
            cur_dist = np.linalg.norm(np.array(v) - np.array(som_mat[j]))
            if cur_dist < best_dist:
                best_dist = cur_dist
                best_class = j
        cls[i] = best_class
        k = (best_class - neighbor) % n_class
        cnt = 2 * neighbor + 1
        while cnt > 0:
            som_mat[k][0] = som_mat[k][0] + alpha * (cities[i][0] - som_mat[k][0])
            som_mat[k][1] = som_mat[k][1] + alpha * (cities[i][1] - som_mat[k][1])
            k += 1
            k %= n_class
            cnt -= 1

for i in range(n):
    for j in range(i):
        dist[i][j] = np.linalg.norm(np.array(cities[i]) - np.array(cities[j]))
        dist[j][i] = dist[i][j]

epochs = 200
initialize(0, 1000)

for i in range(epochs):
    # if i % 10:
    #     print (i)

    if (i % 12 == 0):
        alpha *= 0.8
    if (i % 20 == 0 and neighbor > 1):
        neighbor -= 1

    train(n)

for i in range(n):
    size[cls[i]] += 1

all_classes = [[] for _ in range(n_class)]
for i in range(n):
    all_classes[cls[i]].append(i)

for i in range(n_class):
    if size[i]:
        print(i, size[i], all_classes[i])

ans = []
for i in range(n_class):
    if size[i] > 1:
        sub(all_classes[i])
        index = len(ans)
        for _ in range(len(all_classes[i])):
            ans.append(0)

        first = 0
        last = 0
        for v in all_classes[i]:
            if (best_path[v] == 0):
                first = v
            if (best_path[v] == len(all_classes[i])-1):
                last = v

        # for v in all_classes[i]:
        #     ans[index+best_path[v]] = v

        if i > 1:
            if dist[ans[index-1]][first] <= dist[ans[index-1]][last]:
                for v in all_classes[i]:
                    ans[index+best_path[v]] = v
            else:
                for v in all_classes[i]:
                    ans[index+ ((len(all_classes[i]) - 1 -  best_path[v]))] = v
        else:
            for v in all_classes[i]:
                    ans[index+best_path[v]] = v


    elif size[i] == 1:
        ans.append(all_classes[i][0])
print (len(ans), ans) 

vertices = []
G = nx.Graph()
for i in ans:
    G.add_node(i, pos = (cities[i][0], cities[i][1]))

total_cost = 0
for i in range(1, len(ans)):
    total_cost += dist[ans[i-1]][ans[i]]
    G.add_edge(ans[i-1], ans[i])
total_cost += dist[ans[-1]][ans[0]]
print (total_cost)
G.add_edge(ans[-1], ans[0])

pos = nx.get_node_attributes(G, 'pos')

fig, axis = plt.subplots(1, 2)

plt.sca(axis[0])
nx.draw(G, with_labels = True, pos=pos, node_size=100, node_color = cls, cmap = plt.cm.seismic)

plt.sca(axis[1])
np_cities = np.array(cities)
plt.scatter(np_cities[:, 0], np_cities[:, 1], c = cls, cmap="seismic")

plt.show()