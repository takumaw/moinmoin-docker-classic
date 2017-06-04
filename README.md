# MoinMoin Docker Image
## What is MoinMoin?

MoinMoin is a free and open source wiki engine implemented in Python, which runs on a web hosting service.

## Usage

```
$ docker run -p 8080:80 takumaw/moinmoin
```
You can now access your instance via http://localhost:8080 in your browser.

You can use with docker-compose, i.e.

```
version: '3.1'

services:
  wordpress:
    image: takumaw/moinmoin
    ports:
      - 8080:80
    volumes:
      - ./var/www/html:/var/www/html
      - ./var/www/moin:/var/www/moin
      - ./var/log/nginx:/var/log/nginx
      - ./var/log/moin:/var/log/moin
```


## Image structure and configuration

This image has a MoinMoin setup with Nginx and uWSGI, run by supervisord.

Image's volume folder structure is described below:

  * /var/www/html/
    ... has static contents, accesible via http://HOSTNAME:PORT/FILE_PATH.
  * /var/www/moin/
    ... is a moinmoin instance directory.
    * config/
    * data/
    * server/
    * underlay/
  * /var/log/nginx/
    ... is the Nginx log directory. Stores access.log and error.log.
  * /var/log/moin/
    ... is the MoinMoin log directory.

If `/var/www/moin` is empty (e.g. it's first time to boot a container),
the container will automatically generate a new site under this directory
from `/usr/local/share/moin` with additional settings (done by `docker-entrypoint.sh`):

  * By default, user 'root' is set to a superuser.
    * You can create 'root' via http://localhost/LanguageSetup?action=newaccount .
  * The `instance_dir` is set to `os.path.join(wikiconfig_dir, os.pardir)`,
    which points to `/var/www/moin`.
  * All scripts under `/var/www/moin/server` is configured to use this wiki instance. 
