# Team Password Manager v. 14.177.303 Dockerfile
# 20251015 Ferran Barba (info@teampasswordmanager.com)
# More information: https://teampasswordmanager.com/docs/docker/

FROM ubuntu:24.04

LABEL maintainer="Ferran Barba (info@teampasswordmanager.com)"

# *********** Environment variables (default values) **************** 

# Server timezone
# http://manpages.ubuntu.com/manpages/bionic/man3/DateTime::TimeZone::Catalog.3pm.html
ENV TPM_SERVER_TIMEZONE=Etc/UTC

# PHP timezone (should be the same as the server)
# https://www.php.net/manual/en/timezones.php
ENV TPM_PHP_TIMEZONE=Etc/UTC 

# Upgrade TeamPasswordManager (1=Upgrade files, 0=Leave as is)
ENV TPM_UPGRADE=0

# *******************************************************************

ARG DEBIAN_FRONTEND=noninteractive

# Team Password Manager version
ENV TPM_VERSION=14.177.303

# Install unzip, curl, timezone, cron (for session cleanup)
RUN apt-get update \
 && apt-get -qqy dist-upgrade \
 && apt-get -qqy install ca-certificates unzip curl wget vim tzdata cron

# Ondrej GPG key for Apache and PHP
COPY ondrej_ubuntu_php.gpg /etc/apt/trusted.gpg.d/ondrej_ubuntu_php.gpg

# Install Apache, enable rewrite, generate self signed cert, enable ssl and headers apache modules
RUN echo "deb http://ppa.launchpad.net/ondrej/apache2/ubuntu noble main" > /etc/apt/sources.list.d/ondrej-ubuntu-apache2-noble.list \
	&& apt-get update \
	&& apt-get install -qqy apache2 \
	&& a2enmod rewrite \
	&& make-ssl-cert generate-default-snakeoil --force-overwrite \
	&& a2enmod ssl \
	&& a2enmod headers

# Copy site configuration and enable it, also disable default configuration
COPY teampasswordmanager.conf /etc/apache2/sites-available
RUN a2ensite teampasswordmanager.conf \
	&& a2dissite 000-default.conf

# PHP
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ondrej-ubuntu-php-noble.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install php8.4 libapache2-mod-php8.4 php8.4-cli php8.4-common php8.4-mysql php8.4-mbstring php8.4-ldap php8.4-curl php8.4-gd php8.4-xml

# Custom values for various ini settings
COPY 02-teampasswordmanager.ini /etc/php/8.4/apache2/conf.d

# SourceGuardian Loader
RUN cd /usr/lib/php/20240924 \
	&& wget --quiet https://teampasswordmanager.com/assets/download/sourceguardian/16.0.2/ixed.8.4.lin \
	&& echo "extension = ixed.8.4.lin" > /etc/php/8.4/apache2/conf.d/00-sourceguardian.ini

# ldaps
RUN echo "TLS_REQCERT never" >> /etc/ldap/ldap.conf

# TeamPasswordManager
# We download the file and decompress it, but the docker_entrypoint.sh script is the one that puts it in /var/www/html/site
RUN cd /root \
	&& wget --quiet https://teampasswordmanager.com/assets/download/teampasswordmanager_"$TPM_VERSION".zip \
	&& unzip -qq teampasswordmanager_"$TPM_VERSION".zip \
	&& rm teampasswordmanager_"$TPM_VERSION".zip

# Schedule the php session cleanup script
RUN crontab /etc/cron.d/php

# Cleanup
RUN apt-get clean \
	&& apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/* \
    && rm /var/www/html/index.html

WORKDIR /var/www/html

VOLUME /var/www/html

# So that Apache stops gracefully
# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

# Startup script
COPY docker_entrypoint.sh /usr/local/bin/ 
RUN chmod +x /usr/local/bin/docker_entrypoint.sh 

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]