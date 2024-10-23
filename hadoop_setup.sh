#!/bin/bash
# Experiment 1: part 1: Hadoop Setup Script - hadoop_setup.sh
# Exit on any error
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Hadoop home path
HADOOP_HOME="/usr/local/hadoop"

# Function to log messages
log_message() {
    local message="$1"
    local level="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}"
}

# Function to start Hadoop services
start_hadoop() {
    log_message "Formatting NameNode..." "INFO"
    $HADOOP_HOME/bin/hdfs namenode -format

    log_message "Starting HDFS..." "INFO"
    $HADOOP_HOME/sbin/start-dfs.sh

    log_message "Starting YARN..." "INFO"
    $HADOOP_HOME/sbin/start-yarn.sh

    log_message "Hadoop services started successfully!" "INFO"
    log_message "Access Hadoop NameNode UI at: http://localhost:9870" "INFO"
    log_message "Access YARN ResourceManager UI at: http://localhost:8088" "INFO"
}

# Function to stop Hadoop services
stop_hadoop() {
    log_message "Stopping Hadoop services..." "INFO"
    $HADOOP_HOME/sbin/stop-yarn.sh
    $HADOOP_HOME/sbin/stop-dfs.sh
}

# Function to check services status
check_hadoop_status() {
    jps
}

# Main function
main() {
    case "$1" in
        start)
            start_hadoop
            ;;
        stop)
            stop_hadoop
            ;;
        status)
            check_hadoop_status
            ;;
        *)
            echo -e "Usage: $0 {start|stop|status}"
            exit 1
            ;;
    esac
}

main "$@"
