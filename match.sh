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