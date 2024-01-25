#!/usr/bin/env bash

sudo apt-get update

# Install and setup postgres
sudo apt install postgresql postgresql-client
sudo -u postgres createuser -d -R -S odoo
createdb odoo

# Install dependencies
sudo apt install python3-pip libldap2-dev libpq-dev libsasl2-dev

cd /home/vagrant/odoo-local
pip install --upgrade pip
pip install -r requirements.txt

# TODO: Install wkhtmltopdf version 0.12.6
# TODO: Alias python3 to python
# TODO: virtualenv?

python3 odoo-bin --addons-path=addons -d mydb -i base # -i base needed to force initialization of DB

# Once done, goto: http://odoo-local.gearx.com:8069 (or replace odoo-local with project/deploy name)
# Initial login is admin/admin (even though the first field says "email")
