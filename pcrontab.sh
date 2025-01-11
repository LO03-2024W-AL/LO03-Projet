#!/bin/bash

#resolve arguments
#pcrontab [-u user] {-l | -r | -e} manage the tasks
#0 30 7 * * 1-5 commande
if [ $# -gt 0 ];then
    if [ $1 == "-u" ];then
        user_name=$2
        id $user_name
        if [ $? -nq 0 ];then
            echo "invalid username."
            exit 1
        fi
        shift 2
    else
        user_name=$USER
        echo "user:$user_name"
    fi
fi


case $1 in
    -e)
            shift
            cmd="$*"
            for(( i=1;i<=6;i++ ));do
            match "$1" "0"
                if [ $? -eq -1 ];then
                    echo "error"
                    exit 1
                fi
                shift
            done
            echo "$cmd" >> "tmp/${user_name}Pcrontab" #
            ;;
    -*|--*)  # get unknown args
            echo "unknown args: $1"
            exit 1
            ;;
esac

function main {
    while true;do    
        for usr in $(ls "tmp");do
            current_time=$(date "+%S %M %H %d %m %u")
            while read -r line;do
                IFS=' ' read -r -a ligne <<< "$line"
                #echo "$*"
                m=0
                for val in $current_time;do
                    match "${ligne[$m]}" "$val"
                    if [ $? -eq 1 ];then
                        ((m++))
                    else
                        break
                    fi
                done
                if [ $m -eq 6 ];then
                    cmd=""
                    for (( i=6; i<${#ligne[@]}; i++ )); do
                        cmd+="${ligne[$i]} "
                    done
                    echo "execute: $cmd"
                    eval "$cmd" &
                fi
            done < "tmp/${usr}"
            sleep 1
        done
    done
}
main