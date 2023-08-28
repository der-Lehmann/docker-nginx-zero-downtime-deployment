FROM php:8.2-fpm

COPY ./dockerfiles/index.php /var/www/public/index.php
COPY ./dockerfiles/script2.php /var/www/script.php

WORKDIR /var/www/public