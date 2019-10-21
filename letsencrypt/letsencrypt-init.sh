#!/usr/bin/env bash

REPO_DIR=$(pwd)
CERTS=${REPO_DIR}/certs
CERTS_DATA=${REPO_DIR}/certs-data

# DOMAIN_NAME should not include prefix of www.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 DOMAIN_NAME" >&2
    exit 1;
else
    DOMAIN_NAME=$1
fi

WILD_DOMAIN_NAME="*.${DOMAIN_NAME}"

echo "Domain: ${DOMAIN_NAME}"
echo "Wildcard Domain: ${WILD_DOMAIN_NAME}"

if [ ! -d "${CERTS}" ]; then
    echo "INFO: making certs directory"
    mkdir ${CERTS}
fi

if [ ! -d "${CERTS_DATA}" ]; then
    echo "INFO: making certs-data directory"
    mkdir ${CERTS_DATA}
fi

docker run -it --rm \
    -v ${CERTS}:/etc/letsencrypt \
    -v ${CERTS_DATA}:/data/letsencrypt \
    certbot/certbot \
    certonly \
    --manual --preferred-challenges dns \
    --manual-public-ip-logging-ok \
    -d ${WILD_DOMAIN_NAME} -d ${DOMAIN_NAME}

echo "INFO: update the nginx config file"
echo "-  4:    server_name ${DOMAIN_NAME};"
echo "- 19:    server_name               ${DOMAIN_NAME};"
echo "- 46:    ssl_certificate           /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;"
echo "- 47:    ssl_certificate_key       /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;"
echo "- 48:    ssl_trusted_certificate   /etc/letsencrypt/live/${DOMAIN_NAME}/chain.pem;"

exit 0;
