#!/bin/bash

# Error handling
set -o errexit          # Exit on most errors
set -o errtrace         # Make sure any error trap is inherited
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o nounset          # Exits if any of the variables is not set

GRN='\033[0;32m' && YEL='\033[1;33m' && RED='\033[0;31m' && BLU='\033[0;34m' && NC='\033[0m'

#folder where the current script is located
declare HOME="$(cd "$(dirname "$0")"; pwd -P)"
#declare env=".env"
declare adminuser="odoo"
declare instances=${HOME}"/instances"
declare env=${instances}'default/.env'
declare postgresecret=./.secrets/postgre-admin-password

checkdocker() {
  if [[ ! -x "$(command -v docker)" ]]; then
    printf "\ninit(): You must install ${RED}docker${NC} on your machine. Aborted. \n"
    exit 1
  fi
  if [[ ! -x "$(command -v docker-compose)" ]]; then
    printf "\ninit(): You must install ${RED}docker-compose${NC} on your machine. Aborted. \n"
    exit 1
  fi
}

createnet() {
  if [ ! "$(docker network ls | grep proxy)" ]; then
    printf "\ncreatenet(): Creating docker network (${YEL}proxy${NC}). \n"
    sudo docker network create proxy
  fi
}

createsecrets() {
  if [ ! -d ".secrets" ]; then
    mkdir -p ".secrets"
    portpass=$(openssl rand -base64 12)
    echo "$portpass" >> $postgresecret
    printf "\ncreatesecrets(): Postgres secret has been created in ${YEL}$postgresecret${NC}.\n"
  fi
}

createinstance() {
    log="createinstance():"
    printf "\n$log Started...\n"
    mkdir -p ${instances}
    COMPOSE_PROJECT_NAME="default"
    thisinstance=$instances"/"$COMPOSE_PROJECT_NAME

    if [ ! -z "$2" ]; then
        COMPOSE_PROJECT_NAME=$2
        thisinstance=$instances'/'$2
    fi
    env=${thisinstance}'/.env'
    conf=${thisinstance}'/config/odoo.conf'

    if [ ! -d "$thisinstance" ]; then
        mkdir -p ${thisinstance}
        mkdir -p ${thisinstance}'/addons'
        mkdir -p ${thisinstance}'/config'
        mkdir -p ${thisinstance}'/log'

        # copying _env into the .env if not found:
        printf "Creating .env file: ${YEL}${env}${NC}... Check it before you launch the stack.\n"
        cp '_env' ${env}
        sed -i "s|#COMPOSE_PROJECT_NAME#|$COMPOSE_PROJECT_NAME|g" ${env}
        sed -i "s|#ADDONS#|$thisinstance/addons|g" ${env}
        sed -i "s|#CONFIG#|$thisinstance/config|g" ${env}
        sed -i "s|#LOG#|$thisinstance/log|g" ${env}
        POSTGRES_PASSWORD=$(openssl rand -base64 14)
        sed -i "s|#POSTGRES_PASSWORD#|$POSTGRES_PASSWORD|g" ${env}
        sed -i "s|#PGADMIN_PASSWORD#|$(openssl rand -base64 14)|g" ${env}
        sed -i "s|#METABASE_SECRET#|$(openssl rand -base64 14)|g" ${env}
        read -p "Input your Odoo domain name (e.g. odoo.mydomain.com): " ODOO_URL
        if [ -z $ODOO_URL ]; then
            ODOO_URL="odoo.mydomain.com"
        fi
        read -p "Input your pgAdmin domain name (e.g. pga.mydomain.com): " PGADMIN_URL
        if [ -z $PGADMIN_URL ]; then
            PGADMIN_URL="pga.mydomain.com"
        fi
        read -p "Input your Metabase domain name (e.g. bi.mydomain.com): " MB_URL
        if [ -z $MB_URL ]; then
            MB_URL="bi.mydomain.com"
        fi
        sed -i "s|#ODOO_URL#|$ODOO_URL|g" ${env}
        sed -i "s|#PGADMIN_URL#|$PGADMIN_URL|g" ${env}
        sed -i "s|#MB_URL#|$MB_URL|g" ${env}
        printf "\n$log Check the ${YEL}${env}${NC} and make sure all parameters are correct. \n"
        source ${env}

        # copying conf.odoo into the new folder if not found:
        printf "$log Creating config file: ${YEL}${conf}${NC}... Check it before you launch the stack.\n"
        cp 'odoo.conf' ${conf}
        sed -i "s|#POSTGRES_PASSWORD#|$POSTGRES_PASSWORD|g" ${conf}
        sed -i "s|#POSTGRES_USER#|$POSTGRES_USER|g" ${conf}
        sed -i "s|#ODOO_VER#|$ODOO_VER|g" ${conf}

        printf "$log ${GRN}An odoo instance has been created in ${BLU}$thisinstance${NC} \n"
    fi
}



init() {

  checkdocker
  createnet
  createsecrets
  createinstance "$@"

  #checking if .env created successfully:
  if [ -r ${env} ]
  then
    source ${env}
  else
    printf "Error creating environment file ${RED}${env}${NC}. Please, check if an ${BLU}_env${NC} file available, resolve and restart...\n"
    exit 1
  fi
}


main() {
    printf "\n Variables: \n"
    printf "   instance : ${BLU}$COMPOSE_PROJECT_NAME${NC}. You can provide a new instance name as a parameter.\n"
    printf "        env : ${BLU}${env}${NC}\n"
    printf "Config file : ${BLU}$conf${NC}\n"

    case "${1}" in
        --pull | -p )
            docker image prune -a --force --filter "until=72h"
            docker-compose --env-file ${env} pull "${@:3}"
            ;;
        --up | -u )
            printf "${GRN}docker-compose --env-file ${env} up -d "${@:3}"${NC} \n"
            docker-compose --env-file ${env} up -d "${@:3}"
            ;;
        --down | -d )
            docker-compose --env-file ${env} down
            ;;
        --restart | -r )
            docker-compose --env-file ${env} down
            docker-compose --env-file ${env} up -d "${@:3}"
            ;;
        * ) 
            printf "\n \
                    Usage:${BLU} ${0} ${GRN}[parameters]${NC}\n \
                    ${GRN}--pull, -p${NC}\t\t Pull the repo from registry\n \
                    ${GRN}--up,-u${NC}\t\t Up the repo. ${GRN}pgadmin${NC} and ${GRN}metabase${NC} are optional parameters\n \
                    ${GRN}--down,-d${NC}\t\t Down the repo\n \
                    ${GRN}--restart,-r${NC}\t Cold-restart the repo\n \
                    "
            ;;
    esac

}

init "$@"
time main "$@"
