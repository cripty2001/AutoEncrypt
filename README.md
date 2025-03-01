```
services:
    certbot:
        image: cripty2001/autoencrypt
        restart: unless-stopped
        environment:
        - EMAIL=<!!! TODO REPLACE !!!>
        - DOMAIN=<!!! TODO REPLACE !!!>
        volumes:
        - certs:/mnt/certs
        - acme:/mnt/acme
volumes:
  certs:
  acme:
```

NOTE: TOS will be accepted automatically

EMAIL is the email required by letsencrypt
DOMAIN is the domain to issue certificate for

certs will contain

- privkey.pem The private key in pem format
- fullchain.pem The letsencrypt fullchain
- bundle.pem The concat of privatekey and fullchain (required by some applications...)

acme will contain the acme challenges and should be mounded directly to the `.well-known/acme-challenge` on the server (`acme:/usr/share/icecast/web/.well-known/acme-challenge`)
