# List of commands I ran 

# Schedtool + Hackbench for 10s
# 1) Setup since node restarted + need datamash for analysis
sudo apt-get update
sudo apt-get install rt-tests
sudo apt-get install datamash
sudo apt-get install schedtool

# For noise minimization
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo1
echo 0 | sudo tee  /sys/devices/system/cpu/cpu*/online

for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
  echo performance | sudo tee $i
done
# This produced lots of tee: /sys/devices/system/cpu/cpu21/cpufreq/scaling_governor: Device or resource busy