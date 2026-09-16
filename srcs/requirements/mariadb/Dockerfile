FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

EXPOSE 3306

# Copy the configuration script into the image
COPY tools/mariadb.sh /usr/local/bin/mariadb.sh

# Make the script executable
RUN chmod +x /usr/local/bin/mariadb.sh

# Define the script as the default command to run when the container starts
ENTRYPOINT ["/usr/local/bin/mariadb.sh"]