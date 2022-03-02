FROM php:8.0-fpm-bullseye

WORKDIR /var/www/html

# Install base packages and repositories
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" > /etc/apt/sources.list.d/ansible.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-get update \
    && apt-get install -y gnupg mariadb-client libicu-dev libpq-dev libzip-dev postgresql-client unzip wget zip zlib1g-dev ansible ansible-core ansible-lint

RUN echo 'memory_limit=256M' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install php packages
RUN docker-php-ext-install intl opcache pdo_mysql pdo_pgsql zip
RUN pecl install pcov xdebug \
    && docker-php-ext-enable pcov xdebug

# # Configure xdebug but do not enable it (to enable add it conf.d in same path)
# RUN rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# ADD docker-php-ext-xdebug.ini /usr/local/etc/php/docker-php-ext-xdebug.ini

COPY install_composer.sh install_composer.sh
RUN sh install_composer.sh \
    && mv composer.phar /usr/local/bin/composer

RUN wget https://github.com/fabpot/local-php-security-checker/releases/download/v1.2.0/local-php-security-checker_1.2.0_linux_amd64 \
    && chmod +x local-php-security-checker_1.2.0_linux_amd64 \
    && mv local-php-security-checker_1.2.0_linux_amd64 /usr/local/bin/local-php-security-checker