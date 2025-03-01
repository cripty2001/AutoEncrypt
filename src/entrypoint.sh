#!/bin/sh
set -e;
trap exit TERM

# Printing env var
echo "DOMAIN: $DOMAIN";
echo "EMAIL: $EMAIL";

# Checking if domain and email are set
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  echo "DOMAIN and EMAIL env vars are required";
  exit 1;
fi

savecert() {
  cp "/tmp/privkey.pem" "/mnt/certs/privkey.pem"
  cp "/tmp/fullchain.pem" "/mnt/certs/fullchain.pem"
  cat "/tmp/privkey.pem" "/tmp/fullchain.pem" > "/mnt/certs/bundle.pem"
}

# Linking acme challenge to mnt/acme
mkdir -p /tmp/acme/.well-known
if [ ! -L /tmp/acme/.well-known/acme-challenge ]; then
  mkdir -p /mnt/acme
  ln -s /mnt/acme /tmp/acme/.well-known/acme-challenge;
fi

while true; do
  if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "Generating a self-signed certificate for $DOMAIN";
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /tmp/privkey.pem \
      -out /tmp/fullchain.pem \
      -subj "/CN=$DOMAIN";

    savecert;

  fi;

  echo "Renewing certificate for $DOMAIN";

  # Generating/renewing certificate
  certbot certonly \
    -v \
    --webroot \
    --webroot-path="/tmp/acme" \
    -d "$DOMAIN" \
    -m "$EMAIL" \
    --agree-tos \
    --non-interactive;
    # --dry-run;

  # Saving certificate
  cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /tmp/privkey.pem
  cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /tmp/fullchain.pem

  # Exporting certificate
  savecert;

  # It is useless to run certbot continuously (we still need to handle the trapped signal)
  sleep 3600 & wait $!;
done
