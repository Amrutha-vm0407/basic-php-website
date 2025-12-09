
#!/bin/bash
set -e

SRC_DIR="$WORKSPACE"
DEST_DIR="/var/www/html/phpstatic"
APACHE_CONF="/etc/apache2/sites-available/000-default.conf"

echo "Starting PHP deployment..."
echo "Source: $SRC_DIR"
echo "Destination: $DEST_DIR"

# Create destination folder if missing
[ ! -d "$DEST_DIR" ] && mkdir -p "$DEST_DIR"

# Sync code
rsync -av --delete --exclude='.git' "$SRC_DIR"/ "$DEST_DIR"/

# Permissions
chown -R www-data:www-data "$DEST_DIR"
find "$DEST_DIR" -type d -exec chmod 755 {} \;
find "$DEST_DIR" -type f -exec chmod 644 {} \;

# Update Apache DocumentRoot
sed -i "s|DocumentRoot .*|DocumentRoot $DEST_DIR|g" "$APACHE_CONF"

# Restart Apache
systemctl restart apache2

echo "✔ PHP Deployment complete."
