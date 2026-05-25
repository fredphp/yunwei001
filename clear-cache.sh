#!/bin/bash
# Clear Nginx FastCGI cache and update resource version numbers
echo "Clearing Nginx FastCGI cache..."
rm -rf /var/cache/nginx/fastcgi/*
nginx -s reload
echo "Cache cleared!"

# Auto-update JS/CSS version numbers
VERSION=$(date +%Y%m%d%H%M)
echo "Updating resource version to: $VERSION"
cd /var/www/yunwei001/wwwroot/templates/default
sed -i "s/\.js?v=[0-9]*/\.js?v=$VERSION/g" header.html
echo "header.html version numbers updated to v=$VERSION"

