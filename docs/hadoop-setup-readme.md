# Experiment 1: Hadoop Installation and Setup Guide

## Scripts Overview

1. `hadoop_install.sh`: Handles the initial installation of Hadoop and its dependencies
2. `hadoop_setup.sh`: Manages Hadoop services and provides operational commands

## Installation Steps
### 1. Make scripts executable
```bash
chmod +x hadoop_install.sh
chmod +x hadoop_setup.sh 
```

### 2. Running the Installation Script
*Just run this and you'll finish experiment*
```bash
./hadoop_install.sh
```

The script will:
- Install required dependencies
- Configure SSH
- Download and install Hadoop
- Set up environment variables
- Configure Hadoop settings

### 3. Service Management

Use the setup script to manage Hadoop services:

```bash
# Start Hadoop services
./hadoop_setup.sh start

# Check service status
./hadoop_setup.sh status

# Stop Hadoop services
./hadoop_setup.sh stop
```

## Verification

1. Check if Hadoop is properly installed:
```bash
hadoop version
```

2. Verify HDFS is working:
```bash
hdfs dfs -ls /
```

3. Access Web Interfaces:
- NameNode: http://localhost:9870
- YARN Resource Manager: http://localhost:8088

## Troubleshooting

### Common Issues

1. **SSH Connection Problems**
   ```bash
   # Regenerate SSH keys
   rm -rf ~/.ssh
   ./hadoop_install.sh
   ```

2. **Port Conflicts**
   ```bash
   # Check if ports are in use
   netstat -tuln | grep "9000\|9870\|8088"
   ```

3. **Permission Issues**
   ```bash
   # Fix HDFS permissions
   sudo chown -R $USER:$USER $HADOOP_HOME
   sudo chmod -R 755 $HADOOP_HOME
   ```

4. **HDFS Safe Mode**
   ```bash
   # Leave safe mode
   hdfs dfsadmin -safemode leave
   ```

### Logs Location

- Hadoop Logs: `$HADOOP_HOME/logs/`
- Installation Log: Check terminal output during installation

## Additional Resources

- [Apache Hadoop Documentation](https://hadoop.apache.org/docs/current/)
- [Hadoop Commands Guide](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/CommandsManual.html)
