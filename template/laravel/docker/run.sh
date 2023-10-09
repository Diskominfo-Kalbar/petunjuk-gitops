#!/bin/sh

cd /var/www
chmod -R 775 /var/www/storage
chown -R www-data:www-data /var/www/storage
composer install
# php artisan migrate:fresh --seed
#php artisan cache:clear
php artisan key:generate
chown  www-data:www-data /var/www/storage/logs/laravel.log
/usr/bin/supervisord -c /etc/supervisord.conf