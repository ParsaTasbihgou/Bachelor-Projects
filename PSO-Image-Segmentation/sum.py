from os import read

file_name = "results/5CL/results.txt"
file = open(file_name, "r")

sse = 0
psnr = 0

size = 52

cnt = 0

for _ in range(size):
    line = file.readline()
    arr = line.split()
    sse += float(arr[3])

    if (float(arr[6]) > 0):
        cnt += 1
        psnr += float(arr[6])

sse /= size
psnr /= cnt

print (sse, psnr)