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
    curl \
    openssh-client

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

# Enable OPcache
RUN docker-php-ext-enable opcache

# Clear cache
RUN rm -rf /var/cache/apk/* && rm -rf /tmp/*

# Copy the application files
COPY ./web /var/www/html

# Set proper permissions
RUN addgroup -g 1000 www && \
    adduser -D -G www -u 1000 -h /var/www/html www && \
    chown -R www:www /var/www/html

# Switch to non-root user
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
