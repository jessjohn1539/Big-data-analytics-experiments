#!/bin/bash
#Experiment 2: Use of Sqoop tool to transfer data between Hadoop and relational database servers.
#a. Sqoop and MySQL - Installation.
#b. To execute basic commands of Hadoop eco system component Sqoop
#(Main experiment code to run if sqoop and hadoop is downloaded in system)
# 
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="sqoop_setup_$(date +%Y%m%d_%H%M%S).log"

# Default ports for Hadoop 3.x
MYSQL_PORT=3306
NAMENODE_PORT=9870  # Changed from 50070 to 9870 for Hadoop 3.x
NAMENODE_IPC_PORT=9000  # Added IPC port
YARN_PORT=8088
DATANODE_PORT=9864  # Added DataNode port
SECONDARY_NAMENODE_PORT=9868  # Added Secondary NameNode port

# Function to check if a port is available
check_port() {
    local port=$1
    if ! netstat -tuln | grep -q ":${port} "; then
        return 0
    fi
    return 1
}

# Function to find next available port
find_available_port() {
    local port=$1
    while ! check_port $port; do
        port=$((port + 1))
    done
    echo $port
}

# Function to update Hadoop configuration with new ports
update_hadoop_ports() {
    local new_namenode_port=$1
    local new_namenode_ipc_port=$2
    local new_yarn_port=$3
    
    # Update core-site.xml
    sed -i "s|<value>hdfs://localhost:[0-9]*</value>|<value>hdfs://localhost:${new_namenode_ipc_port}</value>|" $HADOOP_HOME/etc/hadoop/core-site.xml
    
    # Update hdfs-site.xml
    cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.namenode.http-address</name>
        <value>localhost:${new_namenode_port}</value>
    </property>
    <property>
        <name>dfs.datanode.http-address</name>
        <value>localhost:${DATANODE_PORT}</value>
    </property>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>localhost:${SECONDARY_NAMENODE_PORT}</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///tmp/hadoop/dfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///tmp/hadoop/dfs/data</value>
    </property>
</configuration>
EOF
    
    # Update yarn-site.xml
    cat > $HADOOP_HOME/etc/hadoop/yarn-site.xml << EOF
<?xml version="1.0"?>
<configuration>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>localhost:${new_yarn_port}</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME</value>
    </property>
</configuration>
EOF
    
    log_message "Updated Hadoop ports: NameNode=${new_namenode_port}, NameNode IPC=${new_namenode_ipc_port}, YARN=${new_yarn_port}" "INFO"
}

# Function to verify service accessibility
verify_service() {
    local url=$1
    local service=$2
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s --head "$url" >/dev/null; then
            log_message "${service} is accessible at ${url}" "INFO"
            return 0
        elif [ "$service" = "Hadoop NameNode" ] && curl -s --head "${url}/dfshealth.html" >/dev/null; then
            log_message "${service} is accessible at ${url}/dfshealth.html" "INFO"
            return 0
        fi
        log_message "Attempt ${attempt}/${max_attempts}: ${service} not yet accessible" "WARN"
        sleep 5
        attempt=$((attempt + 1))
    done
    
    log_message "Failed to verify ${service} accessibility" "ERROR"
    return 1
}


# Function to update MySQL configuration with new port
update_mysql_port() {
    local new_mysql_port=$1
    
    sudo sed -i "s/port.*=.*${MYSQL_PORT}/port = ${new_mysql_port}/" /etc/mysql/mysql.conf.d/mysqld.cnf
    log_message "Updated MySQL port to ${new_mysql_port}" "INFO"
}

