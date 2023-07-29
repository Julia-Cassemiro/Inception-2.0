FROM debian:bullseye

RUN apt-get update \
	&& apt-get install -y \
	nginx \
	openssl

COPY ./conf/nginx.conf /etc/nginx/sites-available/default
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default

EXPOSE 443

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt \
	-subj "/C=BR/ST=SP/L=SP/O=42sp/CN=jgomes-c.42.fr"

CMD ["nginx", "-g", "daemon off;"]