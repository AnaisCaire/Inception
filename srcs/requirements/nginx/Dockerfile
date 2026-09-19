FROM debian:bookworm

# Install NGINX and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl

# Create a secure directory for the TLS certificates
RUN mkdir -p /etc/nginx/ssl

# Generate the self-signed TLS certificate directly during the build
RUN openssl req -x509 -nodes \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=42/CN=acaire-d.42.fr/UID=acaire-d"


#  explanation:
# openssl req: Initiates the OpenSSL certificate request management tool.

# -x509: Tells OpenSSL to immediately output a self-signed public certificate
#        rather than just a certificate request.

# -nodes: Stands for "No DES" (No encryption). 
#         This ensures the private key is generated without a password prompt. 
#         If it required a password, your automated Docker build would freeze forever 
#         waiting for human input.

#  -out: the exact path where the public certificate (.crt) will be saved inside the container.

# -keyout: the exact path where the secret private key (.key) will be saved inside the container.

# -subj "...": Automatically fills in the Subject identity data 
#  (Country, State, Locality, Organization, Common Name, User ID)

# Copy the custom configuration
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Start NGINX in the foreground to maintain PID 1
CMD ["nginx", "-g", "daemon off;"]