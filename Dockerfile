#e an official Python runtime as a parent image
FROM ubuntu:16.04

ENV path="/var/www/html"
ENV url="localhost"

#Configs. Apache

ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"
ENV APACHE_LOG_DIR="/var/log/apache2"

COPY ./files/  /files/


USER root
RUN  apt-get update \
 && apt-get install -y sudo  cron phpunit composer ruby ruby-dev npm   wget nmap php7.0 php7.0-mysql php7.0-fpm php-xml php-mbstring  php7.0-gd php-imagick  php7.0-mcrypt libapache2-mod-php7.0 php7.0-cli php7.0-curl apache2 curl mysql-client git vim \
 && a2enmod rewrite \ 
 && a2enmod ssl \
 && apachectl restart  \
 && cp  /files/apache2.conf /etc/apache2/ \
 && cp  /files/.htaccess /var/www/html \
 && cp  /files/000-default.conf /etc/apache2/sites-available/ \
 && apachectl restart  \
 # Instalando o wp-cli
 && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp \  
 #Baixando o Wordpress e o Tainacan
 && chown -R www-data:www-data $path \
 && wp --allow-root core download --path="$path" \
 && rm -r $path/index.html \

#Compilando e instalando o plugin e o tema do Tainacan
#Plugin do Tainacan
#Instalando as depenências necessárias
&& curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - \
&& sudo apt-get install -y nodejs \
## To install the Yarn package manager, run:
&& curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
&& apt-get update && apt-get install yarn \


#Compilando e instalando o plugin
&& cd /var/www/html/wp-content/plugins/ \
&& wget https://downloads.wordpress.org/plugin/tainacan.zip \
&& unzip tainacan.zip \
&& chown -R www-data:www-data /var/www/html/wp-content/plugins/ \


#Tema do Tainacan
#Instalando e configurando o tema do Tainacan
&& git clone https://github.com/tainacan/tainacan-theme.git /files/tainacan-theme \
&& cd /files/tainacan-theme \
&& git checkout develop \
&& cp /files/confs_theme/build-config.cfg /files/tainacan-theme/ \
&& gem install sass \
&& ./build.sh \
&& chown -R www-data:www-data /var/www/html/wp-content/themes/ \

#Habilitando o diretório uploads da instalação Wordpress
&& mkdir /var/www/html/wp-content/uploads \ 

# Agendando a rotina de atualização e execução do build do tema e do plugin do Tainacan..
&& crontab /files/crontab/crontab.txt \
&& /etc/init.d/cron restart \

#Habilitando um álias para o comando de atualização e execução manual do build do tema e do plugin do Tainacan 
&& echo "alias build_tainacan='sh /files/crontab/atualiza_novo_tainacan.sh'" >> /etc/bash.bashrc  \

#Configurando o acesso SSL através do Let"s Encrypt
# && git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt \
#&& cd /opt/letsencrypt \
#&& sh letsencrypt certonly --webroot -w $path -d $url \
&& apachectl restart
 
EXPOSE 80
EXPOSE 443

CMD ["/bin/mkdir", "/teste"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
