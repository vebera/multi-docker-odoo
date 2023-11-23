# Odoo 16.0 + pgAdmin + Metabase multi-instance + Traefik 2.0 labels

## Description
I created this project because the installation and upgrade of Odoo is kind of complex for beginners, and especially complicated if you want to run/test other Odoo versions simultaneously. This might be a great repository for freelance developers who need to support (develop for) various versions at the same time.
You may need this repo to compile your own containers from nightly builds of Odoo (https://nightly.odoo.com/):
https://github.com/vmelnych/odoo_docker_build

## Environment
Tested on Ubuntu 21.04 (on WSL2) but must work on plain Ubuntu 18+ and with some bash script adjustments on other Linux distributions as well.

## Installation
1. launch stack script with the name of your instance (e.g. `demo`):
```
./stack.sh -u demo
```
It you omit the instance name, the `default` name will be used.
2. Adjust your parameters in the created .env file (**instances/`demo`/.env**). Mind that web ports and container names (you can play with ODOO_VER variable) must vary for different environments run simultaneously.
3. Put your addons in the related folder in the **instances/`demo`/addons/** or point to another location.
4. Up your instance for plain vanilla Odoo:
```
./stack.sh -u demo
```

If you need to launch pgAdmin alongside, specify it like that:
```
./stack.sh -u demo pgadmin
```
or this way if you also need a Metabase:
```
./stack.sh -u demo pgadmin metabase
```

Enjoy and let me know if you like it!
vebera.tech@gmail.com