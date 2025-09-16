# List of commands I used at first in the node (from Deepseek)
# I don't think this script will run nor should it really its just a reference for commands I entered

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