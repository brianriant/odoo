# Odoo Development Guidelines for AI Agents

## Architecture Overview

Odoo is a modular ERP system built on a custom Python ORM framework. The codebase follows a strict module-based architecture where each addon (`addons/*/`) is self-contained with models, views, controllers, and static assets.

### Module Structure

Every Odoo module (`addons/module_name/`) contains:

- `__manifest__.py`: Module metadata defining `name`, `depends`, `data` (XML files load order), `assets`, `installable`, `author`, `license`
- `models/`: Python files defining database models using the Odoo ORM
- `views/`: XML files defining UI (form, tree, kanban, search views) and menu items
- `security/`: Access control files (`ir.model.access.csv`, security rules)
- `controllers/`: HTTP controllers for web routes
- `static/`: JS/CSS/images organized as `static/src/` (source) and `static/lib/` (libraries)
- `data/`: XML data files (demo data, configuration)
- `wizard/`: Transient models for multi-step wizards
- `tests/`: Python test files (prefixed with `test_`)

## Core Development Patterns

### Model Definitions

Models inherit from `models.Model`, `models.TransientModel`, or `models.AbstractModel`:

```python
from odoo import models, fields, api

class SaleOrder(models.Model):
    _name = 'sale.order'  # Database table name
    _inherit = ['portal.mixin', 'mail.thread']  # Mixin inheritance
    _description = "Sales Order"
    _order = 'date_order desc, id desc'

    # Fields with comodel, string, compute, related patterns
    partner_id = fields.Many2one('res.partner', string="Customer", required=True)
    amount_total = fields.Monetary(compute='_compute_amount_total', store=True)

    @api.depends('order_line.price_total')
    def _compute_amount_total(self):
        for order in self:
            order.amount_total = sum(order.order_line.mapped('price_total'))
```

**Key inheritance patterns**:

- `_inherit = 'model.name'` (no `_name`): Extends existing model in-place
- `_inherit = ['model.a', 'model.b']`: Multiple inheritance (mixins)
- `_inherits = {'parent.model': 'parent_id'}`: Delegation inheritance (fields accessible via Many2one)

### XML Data Files

Views and data use `<odoo>` root with `<record>` elements:

```xml
<odoo>
    <record id="view_sale_order_form" model="ir.ui.view">
        <field name="name">sale.order.form</field>
        <field name="model">sale.order</field>
        <field name="arch" type="xml">
            <form string="Sales Order">
                <header>
                    <button name="action_confirm" string="Confirm" type="object"/>
                    <field name="state" widget="statusbar"/>
                </header>
                <sheet>
                    <field name="partner_id"/>
                    <field name="order_line"/>
                </sheet>
            </form>
        </field>
    </record>

    <menuitem id="menu_sale_order"
              action="action_sale_order"
              parent="menu_sale_root"
              sequence="10"/>
</odoo>
```

**XML ID convention**: `module_name.record_identifier` (e.g., `sale.view_sale_order_form`)

## Critical Developer Workflows

### Running Odoo

Start server: `./odoo-bin --addons-path=addons --db-filter=^dbname$ -d dbname`

Common options:

- `-i module_name`: Install module
- `-u module_name`: Update module (after code changes)
- `--dev=all`: Enable auto-reload, debug mode
- `--test-enable --test-tags module_name`: Run tests

### Testing

Tests live in `tests/` directory, inherit from `odoo.tests.TransactionCase` or `HttpCase`:

```python
from odoo.tests import TransactionCase, tagged

@tagged('post_install', '-at_install')
class TestSaleOrder(TransactionCase):
    def test_sale_order_total(self):
        order = self.env['sale.order'].create({'partner_id': self.partner.id})
        self.assertEqual(order.amount_total, 0.0)
```

Run tests: `./odoo-bin --test-enable --test-tags /module_name -d dbname --stop-after-init`

### Module Installation & Updates

After modifying `__manifest__.py` or adding data files:

1. Restart with `-u module_name` to update
2. For new models/fields: `-u module_name` creates DB columns automatically
3. For security/access changes: Update and restart

### Database Migrations

No explicit migrations in typical development. ORM handles schema changes automatically when updating modules.

## Project-Specific Conventions

### Import Organization

```python
# Standard library
import json
from datetime import datetime

# Odoo core
from odoo import _, api, fields, models
from odoo.exceptions import UserError, ValidationError
from odoo.tools import float_compare, format_amount
```

### Field Naming

- Boolean fields: `is_*`, `has_*`, `can_*`
- Many2one: `*_id` (singular)
- One2many/Many2many: `*_ids` (plural)
- Computed fields: Often prefixed with `computed_*` or suffixed with `_display`

### Decorators

- `@api.depends('field1', 'field2')`: Compute field dependencies
- `@api.onchange('field')`: Client-side field change handlers
- `@api.constrains('field')`: Validation constraints
- `@api.model`: Class method (no recordset)

### Security

Every model requires `security/ir.model.access.csv`:

```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_sale_order_user,sale.order.user,model_sale_order,base.group_user,1,1,1,0
```

### Linting

Project uses `ruff` for linting (see `ruff.toml`). Key rules enforced:

- PEP 8 compliance
- Import sorting (isort-style)
- No star imports except for `__init__.py` exports
- Prefer f-strings over `%` formatting

## Integration Patterns

### ORM Operations

```python
# Create
order = self.env['sale.order'].create({'partner_id': partner_id})

# Search
orders = self.env['sale.order'].search([('state', '=', 'draft')], limit=10)

# Browse (by ID)
order = self.env['sale.order'].browse(order_id)

# Write (update)
order.write({'state': 'confirmed'})

# Recordset operations
partner_names = orders.mapped('partner_id.name')
total = sum(orders.mapped('amount_total'))
```

### Context & Environment

- `self.env`: Current environment (user, database cursor, context)
- `self.env.user`: Current user record
- `self.env.company`: Current company record
- `self.with_context(key='value')`: Pass context data
- `self.sudo()`: Execute with superuser rights

### JavaScript (Owl Components)

Frontend uses Owl framework. Components in `static/src/`:

```javascript
import { Component } from "@odoo/owl";
import { useService } from "@web/core/utils/hooks";

export class MyComponent extends Component {
  setup() {
    this.orm = useService("orm");
    this.action = useService("action");
  }

  async loadData() {
    const data = await this.orm.call("model.name", "method_name", [args]);
  }
}
```

## Key Directories

- `odoo/`: Core framework (ORM, HTTP, services)
- `odoo/addons/`: Core modules bundled with Odoo
- `addons/`: Community/standard business modules
- `odoo/cli/`: Command-line tools (`odoo-bin` entry point)
- `odoo/tools/`: Utility functions (convert, config, safe_eval)

## References

- Manifest format: `odoo/modules/module.py` (`_DEFAULT_MANIFEST`)
- Model base classes: `odoo/orm/models.py`
- Field types: `odoo/orm/fields.py`
- View architecture: `odoo/addons/base/models/ir_ui_view.py`
