# Experiment 2: Sqoop Data Transfer Guide

## Script Overview

`sqoop_install.sh` handles:
- MySQL and Sqoop installation
- Database configuration
- Data transfer operations
- Service verification

## Setup Instructions

### 1. Prerequisites

Ensure you have:
- Hadoop properly installed and running (refer experiment 1 files)
- Root access for MySQL installation
- Network access for package download
### 2. Make script executable
```bash
chmod +x sqoop.sh
```
### 3. Running the Script
*Just run this and you'll finish experiment*
```bash
./sqoop.sh
```


The script performs:
- Environment variable setup
- MySQL installation and configuration
- Sample database creation
- Various Sqoop operations

## Sqoop Operations Explained

### 1. Basic Import
```bash
# Import entire table
sqoop import \
--connect "jdbc:mysql://localhost:3306/emp?useSSL=false" \
--username root \
--password root \
--table Faculty \
--target-dir /user/$USER/Faculty
```

### 2. Conditional Import
```bash
# Import with WHERE clause
sqoop import \
--connect "jdbc:mysql://localhost:3306/emp?useSSL=false" \
--username root \
--password root \
--table Faculty \
--where "salary > 70000" \
--target-dir /user/$USER/Faculty_highsalary
```

### 3. Compressed Import
```bash
# Import with compression
sqoop import \
--connect "jdbc:mysql://localhost:3306/emp?useSSL=false" \
--username root \
--password root \
--table Faculty \
--compress \
--target-dir /user/$USER/Faculty_compressed
```

## Verification Steps

1. Check HDFS for imported data:
```bash
hdfs dfs -ls /user/$USER/Faculty
hdfs dfs -ls /user/$USER/Faculty_highsalary
hdfs dfs -ls /user/$USER/Faculty_compressed
```

2. Verify MySQL exports:
```bash
mysql -u root -proot -e "USE engineer; SELECT * FROM Faculty;"
```

## Troubleshooting

### Common Issues

1. **MySQL Connection Issues**
```bash
# Check MySQL service status
sudo service mysql status

# Restart MySQL
sudo service mysql restart
```

2. **Sqoop Import Failures**
```bash
# Check MySQL grants
mysql -u root -proot -e "SHOW GRANTS;"

# Verify table existence
mysql -u root -proot -e "USE emp; SHOW TABLES;"
```

3. **HDFS Permission Issues**
```bash
# Create and set permissions for HDFS directories
hdfs dfs -mkdir -p /user/$USER
hdfs dfs -chmod 755 /user/$USER
```

### Logs and Debugging

- Script logs: Check `sqoop_setup_[timestamp].log`
- MySQL logs: `/var/log/mysql/error.log`
- Sqoop logs: Check console output during operations

## Port Configuration

The script automatically handles port conflicts for:
- MySQL (default: 3306)
- Hadoop NameNode (default: 9870)
- YARN ResourceManager (default: 8088)

## Additional Resources

- [Sqoop User Guide](https://sqoop.apache.org/docs/1.4.7/SqoopUserGuide.html)
- [MySQL Documentation](https://dev.mysql.com/doc/)
