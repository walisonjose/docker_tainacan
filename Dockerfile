#e an official Python runtime as a parent image
FROM ubuntu:16.04

ENV title="Tainacan Site"
ENV admin_name="admin"
ENV admin_email="voce@exemplo.com"
ENV admin_password="12345"

#dados do Banco 
ENV dbhost="bd_tainacan"
ENV dbname="wordpress"
ENV dbuser="wordpress"
ENV dbpass="wordpress"
ENV path="/var/www/html"

#Configs. Apache

ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"
ENV APACHE_LOG_DIR="/var/log/apache2"

COPY .  /files/

RUN apt-get update \
&& apt-get install -y php7.0 php7.0-mysql php7.0-fpm php-xml php-mbstring php7.0-mcrypt libapache2-mod-php7.0 php7.0-cli php7.0-curl apache2 curl mysql-client git vim \
 && a2enmod rewrite \ 
 && cp  /files/apache2.conf /etc/apache2/ \
 && cp  /files/.htaccess /var/www/ \
 && apachectl restart \ 
 # Instalando o wp-cli
 && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp \
#Instalando o Wordpress e o Tainacan
&& wp --allow-root core download --path="$path" \
&& wp --allow-root  core config --path="$path" --dbhost=$dbhost --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass\
&& chmod 644 $path/wp-config.php\
&& wp --allow-root core install --path="$path" --url=localhost --title="$title" --admin_name=$admin_name --admin_password=$admin_password  --admin_email=$admin_email --skip-email \
&& rm -r $path/index.html \
#Clonando e ativando o tema do Tainacan
&& git clone https://github.com/medialab-ufg/tainacan.git $path/wp-content/themes/tainacan/ \
&& wp --allow-root theme --path="$path" activate tainacan 

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]


#RUN apachectl etart 
