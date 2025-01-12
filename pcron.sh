#!/bin/bash

# 检查用户权限
source "./match.sh"
function check_permission {
    user=$(whoami)

    # root 用户默认有权限
    if [ "$user" == "root" ]; then
        return 0
    fi

    allow_file="/etc/pcron.allow"
    deny_file="/etc/pcron.deny"

    # 优先检查拒绝列表
    if [ -f "$deny_file" ]; then
        if grep -q "^$user\$" "$deny_file"; then
            echo "用户 $user 在拒绝列表中，无权使用 pcron。"
            exit 1
        fi
    fi

    # 检查允许列表
    if [ -f "$allow_file" ]; then
        if grep -q "^$user\$" "$allow_file"; then
            echo "用户 $user 在允许列表中，可以使用 pcron。"
            return 0
        else
            echo "用户 $user 未在允许列表中，无权使用 pcron。"
            exit 1
        fi
    fi

    # 如果没有配置文件，只有 root 可以运行
    echo "未找到权限配置文件，仅限 root 使用 pcron。"
    exit 1
}

# 运行所有 tmp 中的任务
function run_tasks {
    tmp_dir="./tmp"
    if [ ! -d "$tmp_dir" ]; then
        echo "任务目录不存在：$tmp_dir"
        exit 1
    fi

    # 获取当前时间（秒、分、小时、日、月、星期）
    current_time=($(date "+%S %M %H %d %m %u"))
    echo ${current_time[@]}
    
    #星期日为0，秒数以15秒为1个单位
    current_time[0]=$((current_time[0]/15))
    if [ ${current_time[5]} -eq 7 ];then
        current_time[5]=0
    fi
    echo ${current_time[@]}

    # 遍历 tmp 目录中的用户文件
    for task_file in "$tmp_dir"/*; do
        echo "检查任务文件：$task_file"

        # 遍历任务文件中的每一行
        while IFS= read -r line; do
            IFS=' ' read -r -a fields <<< "$line"
            
            # 检查时间匹配
            matched=1
            for i in {0..5}; do
                match "${fields[$i]}" "${current_time[$i]}"
                if [ $? -ne 1 ]; then
                    matched=0
                    break
                fi
            done

            # 如果匹配，执行命令
            if [ $matched -eq 1 ]; then
                cmd="${fields[@]:6}" # 获取命令部分
                echo "执行任务：$cmd"
                eval "$cmd" &  # 默认输出到标准输出,&后台非阻塞
            fi
        done < "$task_file"
    done
}

# 主函数入口
function main {
    check_permission # 检查用户权限

    while true; do
        run_tasks
        sleep 15 # 每15秒检查一次任务
    done
}

main
