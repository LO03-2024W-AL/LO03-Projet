#!/bin/bash
function match {
    case $1 in         
        *-*)
            start=$(cut -d '-' -f 1 <<<$1)
            end=$(cut -d '-' -f 2 <<<$1)
            echo "$start to $end"
            ;;
        [0-9]|[0-9][0-9])
            echo "single number $1"
            ;;
        '*')
            echo "any"
            ;;

        *:*)
            IFS=':' read -r -a values <<< "$1"
            echo "${values[*]}"
            ;;
        
        '*/'*)
            echo "step $1"
            step=${arg#*/}
            ;;
        *)
            echo "unknown: $1"
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
            echo "$@"
            for(( i=1;i<=6;i++ ));do
                match "$1"
                shift
            done
            ;;
    -*|--*)  # get unknown args
            echo "unknown args: $1"
            exit 1
            ;;
esac

