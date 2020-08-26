# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sookim <sookim@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/08/26 15:59:30 by sookim            #+#    #+#              #
#    Updated: 2020/08/26 17:38:11 by sookim           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install nginx
RUN apt-get -y install openssl vim
RUN openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Lee/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt
RUN mv localhost.dev.crt etc/ssl/certs/
RUN mv localhost.dev.key etc/ssl/private/
RUN	chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key
RUN	apt-get -y install php-fpm
RUN	echo "<?php phpinfo(); ?>" >> /var/www/html/phpinfo.php
RUN	apt-get -y install mariadb-server php-mysql
COPY ./srcs/phpmyadmin ./
RUN		tar -xvf phpmyadmin.tar.gz
RUN		mv phpmyadmin /var/www/html/
RUN		cp -rp var/www/html/phpmyadmin/config.sample.inc.php var/www/html/phpmyadmin/config.inc.php
COPY    ./srcs/wordpress ./
RUN		tar -xvf wordpress.tar.gz
RUN		mv wordpress/ var/www/html/
RUN		chown -R www-data:www-data /var/www/html/wordpress
RUN		cp var/www/html/wordpress/wp-config-sample.php var/www/html/wordpress/wp-config.php

COPY ./srcs/sql_service.sh ./
COPY ./srcs/config.inc.php var/www/html/phpmyadmin/config.inc.php
COPY ./srcs/default etc/nginx/sites-available/default
COPY ./srcs/wp-config.php var/www/html/wordpress/wp-config.php

CMD	bash sql_service.sh