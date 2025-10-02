# List of commands I ran 

# Schedtool + Hackbench for 10s
# 1) Setup since node restarted + need datamash for analysis
sudo apt-get update
sudo apt-get install rt-tests
sudo apt-get install datamash
sudo apt-get install schedtool

# For noise minimization
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo1

# DO NOT run this
echo 0 | sudo tee  /sys/devices/system/cpu/cpu*/online

# This disables hyperthreading
echo off | sudo tee /sys/devices/system/cpu/smt/control

for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
  echo performance | sudo tee $i
done


