# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sookim <sookim@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/08/26 15:59:30 by sookim            #+#    #+#              #
#    Updated: 2020/08/26 18:03:48 by sookim           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install nginx
RUN apt-get -y install openssl vim

# 인증서 키 발급 4096비트 크기 365일 유효 회사명 파밀명 저장
RUN openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Lee/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt
RUN mv localhost.dev.crt etc/ssl/certs/
RUN mv localhost.dev.key etc/ssl/private/
RUN	chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key
RUN	apt-get -y install php-fpm
RUN	echo "<?php phpinfo(); ?>" >> /var/www/html/phpinfo.php
RUN	apt-get -y install mariadb-server php-mysql
RUN	apt-get install -y wget
RUN	wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz
RUN	tar -xvf phpMyAdmin-5.0.2-all-languages.tar.gz
RUN	mv phpMyAdmin-5.0.2-all-languages phpmyadmin
RUN	mv phpmyadmin /var/www/html/
RUN	cp -rp var/www/html/phpmyadmin/config.sample.inc.php var/www/html/phpmyadmin/config.inc.php
RUN	wget https://wordpress.org/latest.tar.gz
RUN	tar -xvf latest.tar.gz
RUN	mv wordpress/ var/www/html/
RUN	chown -R www-data:www-data /var/www/html/wordpress
RUN	cp var/www/html/wordpress/wp-config-sample.php var/www/html/wordpress/wp-config.php

COPY ./srcs/sql_service.sh ./
COPY ./srcs/config.inc.php var/www/html/phpmyadmin/config.inc.php
COPY ./srcs/default etc/nginx/sites-available/default
COPY ./srcs/wp-config.php var/www/html/wordpress/wp-config.php

CMD	bash sql_service.sh