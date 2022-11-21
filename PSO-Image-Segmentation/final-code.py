import copy
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np
import random
import math

import sys
sys.setrecursionlimit(1000 * 1000)

INF = 1000 * 1000 * 1000

# file_name = input("file name: ")
    # file_name = "ALL_IDB2/img/Im148_0.tif"
file_name = "./Ak (66).png"
# input_file = open("input_file2.txt", "r")
# file_name = input_file.readline()
# input_file.close()
# print (file_name)
    # pic_name = list(file_name.split("/"))[2]
pic_name = "ak66"


picture = np.array(Image.open(file_name))

size = picture.shape
n = size[0]
m = size[1]

def PSNR(picture, recoloured_picture, n, m, l = 256):
    sum = [0, 0, 0]
    for colour in range(3):
        for i in range(n):
            for j in range(m):
                sum[colour] += ((picture[i][j][colour] - recoloured_picture[i][j][colour]) ** 2)
        
        sum[colour] /= (n * m)
        sum[colour] = (l * l) / sum[colour]
    print (sum)
    ret = [10 * math.log10(x) for x in sum]
    return ret

def RGB_distance(a, b):
    sse = 0
    for i in range(len(a)):
        sse += (float(a[i]) - float(b[i])) ** 2
    return np.sqrt(sse)

def fitness(data, recoloured, n, m):
    sum = 0
    for i in range(n):
        for j in range(m):
            sum += RGB_distance(data[i][j], recoloured[i][j])
    return sum

class Particle:
    def __init__(self, n_cluster, n_par):
        self.n_cluster = n_cluster
        self.n_par = n_par
        self.personal_best = np.array([[random.random() * 255 for _ in range(n_par)] for _ in range(n_cluster)])
        self.personal_best_cost = INF
        self.position = np.array([[random.random() * 255 for _ in range(n_par)] for _ in range(n_cluster)])
        self.velocity = np.array([[(random.random() - 0.5) * 2  for _ in range(n_par)] for _ in range(n_cluster)])
        self.cost = 0

    def fit(self, data, n, m, b = 1):
        clusters = []
        central_dist = []
        cost = 0

        for i in range(0, n):
            for j in range(0, m, 2*b+1):
                best_dist = INF
                best_cluster = -1
                cur_dist = 0
                for k in range(self.n_cluster):
                    cl = self.position[k]
                    cur_dist = RGB_distance(data[i][j], cl)
                    if (cur_dist < best_dist):
                        best_dist = cur_dist
                        best_cluster = cl
                for l in range(max(0, j-b), (min(m, j+b+1)), 1):
                    clusters.append(best_cluster)
                    cost += best_dist
        return (cost, clusters)

    def fit_estimate(self, data):
        cost = 0
        for point in data:
            best_dist = INF
            cur_dist = 0
            for k in range(self.n_cluster):
                    cl = self.position[k]
                    cur_dist = RGB_distance(point, cl)
                    if (cur_dist < best_dist):
                        best_dist = cur_dist
            cost += best_dist
        return cost
            

n_iteration = 30
n_particles = 20
n_clusters = 8
particles = []

intensities = [[0 for _ in range(260)], [0 for _ in range(260)], [0 for _ in range(260)]]
for i in range(len(picture)):
    for j in range(len(picture[i])):
        for k in range(3):
            intensities[k][picture[i][j][k]] += 1
    

stk = [[], [], []]
for i in range(256):
    for j in range(3):
        flag = True
        # print (intensities[j][i], intensities[j][i:i+5])
        for k in range(max(i-5, 0), min(256, i+5)):
            if intensities[j][i] <= intensities[j][k] and k != i:
                flag = False
        if flag:
            stk[j].append(i)

# print (stk)

background = np.array([intensities[i].index(max(intensities[i])) for i in range(3)])

# print (background)

all_colours = []

for i in range(len(stk[0])-1, max(-1, len(stk[0]) - 4), -1):
    for j in range(len(stk[1])-1, max(-1, len(stk[1]) - 4), -1):
        for k in range(len(stk[2])-1, max(-1, len(stk[2]) - 4), -1):
            all_colours.append([stk[0][i], stk[1][j], stk[2][k]])
colour_count = [0 for _ in range(len(all_colours))]

