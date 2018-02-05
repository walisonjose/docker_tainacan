#e an official Python runtime as a parent image
FROM ubuntu:16.04

ENV path="/var/www/html"

#Configs. Apache

ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"
ENV APACHE_LOG_DIR="/var/log/apache2"

COPY .  /files/

RUN apt-get update \
 && apt-get install -y wget nmap php7.0 php7.0-mysql php7.0-fpm php-xml php-mbstring php7.0-mcrypt libapache2-mod-php7.0 php7.0-cli php7.0-curl apache2 curl mysql-client git vim \
 && a2enmod rewrite \ 
 && cp  /files/apache2.conf /etc/apache2/ \
 && cp  /files/.htaccess /var/www/html \
 && apachectl restart  \
 # Instalando o wp-cli
 && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp \  
 #Baixando o Wordpress e o Tainacan
 && chown -R www-data:www-data $path \
 && wp --allow-root core download --path="$path" \
 && cp  /files/wp-config.php $path \
 && chmod 644 $path/wp-config.php \
 && rm -r $path/index.html \
#Clonando o tema do Tainacan
 && git clone https://github.com/medialab-ufg/tainacan.git $path/wp-content/themes/tainacan/ 
 
EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
