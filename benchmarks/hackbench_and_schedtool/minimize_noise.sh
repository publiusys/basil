#!/bin/bash
#
# minimize_noise.sh - A wrapper script to create a low-noise environment for benchmarking.
# Based on techniques from: https://easyperf.net/blog/2019/08/02/Perf-measurement-environment-on-Linux
#
# Usage: sudo ./minimize_noise.sh <your_benchmark_command>
# Example: sudo ./minimize_noise.sh hackbench -g 40 -l 4000

# If I am being fully honest I am not entirely sure how this works? or which cpu to isolate?
# Might spend more time on this next week
# This failed :( So I will spend more time looking into how to do this next week 

# --- Configuration ---
# Set the CPU(s) you want to isolate for the benchmark.
# This should be a CPU that is NOT the boot CPU (core 0).
# Find a core and its SMT sibling. Use `lscpu -e` to check.
# Example: "3,7" for core 3 and its sibling 7.
ISOLATED_CPUS="3"

# --- Script Start ---

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)."
  exit 1
fi

# 2. Check for benchmark command
if [ -z "$1" ]; then
    echo "Usage: sudo $0 <your_benchmark_command>"
    echo "Example: sudo $0 hackbench -g 40 -l 4000"
    exit 1
fi

BENCHMARK_CMD="$@"
ORIG_SETTINGS_DIR="/tmp/orig_settings_$(date +%s)"
mkdir -p "$ORIG_SETTINGS_DIR"
echo "Saving original system settings to $ORIG_SETTINGS_DIR"

# --- Function to save original settings ---
save_setting() {
    local path=$1
    local setting_name=$2
    if [ -f "$path" ]; then
        cat "$path" > "$ORIG_SETTINGS_DIR/$setting_name"
    fi
}

# --- Cleanup Function: Restore all original settings ---
cleanup_environment() {
    echo -e "\n--- Restoring original system settings ---"

    # Restore CPU governors
    for cpu_gov in "$ORIG_SETTINGS_DIR"/cpu*_governor; do
        if [ -f "$cpu_gov" ]; then
            cpu_num=$(basename "$cpu_gov" | sed 's/cpu\([0-9]*\)_governor/\1/')
            cat "$cpu_gov" > "/sys/devices/system/cpu/cpu$cpu_num/cpufreq/scaling_governor"
            echo "Restored CPU$cpu_num governor to $(cat "$cpu_gov")"
        fi
    done

    # Restore other settings by reversing the setup steps
    [ -f "$ORIG_SETTINGS_DIR/smt_control" ] && cat "$ORIG_SETTINGS_DIR/smt_control" > /sys/devices/system/cpu/smt/control && echo "Restored SMT control."
    [ -f "$ORIG_SETTINGS_DIR/no_turbo" ] && cat "$ORIG_SETTINGS_DIR/no_turbo" > /sys/devices/system/cpu/intel_pstate/no_turbo && echo "Restored Intel Turbo Boost."
    [ -f "$ORIG_SETTINGS_DIR/randomize_va_space" ] && cat "$ORIG_SETTINGS_DIR/randomize_va_space" > /proc/sys/kernel/randomize_va_space && echo "Restored ASLR."
    [ -f "$ORIG_SETTINGS_DIR/nmi_watchdog" ] && cat "$ORIG_SETTINGS_DIR/nmi_watchdog" > /proc/sys/kernel/nmi_watchdog && echo "Restored NMI Watchdog."
    [ -f "$ORIG_SETTINGS_DIR/perf_event_paranoid" ] && cat "$ORIG_SETTINGS_DIR/perf_event_paranoid" > /proc/sys/kernel/perf_event_paranoid && echo "Restored perf_event_paranoid."
    [ -f "$ORIG_SETTINGS_DIR/thp_enabled" ] && cat "$ORIG_SETTINGS_DIR/thp_enabled" > /sys/kernel/mm/transparent_hugepage/enabled && echo "Restored THP enabled."
    [ -f "$ORIG_SETTINGS_DIR/thp_defrag" ] && cat "$ORIG_SETTINGS_DIR/thp_defrag" > /sys/kernel/mm/transparent_hugepage/defrag && echo "Restored THP defrag."

    # Restore IRQ affinities
    for irq_file in "$ORIG_SETTINGS_DIR"/irq_*_affinity; do
        if [ -f "$irq_file" ]; then
            irq_num=$(basename "$irq_file" | sed 's/irq_\([0-9]*\)_affinity/\1/')
            cat "$irq_file" > "/proc/irq/$irq_num/smp_affinity_list"
        fi
    done
    echo "Restored IRQ affinities."

    # Clean up cpuset
    if [ -d "/sys/fs/cgroup/cpuset/system" ]; then
        # Move tasks from benchmark set back to root before removing
        for pid in $(cat /sys/fs/cgroup/cpuset/benchmark/tasks); do
            echo $pid > /sys/fs/cgroup/cpuset/tasks 2>/dev/null
        done
        rmdir /sys/fs/cgroup/cpuset/benchmark
        # Restore original system cpuset config
        cat "$ORIG_SETTINGS_DIR/system_cpus" > /sys/fs/cgroup/cpuset/system/cpuset.cpus
        echo "Cleaned up cpusets."
    fi

    rm -rf "$ORIG_SETTINGS_DIR"
    echo "Cleanup complete."
}

