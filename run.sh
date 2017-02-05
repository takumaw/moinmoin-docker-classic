#!/bin/bash

chown -R www-data /var/www/moin/data
uwsgi --ini /usr/local/etc/moin/uwsgi.ini
nginx -g 'daemon off;'
