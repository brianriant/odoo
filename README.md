# Odoo

[![Build Status](https://runbot.odoo.com/runbot/badge/flat/1/master.svg)](https://runbot.odoo.com/runbot)
[![Tech Doc](https://img.shields.io/badge/master-docs-875A7B.svg?style=flat&colorA=8F8F8F)](https://www.odoo.com/documentation/master)
[![Help](https://img.shields.io/badge/master-help-875A7B.svg?style=flat&colorA=8F8F8F)](https://www.odoo.com/forum/help-1)
[![Nightly Builds](https://img.shields.io/badge/master-nightly-875A7B.svg?style=flat&colorA=8F8F8F)](https://nightly.odoo.com/)

Odoo is a suite of web based open source business apps.

The main Odoo Apps include an [Open Source CRM](https://www.odoo.com/page/crm),
[Website Builder](https://www.odoo.com/app/website),
[eCommerce](https://www.odoo.com/app/ecommerce),
[Warehouse Management](https://www.odoo.com/app/inventory),
[Project Management](https://www.odoo.com/app/project),
[Billing &amp; Accounting](https://www.odoo.com/app/accounting),
[Point of Sale](https://www.odoo.com/app/point-of-sale-shop),
[Human Resources](https://www.odoo.com/app/employees),
[Marketing](https://www.odoo.com/app/social-marketing),
[Manufacturing](https://www.odoo.com/app/manufacturing),
[...](https://www.odoo.com/)

Odoo Apps can be used as stand-alone applications, but they also integrate seamlessly so you get
a full-featured [Open Source ERP](https://www.odoo.com) when you install several Apps.

## Getting started with Odoo

### Standard Installation

For a standard installation please follow the [Setup instructions](https://www.odoo.com/documentation/master/administration/install/install.html)
from the documentation.

To learn the software, we recommend the [Odoo eLearning](https://www.odoo.com/slides),
or [Scale-up, the business game](https://www.odoo.com/page/scale-up-business-game).
Developers can start with [the developer tutorials](https://www.odoo.com/documentation/master/developer/howtos.html).

### Docker Deployment

Quick start with Docker Compose:

```bash
# Copy environment template
cp .env.example .env

# Edit .env and set your database password
nano .env

# Start services
docker-compose up -d

# View logs
docker-compose logs -f web
```

Access Odoo at `http://localhost:8069`

**First-time setup:**

1. Navigate to `http://localhost:8069`
2. Create a new database through the web interface
3. Set a master password and database name
4. Install the modules you need

**Alternative: Initialize via CLI:**

```bash
# Stop the web container
docker-compose stop web

# Initialize database with base module
docker-compose run --rm web \
  --addons-path=/mnt/extra-addons,/opt/odoo/addons,/opt/odoo/odoo/addons \
  -d odoo \
  -i base \
  --db_host=db \
  --db_user=odoo \
  --db_password=your_password \
  --stop-after-init \
  --without-demo=all

# Start the web container
docker-compose start web
```

**Development mode:**

```bash
# Set dev mode in .env
ODOO_EXTRA_ARGS=--dev=all

# Restart
docker-compose restart web
```

**Running tests:**

```bash
docker-compose exec web odoo --test-enable --test-tags /module_name -d odoo --stop-after-init
```

**Installing/updating modules:**

```bash
# Install module
docker-compose exec web odoo -i module_name -d odoo --stop-after-init

# Update module
docker-compose exec web odoo -u module_name -d odoo --stop-after-init
```

**Managing services:**

```bash
# Stop services
docker-compose stop

# Start services
docker-compose start

# Rebuild after code changes
docker-compose up -d --build

# View database logs
docker-compose logs -f db

# Access Odoo shell
docker-compose exec web odoo shell -d odoo
```

### Development Setup

```bash
# Install Python dependencies
pip install -r requirements.txt

# Start Odoo with custom addons
./odoo-bin --addons-path=addons,odoo/addons -d odoo --dev=all

# Run tests for specific module
./odoo-bin --test-enable --test-tags /module_name -d odoo --stop-after-init
```

## AI Development Guidelines

For AI coding agents, see [.github/copilot-instructions.md](.github/copilot-instructions.md) for:

- Module architecture patterns
- ORM usage and inheritance
- View definitions and conventions
- Testing workflows
- Project-specific patterns

## Security

If you believe you have found a security issue, check our [Responsible Disclosure page](https://www.odoo.com/security-report)
for details and get in touch with us via email.
