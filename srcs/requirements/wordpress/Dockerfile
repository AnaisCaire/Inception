FROM debian:bookworm

# Install PHP-FPM, MySQL extensions, and required tools
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download and install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create the directory required by PHP-FPM to run
RUN mkdir -p /run/php

# Copy the internal routing config and setup script
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh

RUN chmod +x /usr/local/bin/wp_setup.sh

# Expose the FastCGI port for NGINX to connect to
EXPOSE 9000

# Set the working directory to the mounted volume path
WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]