# Trap the EXIT signal to ensure cleanup_environment is always called
trap cleanup_environment EXIT

# --- Setup Function: Configure the low-noise environment ---
echo "--- Configuring low-noise environment ---"

# 1. Disable SMT (Hyper-Threading)
save_setting /sys/devices/system/cpu/smt/control smt_control
echo "off" > /sys/devices/system/cpu/smt/control
echo "Disabled SMT (Hyper-Threading)."

# 2. Set CPU Governor to "performance" for all cores
for cpu_gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    cpu_num=$(basename $(dirname "$cpu_gov"))
    save_setting "$cpu_gov" "${cpu_num}_governor"
    echo "performance" > "$cpu_gov"
done
echo "Set all CPU governors to 'performance'."

# 3. Disable Intel Turbo Boost
save_setting /sys/devices/system/cpu/intel_pstate/no_turbo no_turbo
echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
echo "Disabled Intel Turbo Boost."

# 4. Disable ASLR
save_setting /proc/sys/kernel/randomize_va_space randomize_va_space
echo 0 > /proc/sys/kernel/randomize_va_space
echo "Disabled Address Space Layout Randomization (ASLR)."

# 5. Disable Watchdogs and other kernel settings
save_setting /proc/sys/kernel/nmi_watchdog nmi_watchdog
save_setting /proc/sys/kernel/perf_event_paranoid perf_event_paranoid
save_setting /sys/kernel/mm/transparent_hugepage/enabled thp_enabled
save_setting /sys/kernel/mm/transparent_hugepage/defrag thp_defrag

echo 0 > /proc/sys/kernel/nmi_watchdog
echo -1 > /proc/sys/kernel/perf_event_paranoid
echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
echo "Disabled watchdogs and Transparent Huge Pages."

# 6. Set up cpusets
TOTAL_CPUS=$(grep -c ^processor /proc/cpuinfo)
ALL_CPU_LIST="0-$(($TOTAL_CPUS - 1))"
HOUSEKEEPING_CPUS=$(tr ',' '\n' <<< "$ALL_CPU_LIST" | grep -vF "$(tr ',' '\n' <<< "$ISOLATED_CPUS")" | tr '\n' ',' | sed 's/,$//')

# Move all current tasks to a "system" cpuset
mkdir -p /sys/fs/cgroup/cpuset
mount -t cgroup -o cpuset none /sys/fs/cgroup/cpuset 2>/dev/null || true # Mount if not already mounted
mkdir -p /sys/fs/cgroup/cpuset/system
save_setting /sys/fs/cgroup/cpuset/system/cpuset.cpus system_cpus
echo "$HOUSEKEEPING_CPUS" > /sys/fs/cgroup/cpuset/system/cpuset.cpus
echo 0 > /sys/fs/cgroup/cpuset/system/cpuset.mems
for pid in $(cat /sys/fs/cgroup/cpuset/tasks); do
    echo $pid > /sys/fs/cgroup/cpuset/system/tasks 2>/dev/null
done

# Create a cpuset for our benchmark
mkdir -p /sys/fs/cgroup/cpuset/benchmark
echo "$ISOLATED_CPUS" > /sys/fs/cgroup/cpuset/benchmark/cpuset.cpus
echo 0 > /sys/fs/cgroup/cpuset/benchmark/cpuset.mems
echo "Created 'benchmark' cpuset for CPU(s): $ISOLATED_CPUS"

# 7. Set IRQ affinity
echo "Moving IRQs to housekeeping CPUs ($HOUSEKEEPING_CPUS)..."
for irq_dir in /proc/irq/*; do
    if [ -d "$irq_dir" ] && [ -f "$irq_dir/smp_affinity_list" ]; then
        irq_num=$(basename "$irq_dir")
        save_setting "$irq_dir/smp_affinity_list" "irq_${irq_num}_affinity"
        echo "$HOUSEKEEPING_CPUS" > "$irq_dir/smp_affinity_list" 2>/dev/null || true
    fi
done

# --- Execute the Benchmark ---
echo "-------------------------------------------"
echo "Environment configured. Running benchmark..."
echo "Command: $BENCHMARK_CMD"
echo "-------------------------------------------"

# Move this script (and its children) into the benchmark cpuset and execute the command
echo $$ > /sys/fs/cgroup/cpuset/benchmark/tasks
eval "$BENCHMARK_CMD"

# The 'trap' will handle cleanup automatically when the script exits.
