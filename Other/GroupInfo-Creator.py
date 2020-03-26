# Batch create info.ini files in a Songs folder.  - slaugaus

# Better safe than sorry.
import sys
if sys.version_info <= (3, 0):
    sys.stdout.write("This is a Python 3 script, and you're trying to run it with Python 2. Exiting.\n")
    sys.exit(1)

import os

strings = ["[GroupInfo]\n", "Description=", "Ratings="]

folderPath = input("Input the path to a StepMania \"Songs\" folder: ")

os.chdir(folderPath)

for dir in os.listdir(os.getcwd()):
    if os.path.isfile(dir + "/info.ini"):
        print("info.ini already exists in folder " + dir + ", ignoring.")
        continue
    x = input("Create an info.ini in folder " + dir + "? (y/N) ")
    if x.lower() == "y":
        desc = input("Description: ")
        rate = input("Rating info: ")
        if desc or rate:
            with open(dir + "/info.ini", "w+") as file:
                file.write(strings[0])
                file.write(strings[1] + desc + "\n")
                file.write(strings[2] + rate + "\n")
                print("File saved.")
        else:
            print("No inputs. Skipping folder " + dir + "...")
            continue
    else:
        print("Skipping folder " + dir + "...")
        continue
