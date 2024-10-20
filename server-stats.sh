#!/bin/bash
set -x

# Function to get total CPU usage (adapted for macOS)
get_cpu_usage() {
    echo "CPU Usage:"
    # macOS uses different options for 'top', the below line extracts CPU usage properly for macOS
    top -l 1 | grep "CPU usage" | awk '{print "CPU Load: " $3+$5 "%"}'
}

# Function to get memory usage (free vs used)
get_memory_usage() {
    echo "Memory Usage:"
    # macOS doesn't have 'free', so we use 'vm_stat' instead
    vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages (free|active|inactive|speculative|wired down|purgable):\s+(\d+)/ and $mem{$1}=$2*$size; END { printf("Used: %.2f MB, Free: %.2f MB\n", ($mem{"active"}+$mem{"inactive"}+$mem{"wired down"})/1048576, $mem{"free"}/1048576); }'
}

# Function to get disk usage (free vs used)
get_disk_usage() {
    echo "Disk Usage:"
    # 'df' works on macOS the same way as Linux
    df -h | awk '$NF=="/"{printf "Disk Usage: %s/%sGB (%s)\n", $3,$2,$5}'
}

# Function to get top 5 processes by CPU usage (adjusted for macOS)
get_top_cpu_processes() {
    echo "Top 5 Processes by CPU Usage:"
    # Adjusting the 'ps' command for macOS, removing Linux-specific options
    ps -A -o pid,ppid,%cpu,command | sort -nrk 3 | head -6
}

# Function to get top 5 processes by memory usage (adjusted for macOS)
get_top_memory_processes() {
    echo "Top 5 Processes by Memory Usage:"
    # Adjusting the 'ps' command for macOS, removing Linux-specific options
    ps -A -o pid,ppid,%mem,command | sort -nrk 3 | head -6
}

# Optional Stretch Goal Stats

# Function to get OS version (adapted for macOS)
get_os_version() {
    echo "OS Version:"
    # Using 'sw_vers' for macOS since /etc/os-release doesn't exist
    sw_vers
}

# Function to get system uptime (without '-p' option)
get_uptime() {
    echo "System Uptime:"
    # macOS 'uptime' does not support the '-p' option
    uptime | awk -F, '{print "Uptime: " $1}'
}

# Function to get load average
get_load_average() {
    echo "Load Average:"
    # 'uptime' works similarly for load average in macOS
    uptime | awk -F'load averages: ' '{ print $2 }'
}

# Function to get logged-in users
get_logged_in_users() {
    echo "Logged-in Users:"
    who
}

# Function to get failed login attempts (adapted for macOS)
get_failed_logins() {
    echo "Failed Login Attempts:"
    # macOS doesn't have /var/log/auth.log, using /var/log/system.log instead
    grep "failed" /var/log/system.log | wc -l
}

# Main Script Execution
echo "Analyzing Server Performance Stats..."
echo "===================================="
get_cpu_usage
echo "------------------------------------"
get_memory_usage
echo "------------------------------------"
get_disk_usage
echo "------------------------------------"
get_top_cpu_processes
echo "------------------------------------"
get_top_memory_processes
echo "===================================="
echo "Optional Stretch Goal Stats"
echo "------------------------------------"
get_os_version
echo "------------------------------------"
get_uptime
echo "------------------------------------"
get_load_average
echo "------------------------------------"
get_logged_in_users
echo "------------------------------------"
get_failed_logins
echo "===================================="
echo "Server Performance Analysis Completed."
