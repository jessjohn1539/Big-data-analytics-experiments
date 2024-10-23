#!/bin/bash
echo "Setting up MongoDB..."

# Add the MongoDB GPG key and official MongoDB repository
sudo apt-get update
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Add MongoDB repository to sources list
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update package lists again
sudo apt-get update

# Install MongoDB and mongosh (new shell)
sudo apt-get install -y mongodb-org mongodb-mongosh

# Start MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod

# Wait a moment for MongoDB to start
sleep 5

# Create test database and collection using mongosh
mongosh << 'EOL'
use testdb
db.createCollection("testcollection")
db.testcollection.insertOne({name: "test", value: 1})
db.testcollection.find()
EOL

echo "MongoDB setup completed!"
echo "To access MongoDB shell, use the command: mongosh"
echo "Then run these queries to check the changes:"
echo "use testdb"
echo "db.testcollection.find().pretty()"