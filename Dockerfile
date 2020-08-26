# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sookim <sookim@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/08/26 15:59:30 by sookim            #+#    #+#              #
#    Updated: 2020/08/26 16:57:18 by sookim           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt-get update 
RUN apt-get -y upgrade
RUN apt-get -y intsall nginx
RUN apt-get -y install openssl vim

# ssl 인증서 키 발급 : 새로운 증서요청을 발행하고 새로운 private 키 발급 4096 bits 수 365일 유효한 날짜

RUN openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Lee/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt
RUN mv localhost.dev.crt etc/ssl/certs/
RUN mv localhost.dev.key etc/ssl/private/
RUN	chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key
RUN	apt-get -y install php-fpm
RUN	echo "<?php phpinfo(); ?>" >> /var/www/html/phpinfo.php
RUN	apt-get -y install mariadb-server php-mysql
RUN	chown -R www-data:www-data /var/www/html/wordpress

COPY ./srcs/init_container.sh ./
COPY ./srcs/wordpress var/www/html/
COPY ./srcs/phpmyadmin /var/www/html/
COPY ./srcs/default etc/nginx/sites-available/default

CMD	bash sql_service.sh