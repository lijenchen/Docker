#!/bin/sh
#//#!/bin/bash

##//[N] 建立對應目錄的帳號並轉換映射身分

#//=========================================================
syntax_type_deed()
{
    syntax_type_sets
    syntax_type_cmds
    if [ "$lvx" = "0" ]; then
        local lvsel=1
        if [ "$lvsel" = "1" ]; then
            local cnt="$lvl"
            if [ "$cnt" = "-1" ]; then
                while true
                do
                    $lvcmds
                done
            else
                while [ $cnt -gt 0 ]
                do
                    #(( cnt -- ))
                    cnt=$(( cnt - 1 ))
                    $lvcmds
                done
            fi
        fi
    fi
}
syntax_type_cmds()
{
    lvcmds=
    ##映射時排除(root)
    if [ "$lv_uid" != "0" ] && [ "$lv_gid" != "0" ] ; then
        local lv_name=$IDSET
        ##檢查是否存在(gid)
        ##[=>] 建立群組帳號
        local st_gid=`cat /etc/group  | awk -F : '{print $3}' | grep $lv_gid`
        if [ "$st_gid" = "" ] && [ "$lv_gid" != "$lv_name" ] ; then
            ##不存在時配置
            lvcmds="bash poky_groupadd.sh $lv_gid $lv_name"
            if [ $IDMSG != "0" ]; then echo $lvcmds; fi
            $lvcmds
        fi
        ##檢查是否存在(uid)
        ##[=>] 建立個人帳號
        local st_uid=`cat /etc/passwd | awk -F : '{print $3}' | grep $lv_uid`
        if [ "$st_uid" = "" ] && [ "$lv_uid" != "$lv_name" ]; then
            ##不存在時配置
            lvcmds="bash poky_useradd.sh  $lv_uid $lv_gid $lv_name"
            if [ $IDMSG != "0" ]; then echo $lvcmds; fi
            $lvcmds;
        fi
        ##[=>] 轉換映射身分
        lvcmds="sudo -E -H -u $lv_name poky_launch.sh `pwd` bash"
        if [ $IDMSG != "0" ]; then echo $lvcmds; fi
    fi
}
syntax_type_sets()
{
    ##------------------------
    ## [-w] (對應目錄)
    #local lv_work=$PWD
    local lv_work=`pwd`
    ##------------------------
    ## [-e] (對應名稱)
    local lv_defn="sw"
    local lv_path=/home/
    local lv_name=$IDSET
    if [ "$lv_name" != "" ]; then
        lv_path="$lv_path$lv_name"
    else
        lv_path="$lv_path$lv_defn"
    fi
    ##------------------------
    ##//ls -la `pwd` | awk 'NR==2 {print $3}; END {print $3};'
    ##//ls -la `pwd` | awk 'NR==2 {print $3}'
    ##------------------------
    lv_uid=
    lv_gid=
    local lv_uidw=
    local lv_gidw=
    local lv_uidp=
    local lv_gidp=
    local lvsel=0
    if [ "$lvsel" = "0" ]; then
        if [ -d "$lv_work" ]; then
            lv_uidw=`ls -la $lv_work | awk 'NR==2 {print $3}'`
            lv_gidw=`ls -la $lv_work | awk 'NR==2 {print $4}'`
            lv_uid=$lv_uidw;
            lv_gid=$lv_gidw;
        fi
    else
        if [ -d "$lv_path" ]; then
            lv_uidp=`ls -la $lv_path | awk 'NR==2 {print $3}'`
            lv_gidp=`ls -la $lv_path | awk 'NR==2 {print $4}'`
            lv_uid=$lv_uidp;
            lv_gid=$lv_gidp;
        fi
    fi
    if [ "$lv_uid" = "" ] || [ "$lv_gid" = "" ] ; then
        lv_uid=1000;
        lv_gid=1000;
    fi
    ##------------------------
    if [ $IDMSG != "0" ]; then syntax_type_debug; fi
    ##------------------------
}
syntax_type_debug()
{
    echo "lv_work       => $lv_work"
    echo "st_uid:st_gid => $lv_uidw:$lv_gidw"
    echo
    echo "lv_path       => $lv_path"
    if [ "$lv_uidp" != "" ] || [ "$lv_gidp" != "" ] ; then echo "st_uid:st_gid => $lv_uidp:$lv_gidp"; fi
    echo
    echo "lv_uid:lv_gid => $lv_uid:$lv_gid"
}
#//=====================================
syntax_type_usage()
{
echo
echo "----------------------------------------"
cat << HELP
    <> must| compulsory
    [] need| optional
    {} deploy

    usage:
    sh ${0} <OPTIONS {VALUE}> {[OPTIONS {VALUE}] ...}

    (e.g.)
    . ${0} [-h] [-v] [-x]
    . ${0} -h
    . ${0} -v
    (demo)
    . ${0} -x

    Description:options
    (must)

    (need)
        -h, --help
            Display this message
            (args num 0)
            (String:[ ])
            (Default:null)

        -v, --version
            Display this version
            (args num 0)
            (String:[ ])
            (Default:null)

        -x, --debug
            Set debug
            (args num 0)
            (Value:[0,1] - 1:debug 0:normal)
            (Default: 0)
HELP
echo "----------------------------------------"
#exit 0
}
syntax_type()
{
    ##對應型式
    ##輸入命令(參數的數目)
    #//local lv_min=
    #//local lv_max=
    local lv_err=0 #錯誤數
    local lv_get=0 #至少數
    #//if [ $# -lt $lv_min ] || [ $# -gt $lv_max ] ; then
    #//    way=1
    #//else
        #while true
        while [ -n "$1" ]
        do
        {
            local LOC_SEL
            case "${1}" in
                -l)
                    if [ "${2}" != "" ]; then lvl=${2}; shift; else lv_err=$(($lv_err+1)); fi
                    ##lv_get=$(($lv_get-1))
                    ;;
                -d)
                    if [ "${2}" = "" ]; then lv_err=$(($lv_err+1)); else lvd=${2}; shift; fi
                    ##lv_get=$(($lv_get-1))
                    ;;
                -x)
                    lvx=1
                    ;;
                #-v, --version)
                #    ;&
                #-h|--help)
                #    ;&
                *)
                    lv_err=$[$lv_err+1]; way=1
                    #return
                    #break
                    ;;
            esac
            shift
        }
        done
        #---------------------
        if [ $lv_err != 0 ]; then way=1; fi
        if [ $lv_get != 0 ]; then way=1; fi
        if [ "$way" = "1" ]; then
            echo "lv_err ===> ${lv_err}"
            echo "lv_get ===> ${lv_get}"
            syntax_type_usage
        else
            syntax_type_deed
        fi
    #//fi
}
#//-------------------------------------
#//=====================================
syntax_default()
{
    rm *.bak >/dev/null 2>&1
    ##set value (default)
    ##--------------
    lvv="1.0.0"
    lvx=0
    way=0
    ##--------------
    lvl=1
}
syntax_check()
{
    syntax_default
    ##--------------
    if [ -n "$1" ]; then
        case "${1}" in
            -v)
                echo version:$lvv
                ;;
            -h)
                syntax_type_usage
                ;;
            *)
                syntax_type "$@"
                ;;
        esac
    else
        syntax_type
    fi
}
#//=========================================================
syntax_check "$@"