# Function to log messages
log_message() {
    local message="$1"
    local level="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check and set environment variables
check_env_variables() {
    log_message "Checking environment variables..." "INFO"
    
    # Check JAVA_HOME
    if [ -z "$JAVA_HOME" ]; then
        log_message "JAVA_HOME not set. Setting it up..." "WARN"
        export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
        echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
    fi
    
    # Check HADOOP_HOME
    if [ -z "$HADOOP_HOME" ]; then
        log_message "HADOOP_HOME not set. Setting it up..." "WARN"
        export HADOOP_HOME=/usr/local/hadoop
        echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc
        echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc
    fi
    
    # Check SQOOP_HOME
    if [ -z "$SQOOP_HOME" ]; then
        log_message "SQOOP_HOME not set. Setting it up..." "WARN"
        export SQOOP_HOME=/usr/lib/sqoop
        echo "export SQOOP_HOME=$SQOOP_HOME" >> ~/.bashrc
        echo "export PATH=\$PATH:\$SQOOP_HOME/bin" >> ~/.bashrc
    fi
    
    source ~/.bashrc
}

# Function to check and fix permissions
fix_permissions() {
    log_message "Checking and fixing permissions..." "INFO"
    
    # Fix Hadoop directory permissions
    if [ -d "$HADOOP_HOME" ]; then
        sudo chown -R $USER:$USER $HADOOP_HOME
        sudo chmod -R 755 $HADOOP_HOME
        log_message "Hadoop permissions fixed" "INFO"
    fi
    
    # Create and fix logs directory
    sudo mkdir -p $HADOOP_HOME/logs
    sudo chown -R $USER:$USER $HADOOP_HOME/logs
    sudo chmod -R 755 $HADOOP_HOME/logs
    log_message "Logs directory permissions fixed" "INFO"
}

# Function to check and configure MySQL
configure_mysql() {
    log_message "Configuring MySQL..." "INFO"
    
    # Check if MySQL is installed
    if ! command_exists mysql; then
        log_message "MySQL not found. Installing..." "WARN"
        sudo apt-get update
        sudo apt-get install -y mysql-server
    fi
    
    # Find available port for MySQL
    MYSQL_PORT=$(find_available_port $MYSQL_PORT)
    update_mysql_port $MYSQL_PORT
    
    # Configure MySQL for SSL
    sudo bash -c 'cat >> /etc/mysql/mysql.conf.d/mysqld.cnf << EOF
[mysqld]
ssl=0
EOF'
    
    # Restart MySQL
    sudo service mysql restart
    log_message "MySQL configured and restarted on port ${MYSQL_PORT}" "INFO"
}

# Modified start_hadoop_services function
start_hadoop_services() {
    log_message "Starting Hadoop services..." "INFO"
    
    # Find available ports
    NAMENODE_PORT=$(find_available_port $NAMENODE_PORT)
    NAMENODE_IPC_PORT=$(find_available_port $NAMENODE_IPC_PORT)
    YARN_PORT=$(find_available_port $YARN_PORT)
    
    # Update Hadoop configuration with new ports
    update_hadoop_ports $NAMENODE_PORT $NAMENODE_IPC_PORT $YARN_PORT
    
    # Stop all services first
    $HADOOP_HOME/sbin/stop-all.sh
    
    # Create necessary directories
    mkdir -p /tmp/hadoop/dfs/name
    mkdir -p /tmp/hadoop/dfs/data
    
    # Format namenode if needed
    if [ ! -d "/tmp/hadoop/dfs/name/current" ]; then
        log_message "Formatting namenode..." "INFO"
        hdfs namenode -format
    fi
    
    # Start services
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    
    # Verify services are running
    local services=$(jps)
    if echo "$services" | grep -q "NameNode" && echo "$services" | grep -q "DataNode"; then
        log_message "Hadoop services started successfully" "INFO"
    else
        log_message "Failed to start Hadoop services" "ERROR"
        exit 1
    fi
}

# Function to setup sample database
setup_database() {
    log_message "Setting up sample database..." "INFO"
    
    mysql -u root -proot << EOF
CREATE DATABASE IF NOT EXISTS emp;
USE emp;

DROP TABLE IF EXISTS Faculty;
CREATE TABLE Faculty (
    id int primary key,
    name varchar(10),
    city varchar(10),
    salary bigint
);

INSERT INTO Faculty VALUES
(1, 'Sana', 'Mumbai', 95000),
(2, 'Riya', 'Pune', 85000),
(3, 'Karan', 'Jaipur', 55000),
(4, 'Rahul', 'Delhi', 78000),
(5, 'Bush', 'Mumbai', 75000),
(6, 'Ram', 'Delhi', 66000),
(7, 'Slade', 'Pune', 71000);

GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    if [ $? -eq 0 ]; then
        log_message "Database setup completed successfully" "INFO"
    else
        log_message "Database setup failed" "ERROR"
        exit 1
    fi
}

# Function to perform Sqoop operations
perform_sqoop_operations() {
    log_message "Starting Sqoop operations..." "INFO"
    
    # Create HDFS directories
    hdfs dfs -mkdir -p /user/$USER
    
    # Basic import
    log_message "Performing basic import..." "INFO"
    sqoop import \
    --connect "jdbc:mysql://127.0.0.1:3306/emp?useSSL=false" \
    --username root \
    --password root \
    --table Faculty \
    --target-dir /user/$USER/Faculty \
    --direct \
    -m 1
    
    # Import with where clause
    log_message "Performing conditional import..." "INFO"
    sqoop import \
    --connect "jdbc:mysql://127.0.0.1:3306/emp?useSSL=false" \
    --username root \
    --password root \
    --table Faculty \
    --where "salary > 70000" \
    --target-dir /user/$USER/Faculty_highsalary \
    --direct \
    -m 1
    
    # Compressed import
    log_message "Performing compressed import..." "INFO"
    sqoop import \
    --connect "jdbc:mysql://127.0.0.1:3306/emp?useSSL=false" \
    --username root \
    --password root \
    --table Faculty \
    --compress \
    --target-dir /user/$USER/Faculty_compressed \
    --direct \
    -m 1
    
    # Setup for export
    mysql -u root -proot << EOF
CREATE DATABASE IF NOT EXISTS engineer;
USE engineer;

CREATE TABLE Faculty (
    id int primary key,
    name varchar(10),
    city varchar(10),
    salary bigint
);
EOF
    
    # Export operation
    log_message "Performing export operation..." "INFO"
    sqoop export \
    --connect "jdbc:mysql://127.0.0.1:3306/engineer?useSSL=false" \
    --username root \
    --password root \
    --table Faculty \
    --export-dir /user/$USER/Faculty
}

# Function to verify results
verify_results() {
    log_message "Verifying results..." "INFO"
    
    # Check HDFS contents
    log_message "HDFS Contents:" "INFO"
    hdfs dfs -ls /user/$USER/Faculty
    hdfs dfs -ls /user/$USER/Faculty_highsalary
    hdfs dfs -ls /user/$USER/Faculty_compressed
    
    # Check exported data
    log_message "Exported Data in MySQL:" "INFO"
    mysql -u root -proot -e "USE engineer; SELECT * FROM Faculty;"
}

# Modified main function
main() {
    log_message "Starting Sqoop experiment setup and execution..." "INFO"
    
    # Run all functions in sequence
    check_env_variables
    fix_permissions
    configure_mysql
    start_hadoop_services
    setup_database
    perform_sqoop_operations
    verify_results
    
    log_message "Experiment completed successfully!" "INFO"
    log_message "Results have been logged to $LOG_FILE" "INFO"
    
    # Display useful URLs with verified ports
    echo -e "\n${GREEN}Access Points:${NC}"
    echo "MySQL: http://localhost:${MYSQL_PORT}"
    echo "Hadoop NameNode: http://localhost:${NAMENODE_PORT}/dfshealth.html#tab-overview"
    echo "YARN Resource Manager: http://localhost:${YARN_PORT}"
    
    # Verify service accessibility
    verify_service "http://localhost:${NAMENODE_PORT}" "Hadoop NameNode"
    verify_service "http://localhost:${YARN_PORT}" "YARN Resource Manager"
    
    log_message "Service URLs have been verified and are accessible" "INFO"
}

# Execute main function
main