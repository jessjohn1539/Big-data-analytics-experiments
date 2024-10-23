#!/bin/bash
# install_pig.sh - Run this script once to install and configure Apache PIG

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Create installation directory
mkdir -p /usr/local/pig

# Download and install PIG
echo "Downloading Apache PIG..."
wget https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz
tar -xzf pig-0.17.0.tar.gz
mv pig-0.17.0/* /usr/local/pig/
rm -rf pig-0.17.0 pig-0.17.0.tar.gz

# Configure environment variables
echo "Configuring environment variables..."
echo "export PIG_HOME=/usr/local/pig" >> /etc/profile.d/pig.sh
echo "export PATH=\$PATH:\$PIG_HOME/bin" >> /etc/profile.d/pig.sh
chmod +x /etc/profile.d/pig.sh

echo "Installation complete! Please log out and log back in for changes to take effect."
echo "Verify installation by running: pig --version"