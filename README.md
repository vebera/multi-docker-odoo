# Odoo 16.0/17.0 + pgAdmin + Metabase multi-instance
## Two configurations provided:
* a local one
* a cloud one with Traefik 2.6 labels

## Description
I created this project because the installation and upgrade of Odoo is kind of complex for beginners, and especially complicated if you want to run/test other Odoo versions simultaneously. This might be a great repository for freelance developers who need to support (develop for) various versions at the same time.
You may need this repo to compile your own containers from nightly builds of Odoo (https://nightly.odoo.com/):
https://github.com/vebera/odoo_docker_build

## Environment
Tested on Ubuntu from 18.x and higher (on WSL2) but with some bash script adjustments must work on other Linux distributions as well.

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

If you need to launch `pgadmin` alongside, specify it like that:
```
./stack.sh -u demo pgadmin
```
or this way if you also need a `Metabase`:
```
./stack.sh -u demo pgadmin metabase
```
Note, that for `Metabase` to start it is required to create an empty database named `metabase`. You can do it with help of `pgadmin`.


Enjoy and let me know if you like it!
vebera.tech@gmail.com