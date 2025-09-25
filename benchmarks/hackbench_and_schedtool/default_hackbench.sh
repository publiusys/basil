#!/bin/bash

# File to store the results
RESULTS_FILE="default_hackbench_results.txt"
# Clear previous results
> "$RESULTS_FILE"

NUM_RUNS=10
# Adjust these hackbench parameters to get ~10 second runtime on your machine
GROUPS=20
LOOPS=4000

echo "Starting hackbench benchmark..."
echo "Running $NUM_RUNS times with $GROUPS groups and $LOOPS loops."
echo "--------------------------------------------------------"

for i in $(seq 1 $NUM_RUNS); do
  # Run the command, find the line with "Time:", and extract the numeric value
#   I ended up just inputting this manually here instead of $Groups and $Loops since they were getting read strangely 
    TIME=$(hackbench -g 40 -l 4000 2>&1 | grep 'Time:' | awk '{print $2}')  
  # Check if TIME was successfully extracted
  if [ -n "$TIME" ]; then
    echo "Run $i: $TIME seconds"
    # Append the time to our results file
    echo "$TIME" >> "$RESULTS_FILE"
  else
    echo "Run $i: Failed to extract time."
  fi
done

echo "--------------------------------------------------------"
echo "Benchmark complete. Calculating statistics..."

# Use datamash to calculate and print the mean and standard deviation
# This does not work :((
LC_ALL=C datamash --header-out Mean,StdDev mean 1 sstdev 1 < "$RESULTS_FILE"

echo "Raw data is saved in '$RESULTS_FILE'"
