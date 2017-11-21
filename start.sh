#!/usr/bin/env bash

# exit immediately on failure
set -e

# Configuration details that may be injected through environment
# variables or the contents of files.

injectable_config_vars=( 
    SATOSA_HOST
    SATOSA_PORT
)

# Default values.
SATOSA_HOST="satosa"
SATOSA_PORT="8080"

# If the file associated with a configuration variable is present then 
# read the value from it into the appropriate variable. 

for config_var in "${injectable_config_vars[@]}"
do
    eval file_name=\$"${config_var}_FILE";

    if [ -e "$file_name" ]; then
        declare "${config_var}"=`cat $file_name`
    fi
done

# Copy HTTPS certificate and key into place.
if [ -n "${NGINX_HTTPS_CERT_FILE}" ] && [ -n "${NGINX_HTTPS_KEY_FILE}" ]; then
    cp "${NGINX_HTTPS_CERT_FILE}" /etc/nginx/https.crt
    cp "${NGINX_HTTPS_KEY_FILE}" /etc/nginx/https.key
    chmod 644 /etc/nginx/https.crt
    chmod 600 /etc/nginx/https.key
    chown nginx /etc/nginx/https.key
fi

# Copy DH parameters for EDH ciphers into place
if [ -n "${NGINX_DH_PARAM_FILE}" ]; then
    cp "${NGINX_DH_PARAM_FILE}" /etc/nginx/dhparam.pem
    chmod 600 /etc/nginx/dhparam.pem
    chown nginx /etc/nginx/dhparam.pem
fi

# Wait for the SATOSA container to be ready.
until nc -z -w 1 "${SATOSA_HOST}" "${SATOSA_PORT}"
do
    echo "Waiting for SATOSA container..."
    sleep 1
done

# Start nginx.
exec nginx -g 'daemon off;'
