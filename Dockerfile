FROM python:2.7

# Install NGINX
RUN set -ex \
		&& apt-get update -y && apt-get install -y --no-install-recommends \
			nginx \
		&& rm -rf /var/lib/apt/lists/* \
		&& rm -rf /var/www/html/* \
		&& rm -rf /etc/nginx/sites-available/* \
		&& rm -rf /etc/nginx/sites-enabled/*

COPY nginx/default.conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Install uWSGI
RUN set -ex \
		&& pip install --no-cache-dir uwsgi

# Install MoinMoin
ENV MOINMOIN_VERSION 1.9.9
ENV MOINMOIN_SHA256 4397d7760b7ae324d7914ffeb1a9eeb15e09933b61468072acd3c3870351efa4

RUN set -ex \
		&& mkdir -p /usr/src/moin \
		&& curl -o moin.tar.gz https://static.moinmo.in/files/moin-$MOINMOIN_VERSION.tar.gz \
		&& echo "$MOINMOIN_SHA256 *moin.tar.gz" | sha256sum -c - \
		&& tar -xzf moin.tar.gz -C /usr/src/moin --strip-components=1 \
		&& rm -f moin.tar.gz \
		&& cd /usr/src/moin \
		&& python setup.py install --prefix=/usr/local --install-data=/usr/local \
		&& rm -rf /usr/src/moin \
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
