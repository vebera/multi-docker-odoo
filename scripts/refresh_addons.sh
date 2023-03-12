#!/bin/bash

# maintainer vasyl.melnychuk@accessholding.com
# copy this script to the addons folder!!!

# Error handling
#set -o errexit          # Exit on most errors
#set -o errtrace         # Make sure any error trap is inherited
#set -o pipefail         # Use last non-zero exit code in a pipeline

GRN='\033[0;32m' && YEL='\033[1;33m' && RED='\033[0;31m' && BLU='\033[0;34m' && NC='\033[0m'

#folder where the current script is located
declare folder="$(cd "$(dirname "$0")"; pwd -P)"
declare list="addons.txt"
declare clonescr="clone.sh"
declare branch="15.0"

printf "  Addons:  ${RED}$folder${NC}\n"
printf "  List  :  ${RED}$list${NC}\n"
printf "${RED}=== STARTED ===${NC}\n"

cd "$folder"

# reading the list from the addons folder
if [ ! -r $list ]
then
        printf "  First create and edit the list ${RED}$list${NC}!\n"
fi

# storing git credentials
git config --global credential.helper store


case "${1}" in
        --list | -l ) 
                find $folder -maxdepth 1 -mindepth 1 -type d > $list
            ;;
        --clone | -c ) 
                echo "" > "$folder/$clonescr"
                while IFS= read -r line
                do
                        printf "Addon ${BLU} $line: ${NC}\n"
                        if [ -d "$line" ]
                        then
                                cd "$line"
                                printf "git clone " >> $folder/$clonescr && git remote get-url origin >> "$folder/$clonescr"
                        else
                                printf "${RED}skipped (not found)${NC}\n"
                        fi
                done <"$list"
                chmod +x "$folder/$clonescr"
                printf "  Check the script ${RED}$clonescr${NC}\n"
            ;;
        --refresh | -r ) 
                # performing `git pull` for each folder in the list:
                while IFS= read -r line
                do
                        printf "Addon ${BLU} $line: ${NC}\n"
                        if [ -d "$line" ]
                        then
                                cd "$line"
                                git stash
                                git stash drop
                                git pull
                                git checkout $branch
                                git pull
                        else
                                printf "${RED}skipped (not found)${NC}\n"
                        fi
                        printf "===========================\n\n"
                done <"$list"
            ;;
        * ) 
            printf "usage: ${0} [arg]
               --list,-l\t\t Create the list of all addon folders
               --clone,-c\t\t Create a script for mass git clone
               --refresh,-r\t\t Refresh (pull) all changes from repositories
            "
            ;;
esac


printf "${RED}\n=== FINISHED ===${NC}\n"
