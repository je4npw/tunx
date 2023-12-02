FROM php:8.3-fpm-alpine

# Copy composer.lock and composer.json
COPY ./web/composer.lock ./web/composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apk --no-cache add \
    build-base \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev \
    zip \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    vim \
    unzip \
    git \
    curl

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

# Enable OPcache
RUN docker-php-ext-enable opcache

# Clear cache
RUN rm -rf /var/cache/apk/* && rm -rf /tmp/*

# Adiciona o grupo e usuário www com ID 1000
RUN addgroup -g 1000 www \
    && adduser -D -G www -u 1000 -h /var/www/html www

# Copy the application files
COPY ./web /var/www/html

# Set proper permissions
RUN chown -R www:www /var/www/html\
    && chmod -R 755 /var/www/html/app/config \
    && chmod -R 755 /var/www/html/app/control \
    && chmod -R 755 /var/www/html/app/database \
    && chmod -R 755 /var/www/html/app/model \
    && chmod -R 755 /var/www/html/app/output \
    && chmod -R 755 /var/www/html/tmp

# Switch to non-root user
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
