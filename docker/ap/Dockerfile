FROM php:${PHP_VERSION:-8.2}-${SERVER:-apache}

WORKDIR /var/www/html
COPY ./docker/ap/pam.d/chsh /etc/pam.d/chsh
RUN chsh -s /usr/bin/bash www-data

# Install extensions.
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN apt update -y
RUN apt install -y git unzip zip vim default-mysql-client
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions xdebug
RUN docker-php-ext-install mysqli pdo pdo_mysql && \
    docker-php-ext-enable mysqli pdo pdo_mysql

# Install composer and wp-cli.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Set up private root ca and self signed server cert.
RUN mkdir -p /etc/apache2/ssl/root-ca && \
    cd /etc/apache2/ssl/root-ca && \
    mkdir certs db private && \
    chmod 700 private && \
    touch db/index && \
    mkdir ../certs && \
    openssl rand -hex 16 > db/serial

COPY ./docker/ap/openssl/root-ca.conf /etc/apache2/ssl/root-ca/root-ca.conf
COPY ./docker/ap/openssl/sign-server.conf /etc/apache2/ssl/root-ca/sign-server.conf
COPY ./docker/ap/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./docker/ap/bin/wp-launch.sh /var/www/bin/wp-launch.sh
RUN chown -R www-data:www-data /var/www && chmod +x /var/www/bin/wp-launch.sh

RUN cd /etc/apache2/ssl/root-ca && \
    openssl req -new -config root-ca.conf -out root-ca.csr -keyout private/root-ca.key && \
    openssl ca -selfsign -config root-ca.conf -in root-ca.csr -out root-ca.crt -extensions req_ext -batch && \
    openssl genrsa -out ../certs/server.key 2048 && \
    openssl req -new -key ../certs/server.key -out ../certs/server.csr -subj "/C=JP/ST=Tokyo/L=Chuoh-ku/O=Development/CN=localhost" -addext "subjectAltName=DNS:localhost" && \
    openssl ca -config sign-server.conf -in ../certs/server.csr -out ../certs/server.crt -extensions server_ext -batch

RUN a2enmod ssl && \
    a2enmod rewrite && \
    service apache2 restart
