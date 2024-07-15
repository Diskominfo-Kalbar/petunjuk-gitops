FROM php:8.1-fpm

ARG DB_HOST
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_DATABASE

ARG MINIO_HOST
ARG MINIO_ACCESS_KEY
ARG MINIO_BUCKET_NAME
ARG MINIO_SECRET_KEY

# Set environment variables using build arguments
ENV DB_HOST=${DB_HOST}
ENV DB_USERNAME=${DB_USERNAME}
ENV DB_PASSWORD=${DB_PASSWORD}
ENV DB_DATABASE=${DB_DATABASE}

ENV MINIO_HOST=${MINIO_HOST}
ENV MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
ENV MINIO_BUCKET_NAME=${MINIO_BUCKET_NAME}
ENV MINIO_SECRET_KEY=${MINIO_SECRET_KEY}

# Set working directory
WORKDIR /var/www

# Add docker php ext repo
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install php extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions mbstring pdo_mysql mysqli zip exif pcntl gd memcached dom

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    git \
    curl \
    lua-zlib-dev \
    libmemcached-dev \
    nginx

# Install supervisor
RUN apt-get install -y supervisor

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install object storage
RUN composer require aws/aws-sdk-php 


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add user for php application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy code to /var/www
COPY --chown=www-data:www-data ./src /var/www
RUN mkdir -p /var/www/session
RUN chmod -R 775 /var/www/session
RUN chown -R www-data:www-data /var/www/session


# Copy nginx/php/supervisor configs
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/php.ini /usr/local/etc/php/conf.d/app.ini
COPY docker/nginx.conf /etc/nginx/sites-enabled/default
COPY docker/run.sh /docker/run.sh

# PHP Error Log Files
RUN mkdir /var/log/php
RUN touch /var/log/php/errors.log && chmod 777 /var/log/php/errors.log

# Deployment steps
RUN chmod +x /docker/run.sh
RUN chmod -R 555 /var/www/public

EXPOSE 80
# Run the necessary commands at container startup
CMD ["sh", "-c", "\
    /usr/bin/supervisord -c /etc/supervisord.conf"]
