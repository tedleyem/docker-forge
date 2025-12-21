FROM ubuntu:24.04

# Set ARGs with standard defaults.
ARG BUILD_DATE="default-build-date"
ARG VERSION="latest"
ARG SNIPEIT_RELEASE="v8.3.6"

# --- Install Dependencies for Ubuntu ---
RUN echo "**** Preparing and installing packages ****" && \
  # 1. Update and install prerequisites for adding a PPA
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bash \
    curl \
    jq \
    git \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    && \
  
  # 2. Add the Ondřej Surý PPA for PHP 8.3 and re-update package lists
  add-apt-repository -y ppa:ondrej/php && \
  apt-get update && \
  
  # 3. Install the application packages
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    mariadb-client \
    nginx \
    php8.3-fpm \
    php8.3-cli \
    php8.3-bcmath \
    php8.3-exif \
    php8.3-gd \
    php8.3-ldap \
    php8.3-mysql \
    php8.3-sqlite3 \
    php8.3-redis \
    php8.3-sodium \
    php8.3-tokenizer \
    php8.3-xml \
    php8.3-intl \
    php8.3-mbstring \
    php8.3-fileinfo \
    php8.3-curl \
    php8.3-zip \
    && \
  
  # 4. Clean up APT caches
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Composer globally using the installed PHP CLI
RUN echo "**** install Composer globally ****" && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configure PHP-FPM
RUN echo "**** configure php-fpm to pass env vars ****" && \
  FPM_CONFIG_PATH="/etc/php/8.3/fpm/pool.d/www.conf" && \
  if [ -f "$FPM_CONFIG_PATH" ]; then \
    sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' "$FPM_CONFIG_PATH" && \
    grep -qxF 'clear_env = no' "$FPM_CONFIG_PATH" || echo 'clear_env = no' >> "$FPM_CONFIG_PATH"; \
  fi && \
  MAIN_FPM_CONFIG_PATH="/etc/php/8.3/fpm/php-fpm.conf" && \
  if [ -f "$MAIN_FPM_CONFIG_PATH" ]; then \
    echo "env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> "$MAIN_FPM_CONFIG_PATH"; \
  fi

# Set working directory
WORKDIR /app/www/

# Download and Extract Snipe-IT
RUN echo "**** install snipe-it ****" && \
  if [ -z "$SNIPEIT_RELEASE" ] || [ "$SNIPEIT_RELEASE" = "latest" ]; then \
    echo "SNIPEIT_RELEASE not explicitly set. Fetching latest tag..." && \
    export SNIPEIT_RELEASE=$(curl -s "https://api.github.com/repos/snipe/snipe-it/releases/latest" | jq -r .tag_name); \
  fi && \
  curl -o \
    /tmp/snipeit.tar.gz -L \
    "https://github.com/snipe/snipe-it/archive/${SNIPEIT_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/snipeit.tar.gz --strip-components=1 && \
  rm -f /tmp/snipeit.tar.gz

# Install Composer Dependencies
RUN echo "**** running composer install ****" && \
  cp docker/docker.env .env && \
  composer install --no-dev

# Final Setup and Cleanup
RUN echo "**** move storage directories to defaults ****" && \
  mkdir -p /defaults/ && \
  mv \
    "storage" \
    "public/uploads" \
    /defaults/ && \
  rm -rf \
    $HOME/.cache \
    $HOME/.composer \
    /tmp/*

# ports and volumes
EXPOSE 80 443