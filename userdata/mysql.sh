#!/bin/bash
DATABASE_PASS='admin123'

# Update the system
sudo yum update -y

# Install necessary tools and packages
sudo yum install git zip unzip -y

# Search for available MariaDB packages (modify as needed for your environment)
sudo yum search mariadb

# Install MariaDB (assuming version 10.5 is available; adjust based on the search results)
sudo yum install mariadb105-server -y

# Starting and enabling the MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Clone the project from GitHub
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# Secure MariaDB installation
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS';"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"

# Create the 'accounts' database and grant privileges
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts;"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"

# Restart the MariaDB service
sudo systemctl restart mariadb

# Enable and configure the firewall to allow access to MariaDB on port 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload

# Final restart of MariaDB
sudo systemctl restart mariadb
