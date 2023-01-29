FROM php:8.1-fpm-bullseye

WORKDIR /var/www/html

# Install base packages and repositories
RUN apt-get update \
    && apt-get install -y git gnupg mariadb-client libicu-dev libfreetype6-dev libjpeg-dev libpng-dev libpq-dev libzip-dev postgresql-client unzip wget zip zlib1g-dev gnupg2 rsync

# Install ansible    
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" > /etc/apt/sources.list.d/ansible.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-get update \
    && apt-get install -y ansible ansible-core ansible-lint

# Install php packages and configure php.ini
RUN echo 'memory_limit=256M' > /usr/local/etc/php/conf.d/memory-limit.ini
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install intl gd opcache pdo_mysql pdo_pgsql zip
RUN pecl install pcov xdebug \
    && docker-php-ext-enable pcov xdebug

# # Configure xdebug but do not enable it (to enable add it conf.d in same path)
# RUN rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# ADD docker-php-ext-xdebug.ini /usr/local/etc/php/docker-php-ext-xdebug.ini

COPY install_composer.sh install_composer.sh
RUN sh install_composer.sh \
    && mv composer.phar /usr/local/bin/composer

RUN wget https://github.com/fabpot/local-php-security-checker/releases/download/v2.0.6/local-php-security-checker_2.0.6_linux_amd64 \
    && chmod +x local-php-security-checker_2.0.6_linux_amd64 \
    && mv local-php-security-checker_2.0.6_linux_amd64 /usr/local/bin/local-php-security-checker

# Ansistrano roles for deployment
RUN ansible-galaxy install ansistrano.deploy ansistrano.rollback

# Install Node and yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN corepack enable
# Add sentry-cli
RUN curl -sL https://sentry.io/get-cli/ | bash
