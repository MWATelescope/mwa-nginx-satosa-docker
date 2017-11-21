FROM nginx:stable

RUN apt-get update && apt-get install -y --no-install-recommends \
        netcat-openbsd 

RUN mkdir -p /opt/static

COPY static /opt/static/
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /usr/local/sbin/nginx-start.sh

ENTRYPOINT ["/usr/local/sbin/nginx-start.sh"]