for i in range(0, n, 2):
    for j in range(0, m, 2):
        best_dist = INF
        cur_dist = 0
        winner_colour = 0
        for k in range(len(all_colours)):
            colour = all_colours[k]
            cur_dist = RGB_distance(picture[i][j], colour)
            if (cur_dist < best_dist):
                best_dist = cur_dist
                winner_colour = k
        
        colour_count[winner_colour] += 1

finall_colours = []
# finall_colours.append([x for x in background])
while (len(finall_colours) < n_clusters):
    index = colour_count.index(max(colour_count))
    finall_colours.append(all_colours[index])
    colour_count[index] = 0

# print (finall_colours)

particles.append(Particle(n_cluster= n_clusters, n_par= 3))
for i in range(len(finall_colours)):
    particles[-1].position[i] = [x  for x in finall_colours[i]]
    # particles[-1].velocity[i] = 0.1

for _ in range(n_particles-1):
    particles.append(Particle(n_cluster= n_clusters, n_par= 3))
    for i in range(len(finall_colours)):
        particles[-1].position[i] = [int(x + (random.random() - 0.50) * 20)  for x in finall_colours[i]]
        # particles[-1].velocity[i] = 0.1

# particles[0].position = [[148, 127, 155], [126, 73, 149], [178,172, 158], [167, 137, 129]]

data = np.int32(picture)
estimate_data = []
for i in range(0, n, 3):
    for j in range(0, m, 5):
        sum = [0, 0, 0]
        cnt = 0
        for k in range(max(0, j - 2), min (m, j+3)):
            sum[0] += data[i][k][0]
            sum[1] += data[i][k][1]
            sum[2] += data[i][k][2]
            cnt += 1
        estimate_data.append([x / cnt for x in sum])

def train(particles, data, n_iterations, c_self, c_pbest, c_gbest, batch_size = 1):
    global_best = copy.deepcopy(particles[0])
    global_best.cost = INF
    iteration = 0
    while (iteration < n_iterations):
        print ("Iteration: ", iteration)
        iteration += 1
        cnt = 0
        for particle in particles:
            cnt += 1

            particle.cost, clusters = particle.fit(data, n, m, batch_size)
            print (cnt, particle.cost)

            if (particle.cost < particle.personal_best_cost):
                particle.personal_best_cost = particle.cost
                particle.personal_best = copy.deepcopy(particle.position)

            if (particle.cost < global_best.cost):
                print ("NEW:", particle.cost, [x for x in particle.position])
                print ("here G")
                global_best = copy.deepcopy(particle)

            for i in range(len(particle.velocity)):
                particle.velocity[i] = copy.deepcopy(c_self * particle.velocity[i]) + copy.deepcopy(c_pbest * (random.random() - 0.5) * (particle.personal_best[i] - particle.position[i])) + copy.deepcopy(c_gbest * (random.random() - 0.5) * (global_best.position[i] - particle.position[i]))
                particle.position[i] += particle.velocity[i]

    return global_best

def train2(particles, data, n_iterations, c_self, c_pbest, c_gbest, batch_size = 1):
    global_best = copy.deepcopy(particles[0])
    global_best.cost = INF
    iteration = 0
    while (iteration < n_iterations):
        if iteration % 10 == 0:
            print ("Iteration: ", iteration)
            
        iteration += 1
        cnt = 0
        for particle in particles:
            cnt += 1

            particle.cost = particle.fit_estimate(data)

            if (particle.cost < particle.personal_best_cost):
                particle.personal_best_cost = particle.cost
                particle.personal_best = copy.deepcopy(particle.position)

            if (particle.cost < global_best.cost):
                # print ("NEW:", particle.cost, [x for x in particle.position])
                global_best = copy.deepcopy(particle)

            for i in range(len(particle.velocity)):
                particle.velocity[i] = copy.deepcopy(c_self * particle.velocity[i]) + copy.deepcopy(c_pbest * (random.random() - 0.5) * 4 * (particle.personal_best[i] - particle.position[i])) + copy.deepcopy(c_gbest * (random.random() - 0.5) * (global_best.position[i] - particle.position[i]))
                particle.position[i] += particle.velocity[i]

    return global_best

# BEST = train(particles= particles, data= data, n_iterations=int(input("Iterations: ")), c_self=0.2, c_gbest=0.6, c_pbest=0.2, batch_size=3)
BEST = train2(particles= particles, data= estimate_data, n_iterations=n_iteration, c_self=0.3, c_gbest=0.5, c_pbest=0.2, batch_size=6)

