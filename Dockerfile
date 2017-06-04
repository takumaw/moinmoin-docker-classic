FROM python:2.7

# Install NGINX
RUN set -ex \
		&& apt-get update -y && apt-get install -y --no-install-recommends \
			nginx \
		&& rm -rf /var/lib/apt/lists/* \
		&& rm -rf /var/www/html/* \
		&& rm -rf /etc/nginx/sites-available/* \
		&& rm -rf /etc/nginx/sites-enabled/*

COPY nginx/default.conf /etc/nginx/conf.d/

# Install uWSGI
RUN set -ex \
		&& pip install --no-cache-dir uwsgi

# Install MoinMoin
ENV MOINMOIN_VERSION 1.9.9

RUN set -ex \
		&& pip install --no-cache-dir "moin==$MOINMOIN_VERSION" \
		&& mkdir -p \
			/usr/local/etc/moin \
			/usr/local/run/moin \
			/var/www/moin \
    && chown -R www-data:www-data \
			/usr/local/run/moin

COPY moin/uwsgi.ini /usr/local/etc/moin/

# Install Supervisord
RUN set -ex \
		&& pip install --no-cache-dir supervisor \
		&& mkdir -p /usr/local/run/supervisor

COPY supervisord/supervisord.conf /usr/local/etc/

# Finish setup
ENV PATH $PATH:/var/www/moin/server

EXPOSE 80
VOLUME ["/var/www/html", "/var/www/moin", "/var/log/nginx", "/var/log/moin"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/local/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
