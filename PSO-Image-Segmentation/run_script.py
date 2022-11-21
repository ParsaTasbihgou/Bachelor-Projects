import os
import subprocess
directory = "ALL_IDB2/img"
 
for filename in os.listdir(directory):
    f = os.path.join(directory, filename)
    # checking if it is a file
    if os.path.isfile(f):
        index = str(f).split("/")[2]
        try:
            index = int(index[2:5])
            if (index % 5 == 0):
                print (index, str(f))
                input_file = open("input_file2.txt", "w")
                input_file.write(str(f))
                input_file.close()

                os.system("python3 luk2-2.py")

        except:
            pass