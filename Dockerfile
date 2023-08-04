FROM php:8.1-fpm

ENV COMPOSER_MEMORY_LIMIT='-1'

# install plugins
RUN apt-get update \
    && apt-get install -y autoconf pkg-config libssl-dev libpng-dev libzip-dev libjpeg-dev libfreetype6-dev

# Install PHP extensions
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-configure gd --with-jpeg --with-freetype
RUN docker-php-ext-install gd
RUN docker-php-ext-enable gd
RUN docker-php-ext-install exif
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install zip

# INSTALL MS ODBC Driver for SQL Server
#RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
#RUN apt-get update
#RUN ACCEPT_EULA=Y apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev
#RUN pecl install sqlsrv
#RUN pecl install pdo_sqlsrv
#RUN echo "extension=pdo_sqlsrv.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
#RUN echo "extension=sqlsrv.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-sqlsrv.ini
#RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# INSTALL SUPERVISORD
RUN apt-get update && apt-get install -y nginx supervisor cron

# Install the PHP zip extention
RUN docker-php-ext-install zip

# INSTALL SUPERVISORD
#RUN #apt-get update \
#    && apt-get install -y nginx supervisor cron
#RUN apt-get install supervisor cron

# INSTALL COMPOSER
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer


COPY docker/php/php.ini /usr/local/etc/php/php.ini

# supervisor
COPY docker/config/supervisord.conf /etc/supervisor/supervisord.conf

# RUN docker-php-ext-install opcache
# COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
ADD xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN chown -R www-data:www-data /var/www
WORKDIR /var/www/html

# open port 80 443
EXPOSE 80 443

## run supervisor
CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf