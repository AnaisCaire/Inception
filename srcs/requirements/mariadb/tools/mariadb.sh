#!/bin/bash

# Ensure the script stops immediately if any command fails
set -e

# 1. Check if the database directory is already initialized
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "Initializing the database for the first time..."
    
    DB_ROOT_PWD=$(cat /run/secrets/db_root_password)
    DB_PWD=$(cat /run/secrets/db_password)

    # Set up the initial MariaDB data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB in the background temporarily so we can send SQL commands to it
    mysqld_safe --user=mysql &
    sleep 5 # Wait a few seconds for the daemon to fully start

    # Create the database using the environment variable
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    
    # Create the administrator user (must not contain 'admin') and grant full privileges
    mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${DB_PWD}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
    
    # Create the secondary standard user and grant limited privileges
    mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_SECONDARY_USER}\`@'%' IDENTIFIED BY '${DB_PWD}';"
    mysql -u root -e "GRANT SELECT, INSERT, UPDATE, DELETE ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_SECONDARY_USER}\`@'%';"

    # Secure the root user with the root password and flush privileges to save changes
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    # Shut down the temporary background process cleanly
    mysqladmin -u root -p"${DB_ROOT_PWD}" shutdown
    echo "Initial database setup completed."
fi

echo "Starting MariaDB daemon in the foreground..."
# 2. The PID 1 Handoff
exec mysqld_safe --user=mysql