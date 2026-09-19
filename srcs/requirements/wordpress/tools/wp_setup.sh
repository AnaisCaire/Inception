#!/bin/bash

# Ensure the script stops immediately if any command fails
set -e

# Wait for MariaDB to be fully ready before trying to connect
echo "Waiting for MariaDB..."
while ! mariadb -h mariadb -u $MYSQL_USER -p"$(cat /run/secrets/db_password)" $MYSQL_DATABASE &>/dev/null; do
    sleep 2
done
echo "MariaDB is ready!"

# Only install if wp-config.php doesn't already exist in the persistent volume
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading and configuring WordPress..."
    wp core download --allow-root

    # Connect to the MariaDB container using the secrets
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$(cat /run/secrets/db_password) \
        --dbhost=mariadb:3306 \
        --allow-root

    # Install the core site and set up the Administrator
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception 42" \
        --admin_user=$MYSQL_USER \
        --admin_password=$(cat /run/secrets/credentials) \
        --admin_email="admin@$DOMAIN_NAME" \
        --allow-root

    # Create the mandatory secondary standard user
    wp user create $MYSQL_SECONDARY_USER "secondary@$DOMAIN_NAME" \
        --user_pass=$(cat /run/secrets/db_password) \
        --role=author \
        --allow-root
    
    echo "WordPress installed successfully."
fi

# Ensure correct permissions for the web server to read the files
chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM in the foreground..."
# Take over PID 1 to keep the container alive
exec /usr/sbin/php-fpm8.2 -F