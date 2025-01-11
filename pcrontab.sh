#!/bin/bash

# match($1=proposed_time_value,$2=current_time_value)->state:int -1=err,0=false,1=true
function match {
    case $1 in         
        *-*)
            start=$(cut -d '-' -f 1 <<<$1)
            end=$(cut -d '-' -f 2 <<<$1)
            if [ $start -gt $end ];then
                echo "start $start greater than end $end !"
                return -1
            fi
            if [ $2 -ge $start && $2 -le $end ];then
                return 1
            else
                return 0
            fi
            ;;
        [0-9]|[0-9][0-9])
            if [ $2 -eq $1 ];then
                return 1
            else
                return 0
            fi
            ;;
        '*')
            return 1
            ;;

        *:*)
            IFS=':' read -r -a values <<< "$1"
            #echo "${values[*]}"
            for val in $values ; do
                if [ $val -eq $2 ];then
                    return 1
                fi
            done
            return 0
            ;;
        
        '*/'*)
            #echo "step $1"
            step=${arg#*/}
            if [ $(( $2 % step )) -eq 0 ];then
                    return 1
            fi
            return 0
            ;;
        *)
            echo "unknown: $1"
            return -1
            ;;
    esac
}

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