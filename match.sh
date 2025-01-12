# match($1=proposed_time_value,$2=current_time_value)->state:int 2=err,0=false,1=true
function match {
    case $1 in         
        [0-9]-[0-9]|[0-9][0-9]-[0-9]|[0-9]-[0-9][0-9]|[0-9][0-9]-[0-9][0-9])
            start=$(cut -d '-' -f 1 <<<$1)
            end=$(cut -d '-' -f 2 <<<$1)
            if [ $start -gt $end ];then
                echo "start $start greater than end $end !"
                return 2
            fi
            if [ $2 -ge $start ]&&[ $2 -le $end ];then
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
            for val in "${values[@]}" ; do
                if [[ "$val" =~ ^[0-9]{1,2}$ ]]; then
                    if [ $val -eq $2 ];then
                        return 1
                    fi
                else
                    return 2
                fi
            done
            return 0
            ;;
        
        '*/'[1-9]|'*/'[0-9][0-9])
            #echo "step $1"
            step=${1:2}
            #echo $step
            if [ $(( $2 % step )) -eq 0 ];then
                    return 1
            fi
            return 0
            ;;
        *)
            echo "unknown: $1"
            return 2
            ;;
    esac
}