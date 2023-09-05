#!/usr/bin/env bash

wp core download \
    --locale=${WP_LOCALE}
wp config create \
    --dbuser=${DB_USERNAME} \
    --dbpass=${DB_PASSWORD} \
    --dbhost=db \
    --dbname=${DB_DATABASE} \
    --force
wp core install \
    --url="localhost:${HTTPS_PORT}" \
    --title="${PROJECT_NAME}" \
    --admin_user=${WP_USERNAME} \
    --admin_password=${WP_PASSWORD} \
    --admin_email=${WP_EMAIL} \
    --locale=${WP_LOCALE} \
    --skip-email
