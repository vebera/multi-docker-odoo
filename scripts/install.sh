#!/bin/bash

# maintainer Vasyl Melnychuk
# pass an instance name as a parameter, for example: ./install.sh demo

# Error handling
set -o errexit          # Exit on most errors
set -o errtrace         # Make sure any error trap is inherited
set -o pipefail         # Use last non-zero exit code in a pipeline

GRN='\033[0;32m'
YEL='\033[1;33m'
RED='\033[0;31m'
BLU='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]
then
  instance="default"
else
  instance=$1
fi

printf "Installation started\n"

#folder where the current script is located
declare folder="$(cd "$(dirname "$0")"; pwd -P)"
mkdir -p ${folder}'/../instances'
declare envdir=$(readlink -f ${folder}'/../instances/'${instance})
declare env=${envdir}'/.env'
declare conf=${envdir}'/config/odoo.conf'
declare stack=$(readlink -f ${folder}/'../stack_'$instance'.sh')
declare addons=${envdir}'/addons'
declare refresh="refresh_addons.sh"

printf "      folder:    ${BLU}${folder}${NC}\n"
printf "      envdir:    ${BLU}${envdir}${NC}\n"
printf "         env:    ${BLU}${env}${NC}\n"
printf " odoo config:    ${BLU}${conf}${NC}\n"
printf "stack script:    ${BLU}${stack}${NC}\n"

# creating directories if not found:
printf "mkdir:    ${YEL}${envdir}${NC}\n"
mkdir -p ${envdir}
printf "mkdir:    ${YEL}${envdir}/config${NC}\n"
mkdir -p ${envdir}'/config'
printf "mkdir:    ${YEL}${addons}${NC}\n"
mkdir -p ${addons}
printf "mkdir:    ${YEL}${envdir}/log${NC}\n"
mkdir -p ${envdir}'/log'

# copying _env into a .env if not found:
if [ ! -r ${env} ]
then
  cp ${folder}'/../_env' ${env}
  printf "Creating .env file: ${YEL}${env}${NC}... Check it before you launch the stack.\n"
  sed -i "s|#INSTANCE#|$instance|g" ${env}
  sed -i "s|#ADDONS#|$addons|g" ${env}
  sed -i "s|#CONFIG#|$envdir/config|g" ${env}
  sed -i "s|#LOG#|$envdir/log|g" ${env}
  sed -i "s|#POSTGRES_PASSWORD#|$(openssl rand -base64 14)|g" ${env}
  sed -i "s|#PGADMIN_PASSWORD#|$(openssl rand -base64 14)|g" ${env}
  sed -i "s|#METABASE_SECRET#|$(openssl rand -base64 14)|g" ${env}
fi

if [ -r ${env} ]
then
  source ${env}
else
  printf "Error creating .env file ${RED}${env}${NC}. Please, investigate, resolve and restart...\n"
  exit 1
fi

# copying refresh_addons script if not found:
if [ ! -r ${addons}/$refresh ]
then
  cp ${folder}'/'${refresh} ${addons}'/'${refresh}
  printf "Check ${GRN} '${addons}/${refresh}' ${NC}"
fi

#creating odoo config file:
printf "[options]
addons_path = /mnt/extra-addons
data_dir = /var/lib/odoo
db_port = 5432
db_user = ${POSTGRES_USER}
db_password = ${POSTGRES_PASSWORD}
db_host = db_odoo${ODOO_VER}
; admin_passwd = 
; csv_internal_sep = ,
; db_maxconn = 64
; db_name = False
; db_template = template1
; dbfilter = .*
; debug_mode = False
; email_from = False
; limit_memory_hard = 2684354560
; limit_memory_soft = 2147483648
; limit_request = 8192
; limit_time_cpu = 60
; limit_time_real = 120
; list_db = True
; log_db = False
; log_handler = [':INFO']
; log_level = info
; logfile = None
; longpolling_port = 8072
; max_cron_threads = 2
; osv_memory_age_limit = 1.0
; osv_memory_count_limit = False
; smtp_password = False
; smtp_port = 25
; smtp_server = localhost
; smtp_ssl = False
; smtp_user = False
; workers = 0
; xmlrpc = True
; xmlrpc_interface = 
; xmlrpc_port = 8069
; xmlrpcs = True
; xmlrpcs_interface = 
; xmlrpcs_port = 8071" > ${conf}

printf "\nconfig file ${GRN}${conf}${NC} created\n"


#creating stack launch script:
printf "#!/bin/bash

#adjust your settings as you need:
envfile='$env'
" > $stack
cat stack.txt >> $stack

chmod +x $stack

printf "Stack script ${GRN}${stack}${NC} has been created. Use it to launch the instance.\n"

printf "Installation finished\n"
