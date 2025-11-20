#!/bin/bash
set -e  # exit on error

# Jenkins workspace (source code)
SRC_DIR="$WORKSPACE"

# Bare-metal Apache directory where PHP website will be deployed
DEST_DIR="/var/www/html/phpstatic"

# Apache config file
APACHE_CONF="/etc/apache2/sites-available/000-default.conf"

echo "Starting PHP deployment..."
echo "Source: $SRC_DIR"
echo "Destination: $DEST_DIR"

# 1. Create destination directory if not exists
if [ ! -d "$DEST_DIR" ]; then
    echo "Directory $DEST_DIR does not exist. Creating..."
    sudo mkdir -p "$DEST_DIR"
else
    echo "Directory $DEST_DIR already exists."
fi

# 2. Copy source code to destination (delete old files)
echo "Copying files from $SRC_DIR to $DEST_DIR ..."
sudo rsync -av --delete --exclude='.git' "$SRC_DIR"/ "$DEST_DIR"/

# 3. Set correct permissions for Apache/PHP
echo "Setting permissions..."
sudo chown -R www-data:www-data "$DEST_DIR"
sudo find "$DEST_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEST_DIR" -type f -exec chmod 644 {} \;

# 4. Update DocumentRoot in Apache configuration
if grep -q "DocumentRoot" "$APACHE_CONF"; then
    echo "Updating DocumentRoot to $DEST_DIR ..."
    sudo sed -i "s|DocumentRoot .*|DocumentRoot $DEST_DIR|g" "$APACHE_CONF"
else
    echo "DocumentRoot not found. Adding it..."
    echo "DocumentRoot $DEST_DIR" | sudo tee -a "$APACHE_CONF"
fi

# 5. Restart Apache service
echo "Restarting Apache..."
sudo systemctl restart apache2

echo "✔ PHP Deployment complete. Site is served from: $DEST_DIR"
