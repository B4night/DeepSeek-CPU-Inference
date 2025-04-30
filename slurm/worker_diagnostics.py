#!/usr/bin/env python3
import psutil
import time
import datetime
import socket
import argparse
import os

# 解析命令行参数
parser = argparse.ArgumentParser(description="Enhanced Worker Diagnostics Script")
parser.add_argument("--role", choices=["client", "server"], required=True,
                    help="Set the role of this node: client or server")
parser.add_argument("--interval", type=int, default=5,
                    help="Interval between measurements in seconds (default: 5)")
parser.add_argument("--output", type=str, default=None,
                    help="Output log file (default: worker_diagnostics_<role>_<hostname>.log)")
args = parser.parse_args()

hostname = socket.gethostname()
log_file = args.output if args.output else f"worker_diagnostics_{args.role}_{hostname}.log"

# Initialize network counters
prev_net = psutil.net_io_counters()
prev_time = time.time()

# Get the number of CPU cores
cpu_count = psutil.cpu_count(logical=True)

def bytes_to_mb(bytes_value):
    """Convert bytes to MB with 2 decimal places"""
    return round(bytes_value / (1024 * 1024), 2)

def get_numa_stats():
    """Try to get NUMA node statistics if available"""
    try:
        # This is a placeholder - actual NUMA stats would require platform-specific code
        # On Linux you might use numactl or parse /proc/zoneinfo
        return {}
    except:
        return {}

while True:
    try:
        now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # CPU measurements
        cpu_percent = psutil.cpu_percent(interval=1)
        per_cpu = psutil.cpu_percent(interval=0, percpu=True)
        active_cores = sum(1 for core in per_cpu if core > 5.0)  # Consider cores with >5% usage as active
        
        # Memory info
        mem = psutil.virtual_memory()
        mem_used_gb = round(mem.used / (1024**3), 2)
        
        # Network throughput
        current_time = time.time()
        current_net = psutil.net_io_counters()
        time_diff = current_time - prev_time
        
        bytes_sent = current_net.bytes_sent - prev_net.bytes_sent
        bytes_recv = current_net.bytes_recv - prev_net.bytes_recv
        
        # Convert total network counters to MB
        net_sent_mb = bytes_to_mb(current_net.bytes_sent)
        net_recv_mb = bytes_to_mb(current_net.bytes_recv)
        
        # Get NUMA statistics (placeholder)
        numa_stats = get_numa_stats()
        
        # Format output line
        log_entry = f"[{now}]\n"
        log_entry += f"  CPU (avg): {cpu_percent}% | Active Cores: {active_cores}/{cpu_count}\n"
        log_entry += f"  Mem: {mem.percent}% (Used: {mem_used_gb} GB)\n"
        log_entry += f"  Net: Sent={net_sent_mb} MB | Recv={net_recv_mb} MB\n"
        log_entry += f"  NUMA Stats: {numa_stats}\n"
        
        # Write to log file
        with open(log_file, "a") as f:
            f.write(log_entry + "\n")
        
        # Print to console as well
        print(log_entry)
        
        # Update previous values
        prev_net = current_net
        prev_time = current_time
        
    except Exception as e:
        error_msg = f"[{now}] ERROR: {str(e)}\n"
        with open(log_file, "a") as f:
            f.write(error_msg)
        print(error_msg)
    
    time.sleep(args.interval)