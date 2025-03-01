FROM certbot/certbot:v3.2.0

VOLUME /etc/letsencrypt

COPY ./src/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT []
CMD /app/entrypoint.sh