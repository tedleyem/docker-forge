#!/bin/bash
set -e 

# Startup script for Team Password Manager Dockerfile
# More information: https://teampasswordmanager.com/docs/docker/
# Ferran Barba (info@teampasswordmanager.com)

# Will be set to 0 if TeamPasswordManager files and folders do not exist (index.php, folder.php, config.php, wmm, system, css)
tpm_files_exist=1

# Function that checks if TeamPasswordManager files and folders exist
# We check the wmm, system and css folders and index.php, folder.php, config.php files
# Note that we don't check for the reports folder because it doesn't exist in previous versions
function check_tpm_files {
	tpm_files_exist=1

	if [ ! -d "/var/www/html/site/wmm" ]; then
		tpm_files_exist=0
		return
	fi
	if [ ! -d "/var/www/html/site/system" ]; then
		tpm_files_exist=0
		return
	fi
	if [ ! -d "/var/www/html/site/css" ]; then
		tpm_files_exist=0
		return
	fi
	if [ ! -f "/var/www/html/site/index.php" ]; then
		tpm_files_exist=0
		return
	fi
	if [ ! -f "/var/www/html/site/folder.php" ]; then
		tpm_files_exist=0
		return
	fi
	if [ ! -f "/var/www/html/site/config.php" ]; then
		tpm_files_exist=0
		return
	fi
}

# Server timezone
ln -snf /usr/share/zoneinfo/$TPM_SERVER_TIMEZONE /etc/localtime && echo $TPM_SERVER_TIMEZONE > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# PHP timezone
echo "date.timezone=$TPM_PHP_TIMEZONE" > /etc/php/8.4/apache2/conf.d/01-timezone.ini

# Check if the software folders exist. If not, create them:
# 	/var/www/html/site => Team Password Manager software files
# 	/var/www/html/logs => Apache logs
# 	/var/www/html/ssl => SSL certificates

if [ ! -d "/var/www/html/site" ]; then
	mkdir /var/www/html/site
fi

if [ ! -d "/var/www/html/logs" ]; then
	mkdir /var/www/html/logs
fi

if [ ! -d "/var/www/html/ssl" ]; then
	mkdir /var/www/html/ssl

	# Also copy the generated self signed certificate files to this folder (renaming them)
	cp /etc/ssl/private/ssl-cert-snakeoil.key /var/www/html/ssl/tpm-ssl-key.key
	cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/www/html/ssl/tpm-ssl-cert.crt
fi

# Check if TeamPasswordManager files exist in /var/www/html/site
# We check if these files and folders exist: index.php, folder.php, config.php, wmm, system, css
# If they exist:
# 	- If TPM_UPGRADE is 0, we do nothing (we have a TeamPasswordManager installation and we'll keep it as is)
# 	- If TPM_UPGRADE is 1, delete index.php, wmm, system and css (config.php and folder.php are left as they are) and 
#	  copy the new ones from /root/teampasswordmanager_$TPM_VERSION
# If they do not exist: we copy all the files from /root/teampasswordmanager_$TPM_VERSION and configure the database

check_tpm_files

if [ $tpm_files_exist == 1 ]; then

	# If TPM_UPGRADE is 1, delete index.php, wmm, system and css (config.php and folder.php are left as they are) and 
	# copy the new ones from /root/teampasswordmanager_$TPM_VERSION
	# We only do this the first time the container is executed. The next times the upgrade has been done.
	# The reports folder is not deleted (it didn't exist in previous versions), but is copied
    if [ $TPM_UPGRADE == 1 ]; then
    	# If the files are in root, it means the upgrade has not been done, so do it, else we do nothing
    	if [ -d "/root/teampasswordmanager_$TPM_VERSION" ]; then
	    	rm /var/www/html/site/index.php
	    	rm -r /var/www/html/site/wmm
	    	rm -r /var/www/html/site/system
	    	rm -r /var/www/html/site/css

	    	cp /root/teampasswordmanager_$TPM_VERSION/index.php /var/www/html/site/
	    	cp -r /root/teampasswordmanager_$TPM_VERSION/wmm /var/www/html/site/
	    	cp -r /root/teampasswordmanager_$TPM_VERSION/system /var/www/html/site/
	    	cp -r /root/teampasswordmanager_$TPM_VERSION/css /var/www/html/site/
	    	cp -r /root/teampasswordmanager_$TPM_VERSION/reports /var/www/html/site/

	    	chown -R www-data:www-data /var/www/html/site/    
	    	chmod -R 755 /var/www/html/site/	

    		# Remove downloaded files (so that next time we don't upgrade)
    		rm -r /root/teampasswordmanager_$TPM_VERSION
    	fi
    fi

else
    
    # Copy all the files from /root/teampasswordmanager_$TPM_VERSION and configure the database
    mv /root/teampasswordmanager_$TPM_VERSION/* /var/www/html/site/
    rmdir /root/teampasswordmanager_$TPM_VERSION
	chown -R www-data:www-data /var/www/html/site/
	chmod -R 755 /var/www/html/site/

	# Replace config.php with the one we create here
	echo "<?php" > /var/www/html/site/config.php

	# Database parameters in config.php
	printf "\n// MySQL Database server" >> /var/www/html/site/config.php
	printf "\ndefine('CONFIG_HOSTNAME', '$TPM_CONFIG_HOSTNAME');" >> /var/www/html/site/config.php

	printf "\n\n// User that accesses the database server, that should have all privileges on the database CONFIG_DATABASE" >> /var/www/html/site/config.php
	printf "\ndefine('CONFIG_USERNAME', '$TPM_CONFIG_USERNAME');" >> /var/www/html/site/config.php

	printf "\n\n// User password" >> /var/www/html/site/config.php
	printf "\ndefine('CONFIG_PASSWORD', '$TPM_CONFIG_PASSWORD');" >> /var/www/html/site/config.php

	printf "\n\n// Database for Team Password Manager. You must manually create it before installing Team Password Manager"  >> /var/www/html/site/config.php
	printf "\ndefine('CONFIG_DATABASE', '$TPM_CONFIG_DATABASE');" >> /var/www/html/site/config.php

	# Write define for ENCRYPT_DB_CONFIG if it's not 0
	if [ $TPM_ENCRYPT_DB_CONFIG != "0" ]; then
		printf "\n\ndefine('ENCRYPT_DB_CONFIG', $TPM_ENCRYPT_DB_CONFIG);" >> /var/www/html/site/config.php
	fi

	# Write define for CONFIG_PORT if it's not 3306
	if [ $TPM_CONFIG_PORT != "3306" ]; then
		printf "\n\ndefine('CONFIG_PORT', $TPM_CONFIG_PORT);" >> /var/www/html/site/config.php
	fi

	printf "\n\n// For other parameters read: https://teampasswordmanager.com/docs/all-parameters-config-php/\n" >> /var/www/html/site/config.php

	printf "\n\n//define('MAINTENANCE_MODE', TRUE);\n" >> /var/www/html/site/config.php

fi

# Execute cron
cron

# Off we go
exec "$@"