BEST.position = BEST.position.astype(np.int16)

def hill_climb(data, particle, start_fitness,n_iterations, neighbor_radius):
    last_move = [[0, 0, 0] for _ in range(n_clusters)]
    iteration = 0
    best_result = []
    best_cost = start_fitness
    while iteration < n_iterations:
        iteration += 1
        print("Hill climbing iteration: ", iteration)
        move_vector = [0, 0, 0]

        visited = []

        for dim in range(n_clusters):
            init_pos = copy.copy(particle.position[dim])
            # print(init_pos)
            for i in range(max(0, init_pos[0]-neighbor_radius), min(255, init_pos[0]+neighbor_radius+1), 1):
                for j in range(max(0, init_pos[1]-neighbor_radius), min(255, init_pos[1]+neighbor_radius+1), 1):
                    for k in range(max(0, init_pos[2]-neighbor_radius), min(255, init_pos[2]+neighbor_radius+1), 1):
                        # print (k)
                        move_vector = [i, j, k]
                        if move_vector not in visited:
                            visited.append(move_vector)
                            temp = copy.deepcopy(particle)
                            temp.position[dim] = copy.copy(move_vector)

                            cost = temp.fit_estimate(data)
                            if cost < best_cost:
                                best_cost = cost
                                particle.position[dim] = copy.copy(move_vector)
                                particle.cost = cost
                                if (i < init_pos[0]):
                                    last_move[dim][0] = -1
                                elif (i > init_pos[0]):
                                    last_move[dim][0] = 1
                                else:
                                    last_move[dim][0] = 0

                                if (j < init_pos[1]):
                                    last_move[dim][1] = -1
                                elif (j > init_pos[1]):
                                    last_move[dim][1] = 1
                                else:
                                    last_move[dim][1] = 0

                                if (k < init_pos[2]):
                                    last_move[dim][2] = -1
                                elif (k > init_pos[2]):
                                    last_move[dim][2] = 1
                                else:
                                    last_move[dim][2] = 0
                                
            print("cluster ", dim, " best -> ", best_cost)
    return best_cost, particle, last_move

cost, BEST, last_move = hill_climb(estimate_data, BEST, BEST.fit_estimate(estimate_data), 1, 1)

def search(data, particle, start_fitness, last_move):
    best_fitness = start_fitness
    temp = copy.deepcopy(particle)
    for dim in range(n_clusters):
        for colour in range(3):
            if last_move[dim][colour] != 0:
                cur_colour = temp.position[dim][colour]
                while (0 <= temp.position[dim][colour] <= 255):
                    # print (temp.position[dim][colour])
                    temp.position[dim][colour] += last_move[dim][colour]
                    cur_fitness = temp.fit_estimate(data)
                    if cur_fitness < best_fitness:
                        best_fitness = cur_fitness
                        temp.cost = cur_fitness
                    else:
                        temp.position[dim][colour] -= last_move[dim][colour]
                        break
    return temp

BEST = search(estimate_data, BEST, cost, last_move=last_move)

total_cost, clusters = BEST.fit(data, n, m, 0)
print (total_cost)

picture_recoloured = np.reshape(clusters, picture.shape)

psnr = PSNR(picture, picture_recoloured, n, m, 256)
total_psnr = (psnr[0] + psnr[1] + psnr[2]) / 3

print (total_psnr)

# output_file = open("results/res2.txt", "a")
# output_file.write(pic_name + " - SSE: " + str(total_cost) + " - PSNR: " + str(total_psnr) + "\n")
# output_file.close()

fig, ax = plt.subplots(1, 3, figsize=(16, 6), subplot_kw=dict(xticks=[], yticks=[]))

fig.subplots_adjust(wspace=0.05)
ax[0].imshow(picture)
ax[0].set_title('Original Image', size=16)
ax[1].imshow((picture_recoloured).astype(np.uint8))

# plt.imshow((out * 255).astype(np.uint8))

ax[1].set_title(str(n_clusters) + 'color Image', size=16)
ax[2].hist(picture.reshape(n*m, 3), bins= 256, rwidth = 1)

# plt.savefig("results/" + pic_name + "--" + str(total_cost) + ".jpg")
plt.show()