# List of commands I used at first in the node (from Deepseek)
# I don't think this script will run nor should it really its just a reference for commands I entered

# For reference, the section of the paper and the benchmark results they got from STUN is in STUN_benchmarks.md

# Update the package list
sudo apt-get update

# Install essential build tools, git, and other dependencies
sudo apt-get install -y build-essential git cmake libssl-dev

# Install Python 3 and pip (highly recommended)
sudo apt-get install -y python3 python3-pip

# Install Sysbench (the microbenchmark from the paper)
sudo apt-get install -y sysbench

# Install packages needed for Hackbench
sudo apt-get install -y libssl-dev

# Install packages needed for OpenCV (the face detection workload)
sudo apt-get install -y libopencv-dev python3-opencv

# == HACKBENCH == bash script
# Create a directory for your work and navigate into it
mkdir stun_benchmarks && cd stun_benchmarks

# Download hackbench.c
wget http://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.

# Error, couldnt find it?
# wget http://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c
# --2025-09-16 14:42:50--  http://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c
# Resolving people.redhat.com (people.redhat.com)... 209.132.178.26
# Connecting to people.redhat.com (people.redhat.com)|209.132.178.26|:80... connected.
# HTTP request sent, awaiting response... 301 Moved Permanently
# Location: https://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c [following]
# --2025-09-16 14:42:50--  https://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c
# Connecting to people.redhat.com (people.redhat.com)|209.132.178.26|:443... connected.
# HTTP request sent, awaiting response... 404 Not Found
# 2025-09-16 14:42:50 ERROR 404: Not Found.

#  These pages look promising (look into later):
# https://man.archlinux.org/man/extra/rt-tests/hackbench.8.en
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux_for_real_time/7/html/tuning_guide/chap-before_you_start_tuning_your_rt_system

# Compile it
gcc -o hackbench hackbench.c -lpthread
;\


# NEW VERSION FOR HACKBENCH (much simpler yay)
sudo apt-get update
sudo apt-get install rt-tests

hackbench # This will create 10 groups of 40 tasks each (400 total) and report the time taken.

hackbench -p -T # Uses pipes and threads, often faster

# Stats from above:
# Time: 0.052

# == FACE DETECTION WORKLOAD TEST ==
# Download the pre-trained Haar cascade files for face and eye detection
wget https://github.com/opencv/opencv/raw/master/data/haarcascades/haarcascade_frontalface_default.xml
wget https://github.com/opencv/opencv/raw/master/data/haarcascades/haarcascade_eye.xml

nano face_detection.py
# Below this is python, i'll put it in face_detection.py

# Example: Download a short test video (replace with your own)
# wget http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4 -O test_video.mp4

# Run the face detection benchmark
python3 face_detection.py test_video.mp4

# Stats from above script:
# Total Execution Time: 15.181 seconds
# Total Frames: 360
# Frames Per Second (FPS): 23.714

# == SYSBENCH ==
# The paper used: "number of CPU cores x 10 threads"
NUM_CORES=$(nproc)
sysbench --threads=$(($NUM_CORES * 10)) --time=60 cpu run

# Stats from above commands (most important seems to be events per second?):
# events per second: 28830.07
# but here are the rest:
# General statistics:
#     total time:                          60.0087s
#     total number of events:              1730139

# Latency (ms):
#          min:                                    1.07
#          avg:                                   13.54
#          max:                                   86.25
#          95th percentile:                       40.37
#          sum:                             23432374.86

# Threads fairness:
#     events (avg/stddev):           4325.3475/253.75
#     execution time (avg/stddev):   58.5809/1.27
