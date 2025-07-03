#!/bin/bash

# Read and replace password of web_data from Docker secret
if [ ! -f /run/secrets/db_web_data_password ]; then
    echo "Error: web_data_password secret not found."
    exit 1
fi
DB_WEB_DATA_PASSWORD=$(cat /run/secrets/db_web_data_password)
ESCAPED_PASSWORD=$(echo "$DB_WEB_DATA_PASSWORD" | sed -e 's/[\/&]/\\&/g')

sed -i "s/PLACEHOLDER_PASSWORD/$ESCAPED_PASSWORD/" /docker-entrypoint-initdb.d/1-web_data.sql

echo "test database web_data initialized with provided password."