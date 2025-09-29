#!/bin/bash
# need to run this using sudo 

# --- Configuration ---
# Number of times to run hackbench for each scheduler to get a good average.
NUM_RUNS=10
# Adjust these hackbench parameters to get a ~10 second runtime on your machine.
# -g: number of process groups
# -l: number of loops per group
GROPS=40
LOOPS=4000

# Schedulers to test.
# NORMAL is the default Linux CFS scheduler.
# FIFO and RR are real-time schedulers.
# BATCH is for CPU-intensive, non-interactive tasks.
SCHEDULERS=("NORMAL" "FIFO" "RR" "BATCH")

# --- Main Script ---
# Create a directory to store results
RESULTS_DIR="hackbench_results"
mkdir -p "$RESULTS_DIR"

echo "Starting hackbench benchmark across different schedulers..."
echo "Parameters: $NUM_RUNS runs, $GROPS groups, $LOOPS loops."a
echo "========================================================"

# Loop over each scheduler
for scheduler in "${SCHEDULERS[@]}"; do
  RESULTS_FILE="$RESULTS_DIR/results_${scheduler}.txt"
  echo "Testing Scheduler: $scheduler..."
  # Clear previous results for this scheduler
  > "$RESULTS_FILE"

  # Inner loop to run the benchmark multiple times
  for i in $(seq 1 $NUM_RUNS); do
    
    # Base command for hackbench
    HACKBENCH_CMD="hackbench -g 40 -l $LOOPS"
    
    # Prefix the command with schedtool based on the current scheduler
    case $scheduler in
      "FIFO")
        # -F for FIFO, -p for priority (high for RT), -e to execute the command
        CMD="schedtool -F -p 99 -e $HACKBENCH_CMD"
        ;;
      "RR")
        # -R for Round-Robin, -p for priority, -e to execute
        CMD="schedtool -R -p 99 -e $HACKBENCH_CMD"
        ;;
      "BATCH")
        # -B for BATCH, -e to execute
        CMD="schedtool -B -e $HACKBENCH_CMD"
        ;;
      *)
        # For "NORMAL", we run without schedtool
        CMD="$HACKBENCH_CMD"
        ;;
    esac

    # Run the command and extract the time
    # The 'eval' is used to correctly execute the command string we built
    TIME=$(eval $CMD 2>&1 | grep 'Time:' | awk '{print $2}')
    
    # Check if TIME was successfully extracted and save it
    if [ -n "$TIME" ]; then
      echo "  Run $i: $TIME seconds"
      echo "$TIME" >> "$RESULTS_FILE"
    else
      echo "  Run $i: Failed to extract time."
    fi
  done
  echo "--------------------------------------------------------"
done

echo "Benchmark complete. Calculating statistics..."
echo "========================================================"
echo "Summary:"

# Loop through the results files and calculate stats for each scheduler using awk
for scheduler in "${SCHEDULERS[@]}"; do
  RESULTS_FILE="$RESULTS_DIR/results_${scheduler}.txt"
  
  if [ -s "$RESULTS_FILE" ]; then
    # Use awk to calculate mean and standard deviation
    awk -v sched="$scheduler" '
      { 
        sum += $1; 
        sumsq += $1^2 
      } 
      END { 
        mean = sum / NR; 
        stddev = sqrt(sumsq/NR - mean^2);
        printf "Scheduler: %-10s | Mean: %8.3f s | StdDev: %7.3f s\n", sched, mean, stddev;
      }' "$RESULTS_FILE"
  else
    echo "Scheduler: $scheduler - No data collected."
  fi
done

echo "========================================================"
echo "Raw data is saved in the '$RESULTS_DIR' directory."
