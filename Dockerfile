# PHP 8.1 ve Apache tabanlı bir imaj kullanalım
FROM php:8.1-apache

# Apache'nin rewrite modülünü etkinleştirelim
RUN a2enmod rewrite

# Laravel'in gereksinim duyduğu PHP eklentilerini yükleyelim
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    && docker-php-ext-install zip pdo_mysql

# Composer'ı yükleyelim
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Projemizin kodlarını Docker içindeki /var/www/html klasörüne kopyalayalım
COPY . /var/www/html

# Bağımlılıkları yükleyelim ve optimize edelim
RUN cd /var/www/html && \
    composer install --optimize-autoloader --no-dev

# Apache yapılandırmasını güncelleyelim
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf
RUN service apache2 restart

# Gerekli portu dışarıya açalım
EXPOSE 80

# Docker container'ı çalıştırırken Apache'yi başlatmak için komutu belirtelim
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
