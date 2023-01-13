# Odoo 16.0 + pgAdmin + Metabase multi-instance + Traefik 2.0 labels

## Description
I created this project because the installation and upgrade of Odoo is kind of complex for beginners, and especially complicated if you want to run/test other Odoo versions simultaneously. This might be a great repository for freelance developers who need to support (develop for) various versions at the same time.
You may need this repo to compile your own containers from nightly builds of Odoo (https://nightly.odoo.com/):
https://github.com/vmelnych/odoo_docker_build

## Environment
Tested on Ubuntu 21.04 (on WSL2) but must work on plain Ubuntu 18+ and with some bash script adjustments on other Linux distributions as well.

## Installation
1. launch installation script with the name of your instance (e.g. `demo`):
```
./scripts/install.sh demo
```
2. Adjust your parameters in the created .env file (**instances/`demo`/.env**). Mind that web ports and container names (you can play with ODOO_VER variable) must be different for different environments.
3. Put your addons in the related folder in the **instances/`demo`/addons/** or point to another location.
4. Launch your stack script **stack_`demo`.sh** (created automatically after you successfully performed all steps) without parameters to see the available options.
```
./stack_demo.sh
```
5. Up your instance for plain vanilla Odoo:
```
./stack_demo.sh -u
```

If you need to launch pgAdmin alongside, specify it like that:
```
./stack_demo.sh -u pgadmin
```
or like that if you also need a Metabase:
```
./stack_demo.sh -u pgadmin metabase
```

Enjoy and let me know if you like it!
Vasyl (vasyl@wizzfinancial.com)