#!/bin/bash
# Experiment 1: part 1: Hadoop Installation Script - hadoop_install.sh
# Exit on any error
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Hadoop version and paths
HADOOP_VERSION="3.3.6"
HADOOP_HOME="/usr/local/hadoop"
HADOOP_USER="$USER"  # Use current user instead of creating a new hadoop user

# Function to log messages
log_message() {
    local message="$1"
    local level="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}"
}

# Function to install dependencies
install_dependencies() {
    log_message "Installing dependencies..." "INFO"
    
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y openjdk-8-jdk openssh-server openssh-client wget net-tools curl
}

# Function to configure SSH
configure_ssh() {
    log_message "Configuring SSH..." "INFO"
    
    sudo systemctl start ssh
    sudo systemctl enable ssh
    mkdir -p ~/.ssh && chmod 700 ~/.ssh

    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
    fi

    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
    ssh-keyscan -H localhost >> ~/.ssh/known_hosts
}

# Function to download and install Hadoop
install_hadoop() {
    log_message "Downloading and Installing Hadoop..." "INFO"
    
    wget "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
    tar -xzf "hadoop-${HADOOP_VERSION}.tar.gz"
    sudo mv "hadoop-${HADOOP_VERSION}" "$HADOOP_HOME"
    sudo chown -R "$USER:$USER" "$HADOOP_HOME"
    
    sudo mkdir -p "$HADOOP_HOME/hdfs/"{namenode,datanode}
    sudo chown -R "$USER:$USER" "$HADOOP_HOME/hdfs"
    chmod -R 755 "$HADOOP_HOME/hdfs"
}

# Function to configure environment
configure_environment() {
    log_message "Configuring environment variables..." "INFO"
    
    JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
    
    cat <<EOL | sudo tee /etc/profile.d/hadoop.sh
export HADOOP_HOME=$HADOOP_HOME
export JAVA_HOME=$JAVA_HOME
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOL

    source /etc/profile.d/hadoop.sh
    echo "source /etc/profile.d/hadoop.sh" >> ~/.bashrc
}

# Function to configure Hadoop settings
configure_hadoop() {
    log_message "Configuring Hadoop XML files..." "INFO"

    cat <<EOL > "$HADOOP_HOME/etc/hadoop/core-site.xml"
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>file://${HADOOP_HOME}/hdfs/tmp</value>
    </property>
</configuration>
EOL

    cat <<EOL > "$HADOOP_HOME/etc/hadoop/hdfs-site.xml"
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${HADOOP_HOME}/hdfs/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://${HADOOP_HOME}/hdfs/datanode</value>
    </property>
</configuration>
EOL
}

# Main function
main() {
    log_message "Starting Hadoop Installation..." "INFO"
    install_dependencies
    configure_ssh
    install_hadoop
    configure_environment
    configure_hadoop
    log_message "Hadoop installation completed successfully!" "INFO"
    echo -e "${GREEN}Hadoop Installation Complete!${NC}"
}

main "$@"
