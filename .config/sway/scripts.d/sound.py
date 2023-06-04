#!/bin/python3
import os, subprocess, argparse

###############################
#
## Volume Limit (default: 100)
#
###############################
volumeLimit = 150



###############################
#
## Get Volume Level
#
###############################
def getVolumeLevel():
    try:
        commandOutput = os.popen("pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5, $12}' | sed 's/%//g'").read().split()
        leftVolumeLevel = int(commandOutput[0])
        rightVolumeLevel = int(commandOutput[1])
        averageVolumeLevel = int((leftVolumeLevel + rightVolumeLevel) / 2)
    except IndexError:
        print("An error occurred during get sound volume!!")
        exit(1)
    else:
        return [leftVolumeLevel, averageVolumeLevel, rightVolumeLevel]



###############################
#
## Decrease Volume Level
#
###############################
def decreaseVolumeLevel(level):
    try:
        subprocess.call(["pactl", "set-sink-volume", "@DEFAULT_SINK@", f"{level}%"])
    except:
        print("Error!!!")




###############################
#
## Increase Volume Level
#
###############################
def increaseVolumeLevel(level):
    if (getVolumeLevel()[1] + int(level) <= volumeLimit):
        try:
            subprocess.call(["pactl", "set-sink-volume", "@DEFAULT_SINK@", f"{level}%"])
        except:
            print("Error!!!")




###############################
#
## Handler
#
###############################
def parseArgs():
    parser = argparse.ArgumentParser(description='Sound Helper')
    parser.add_argument("-s", "--set", required=False, help="Set Sound Volume", metavar="LEVEL")
    return parser.parse_args()

def main():
    arguments = parseArgs()
    
    if (arguments.set == None):
        x = getVolumeLevel()[0]
        y = getVolumeLevel()[2]
        z = getVolumeLevel()[1]
        print(
            f"Average Volume Level: {z}\n",
            f"  Left Volume Level: {x}\n",
            f" Right Volume Level: {y}"
        )
    elif ("-" in arguments.set):
        #print("Decrease!")
        decreaseVolumeLevel(arguments.set)
    elif ("+" in arguments.set) or ("-" not in arguments.set):
        #print("Increase!")
        increaseVolumeLevel(arguments.set)
    else:
        print(arguments.set[0])
        print("???")

main()
