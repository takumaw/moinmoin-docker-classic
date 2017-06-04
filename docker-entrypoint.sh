#!/bin/bash
set -eu

# generate default site if not present
if [ ! -d /var/www/moin/config ] && \
   [ ! -d /var/www/moin/data ] && \
   [ ! -d /var/www/moin/server ] && \
   [ ! -d /var/www/moin/underlay ];
then
  cp -r /usr/local/share/moin/* /var/www/moin
  sed -i "/^#sys.path.insert(0, '\/path\/to\/farmconfigdir')/a sys.path.insert(0, '\/var\/www\/moin\/config')" /var/www/moin/server/*
  sed -i "s/^#from MoinMoin import log/from MoinMoin import log/" /var/www/moin/server/*
  sed -i "s/^#log.load_config('\/path\/to\/logging_configuration_file')/log.load_config('\/var\/www\/moin\/config\/logging\/logfile')/" /var/www/moin/server/*
  sed -i "s/instance_dir = wikiconfig_dir/instance_dir = os.path.join(wikiconfig_dir, os.pardir)/" /var/www/moin/config/wikiconfig.py
  sed -i 's/#superuser = \[u"YourName", \]/superuser = \[u"root", \]/' /var/www/moin/config/wikiconfig.py
fi

# correct permissions
chown -R www-data:www-data \
  /var/www/moin \
  /var/log/moin \
  /var/log/nginx
chmod -R ug+rwX \
  /var/www/moin \
  /var/log/moin \
  /var/log/nginx

exec "$@"
