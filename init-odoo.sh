#!/bin/bash
# Odoo initialization helper script

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "Initializing Odoo database..."
echo "Database: ${DB_NAME:-odoo}"
echo "User: ${DB_USER:-odoo}"
echo ""

# Stop web container
echo "Stopping web container..."
docker-compose stop web

# Initialize database
echo "Installing base module..."
docker-compose run --rm web \
  --addons-path=/mnt/extra-addons,/opt/odoo/addons,/opt/odoo/odoo/addons \
  -d "${DB_NAME:-odoo}" \
  -i base \
  --db_host="${DB_HOST:-db}" \
  --db_user="${DB_USER:-odoo}" \
  --db_password="${DB_PASSWORD}" \
  --stop-after-init \
  --without-demo=all

# Start web container
echo ""
echo "Starting web container..."
docker-compose start web

echo ""
echo "✓ Initialization complete!"
echo "Access Odoo at: http://localhost:${ODOO_PORT:-8069}"
echo ""
echo "Default credentials:"
echo "  Email: admin"
echo "  Password: admin"
echo ""
echo "⚠ Remember to change the admin password after first login!"
