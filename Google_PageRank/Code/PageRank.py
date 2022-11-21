import numpy as np
import networkx as nx
import matplotlib as plt
import matplotlib.pyplot as plot

#set MAX_N to limit the size of a big data set
MAX_N = 100

np.set_printoptions(precision=5, suppress=1, linewidth=200)

def MakeGoogleMatrix (n, web_matrix, d) :
    out_degree = [0 for _ in range(n)]
    for i in range(n):
        for j in range(n):
            out_degree[i] += web_matrix[i][j]

    D = np.diag(list(map (float, out_degree)))
    D_inv = D

    for i in range(n) :
     D_inv[i][i] = 1/D_inv[i][i]

    H = np.dot(D_inv,web_matrix)

    e = np.matrix([1.0 for _ in range (n)])
    V_0 = e / n

    google_matrix = d * H + ((1-d) * np.transpose(e) * V_0)

    return google_matrix

def BuildGraph (n, adj) :
    g = nx.DiGraph()
    for i in range(n):
        for j in range(n): 
            if (adj[i][j] != 0) :
                g.add_edge(i, j)
    return g

f = open ("data/data_email.txt")
n = int (f.readline())
n = min (n, MAX_N)
web_matrix = [ [0.0 for _ in range (n)] for _ in range (n)]
out_degree = [0 for _ in range (n)]
for s in f :
    temp = list(map(int, f.readline().split()))
    if (temp == []) :
        break
    u = temp[0]
    v = temp[1]
    if (u < n and v < n) :
        web_matrix[u][v] = 1.0
        out_degree[u] += 1

web_graph = BuildGraph (n, web_matrix)

out_degree = [0 for _ in range(n)]
for i in range(n):
    for j in range(n):
        out_degree[i] += web_matrix[i][j]

for i in range(n):
    if (out_degree[i] == 0):
        for j in range(n):
            web_matrix[i][j] = 1
    out_degree[i] = 1

google_matrix = MakeGoogleMatrix(n, web_matrix, d = 0.85)

e = np.matrix([1 for _ in range(n)])
PR = e/n

number_of_iterations = int (input("Enter the number of iterations: "))

for i in range (number_of_iterations):
    #print ("iteration ", i, " : ")
    #print (PR)
    PR = np.dot(PR, google_matrix)

PR = (PR.tolist())[0]
print ("the PageRank vector : \n", PR)

eigenvalues = np.linalg.eigvals(google_matrix)
eigenvalues.sort()
print ("dominant eigenvalue (according to theory should be 1) : ", eigenvalues[-1])

rank = [(0.0, 0) for _ in range(n)]
for i in range(n) :
    rank[i] = (PR[i], i)

rank.sort()

for i in range (n):
    rank[i] = (i, rank[i][1], rank[i][0])
    print (rank[i])

mx = -1.0
highest_rank = 0
for i in range(n):
    if (PR[i] > mx) :
        highest_rank = i

color_values = list()
for v in web_graph:
    color_values.append(PR[v])

pos = nx.spring_layout (web_graph, iterations = 100, k = 0.8)
nx.draw(web_graph, pos, font_size = 8, width = 0.1, with_labels=True, node_size = 100, arrowsize = 10, node_color = color_values, cmap = plot.cm.seismic)
plt.pyplot.savefig("graph.png")