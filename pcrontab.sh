#!/bin/bash
source "./match.sh"
PROFILE_DIR="tmp"
#resolve arguments
#pcrontab [-u user] {-l | -r | -e} manage the tasks
#0 30 7 * * 1-5 commande
if [ $# -gt 0 ];then
    if [ $1 == "-u" ];then
        user_name=$2
        id $user_name 2>/dev/null
        if [ $? -ne 0 ];then
            echo "invalid username."
            exit 1
        fi
        shift 2
    else
        user_name=$(whoami)
        echo "user:$user_name"
    fi
fi

#check illegal time values
function check {
    MAX_VALS=(3 59 23 31 12 6)
    max_val=${MAX_VALS[(($2 - 1))]}
    for num in $(echo "$1" | grep -o '[0-9]\+');do
        if [ $num -gt $max_val ];then
            return 2
        fi
        if [ $2 -eq 5 ];then
            if [ $num -eq 0 ];then
                return 2
            fi
        fi
    done
    return 0
}

case $1 in
    -e)
            shift
            cmd="$*"
            if [ $# -lt 7 ];then
                echo "too few arguments!"
                exit 1
            fi
            for(( i=1;i<=6;i++ ));do
                match "$1" "0"
                if [ $? -eq 2 ];then
                    echo "error,invalid format."
                    exit 1
                fi
                check "$1" "$i"
                if [ $? -eq 2 ];then
                    echo "error,illegal value."
                    exit 1
                fi
                shift
            done
            echo "$cmd" >> "${PROFILE_DIR}/${user_name}Pcrontab"
            echo "add task:" "$cmd"
            ;;
    -l)
            shift
            if [ -r "${PROFILE_DIR}/${user_name}Pcrontab" ];then
                cat "${PROFILE_DIR}/${user_name}Pcrontab"
            else
                echo "Error, profile does not exist or accessible."
            fi
            ;;
    -r)
            shift
            if [ -f "${PROFILE_DIR}/${user_name}Pcrontab" ];then
                if [ $(whoami)=="root" ]||[ $(whoami)==$user_name ];then
                    rm -f "${PROFILE_DIR}/${user_name}Pcrontab"
                    echo "remove: " "${PROFILE_DIR}/${user_name}Pcrontab"
                fi
            fi
            ;;
    -*|--*)  # get unknown args
            echo "unknown args: $1"
            exit 1
            ;;
esac