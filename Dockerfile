FROM ubuntu:16.04
MAINTAINER Takuma Watanabe <takumaw@sfo.kuramae.ne.jp>

# Set environmental variables
ENV HOME /root
WORKDIR /root

# Setup base environment
RUN apt update -qy && \
	apt upgrade -qy && \
	apt autoremove -qy && \
	apt autoclean -qy && \
	apt clean

RUN apt install -qy \
	wget unzip \
	nginx uwsgi uwsgi-plugin-python python

# Install Nginx
ADD nginx/moin /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/moin /etc/nginx/sites-enabled/moin

# Install MoinMoin
RUN wget http://static.moinmo.in/files/moin-1.9.9.tar.gz --quiet -P /tmp && \
    tar xzf /tmp/moin-*.tar.gz -C /tmp && \
	cd /tmp/moin-* && \
    python setup.py install --force --prefix=/usr/local && \
	cd && \
	rm -rf /tmp/moin-*

RUN mkdir -p \
		/usr/local/etc/moin/ \
		/usr/local/run/moin/ && \
    chown -Rh www-data:www-data \
		/usr/local/run/moin/ \
		/usr/local/share/moin/data \
		/usr/local/share/moin/underlay

ADD moin/uwsgi.ini /usr/local/etc/moin/
ADD moin/moin.wsgi /usr/local/etc/moin/

# Finish setup
ADD run.sh /
EXPOSE 443
VOLUME ["/var/www/moin"]
CMD ["bash", "/run.sh"]

