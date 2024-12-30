#!/bin/sh
#//#!/bin/bash

#//=========================================================
### [N] "===>流程管控(進程管理)(dumb-init)"
setup_dumb()
{
    if [ ! -f "/usr/bin/dumb-init" ]; then
    ##//------------------------------------------
    ##//==[crops/yocto]https://github.com/crops/yocto-dockerfiles/blob/master/build-install-dumb-init.sh
    ##//------------------------------------------
    #//builddir=`mktemp -d` && cd $builddir
    #//##虛擬環境
    #//##pip3 install virtualenv
    #//virtualenv $builddir/venv; . $builddir/venv/bin/activate
    #//pip3 install setuptools tox
    #//##
    #//target="v1.2.5.tar.gz"; wget --no-check-certificate https://github.com/Yelp/dumb-init/archive/${target}
    #//sha256="3eda470d8a4a89123f4516d26877a727c0945006c8830b7e3bad717a5f6efc4e"
    #//echo "${sha256} ${target}" > SHA256SUMS; sha256sum -c SHA256SUMS || exit 1; rm SHA256SUMS
    #//tar xf ${target}
    #//cd dumb-init*
    #//echo py >> requirements-dev.txt
    #//sed -i '128 i \ \ \ \ packages=[],' setup.py
    #//sed -i -e 's/envlist = .*/envlist = py3/' tox.ini
    #//sed -i -e 's/tox -e pre-commit//' Makefile
    #//make dumb-init
    #//#make test
    #//cp dumb-init /usr/bin/dumb-init
    #//chmod +x /usr/bin/dumb-init
    #//cd / && rm $builddir -rf
    ##//----------------------
    verget="1.2.5"; wget --no-check-certificate https://github.com/Yelp/dumb-init/releases/download/v${verget}/dumb-init_${verget}_amd64.deb
    dpkg -i dumb-init_*.deb; rm -f dumb-init_${verget}_amd64.deb
    ##//----------------------
    #//verget="1.2.5"; wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${verget}/dumb-init_${verget}_x86_64
    #//chmod +x /usr/bin/dumb-init
    ##//----------------------
    ##//apt-get install -y dumb-init
    ##//----------------------
    fi
}
#//=========================================================
### [N] "===>環境設定(量身訂做)"
setup_dockerenv()
{
    ##//環境設定(sudo)
    if [ -f "/etc/sudoers" ]; then
        ##//無須密碼
        ##//sed -i 's/ALL=(ALL:ALL) ALL/ALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers
        sed -i 's/root\tALL=(ALL:ALL) ALL/root\tALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers
        sed -i 's/\%sudo\tALL=(ALL:ALL) ALL/\%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers
        ##//內嵌引用(預設帳號)
        ##//echo >> /etc/sudoers
        ##//echo "$IDSET ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
        ##//echo "%$IDSET ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
        ##//[NR]echo "$username ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
        ##//[NR]sudo sh -c "echo $username ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
        ##//附加引用(sudoers.usersetup)
        ##//if [ -f "/etc/sudoers.usersetup" ]; then echo "#include /etc/sudoers.usersetup" >> /etc/sudoers; fi
    fi
    ##//環境設定(shell)
    echo 'dash dash/sh boolean false' | debconf-set-selections
    dpkg-reconfigure -f noninteractive dash
    ##//環境設定(區域)(語系)
    apt-get install -y locales language-pack-zh-hant language-pack-zh-hant-base
    ##
    ##//新增系統語系
    #//sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    #//sed -i 's/# zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/' /etc/locale.gen
    #//#sed -i '/^#.* zh_TW.* /s/^#//' /etc/locale.gen
    #//#sed -i "s/^# $LANG.*/$LANG.UTF-8 UTF-8/" /etc/locale.gen
    #//#localedef -c -i en_US -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
    #//#localedef -c -i zh_TW -f UTF-8 -A /usr/share/locale/locale.alias zh_TW.UTF-8
    ##
    /usr/sbin/locale-gen zh_TW.UTF-8 en_US.UTF-8
    ##
    ##//設定系統語系!!功能相同!!
    ##//------------
    dpkg-reconfigure -f noninteractive locales
    ##//------------
    update-locale LANGUAGE="en_US" LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8"
    #//update-locale LANGUAGE="zh_TW" LANG="zh_TW.UTF-8" LC_ALL="zh_TW.UTF-8"
    #//update-locale LANGUAGE="zh_TW:zh:en_US:en" LANG="zh_TW.UTF-8" LC_ALL="zh_TW.UTF-8"
    ##//------------
    #//#echo 'LANGUAGE=zh_TW:zh:en_US:en' > /etc/default/locale
    #//#echo 'LANG=zh_TW.UTF-8:en_US.UTF-8' > /etc/default/locale
    #//#echo 'LC_ALL=zh_TW.UTF-8:en_US.UTF-8' > /etc/default/locale
    #//#echo 'LC_CTYPE=zh_TW.UTF-8' > /etc/default/locale
    #//#echo 'LC_MESSAGES=zh_TW.UTF-8' > /etc/default/locale
    ##//------------
    ##
    ##locale-gen
    ##update-locale
    ##locale && locale -a
    ##//環境設定(區域)(時區)
    if [ "$IDTZD" != "Etc/UTC" ]; then
        ln -snf "/usr/share/zoneinfo/$IDTZD" /etc/localtime
        echo $IDTZD > /etc/timezone
        dpkg-reconfigure -f noninteractive tzdata
    fi
}
#//=========================================================
### [N] "===>帳號設定(登入對應)(權限、名稱)(全新設定)"
setup_usertwin_fixed()
{
    ##//------------------------------------------
    ##//==[crops/poky]https://github.com/crops/poky-container/blob/master/Dockerfile
    ##//==[crops/poky](dockerfile)[s](引用上述文件)
    ##//------------------------------------------
    ##//ENTRYPOINT & CMD
    ##//[=>]進入點 => 同時存在時以 ENTRYPOINT 為主，CMD 成為 ENTRYPOINT 的參數
    ##//[=>]呼叫時 => ENTRYPOINT 不可被覆寫 而 CMD 可以
    ##//------------------------------------------
    ##//[??]繼承 crops/poky 映像時，新映像如果不指定 ENTRYPOINT，會沿用 crops/poky 映像的 ENTRYPOINT
    ##//[??]繼承 crops/poky 映像時，新映像繼承了所有 crops/poky 建立時 Dockerfile 的行為，所以原先的 ENTRYPOINT 會被執行
    ##//(啟動流程)
    ##//[=>]ENTRYPOINT ["/usr/bin/distro-entry.sh", "/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
    ##//[=>]ENTRYPOINT ["/usr/bin/dumb-entry.sh",   "/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
    ##//(!進入起點!)
    ##//dumb-entry.sh => poky-entry.py
    ##//poky-entry.py => poky_usersetup.py --username=$IDSET --workdir={wd} {idargs} poky_launch.sh {wd}
    ##//poky_usersetup.py => sudo poky_useradd.sh & sudo poky_groupadd.sh & "sudo -E -H -u"
    ##//poky_useradd.sh => useradd -N -g $gid -m $skelarg -o -u $uid "$username" [帳號建立]
    ##//poky_launch.sh => exec "$@" [帳號登入(shell)]
    ##//------------------------------------------
    ##//(!進入起點!)[=帳號登入=](權限=>USER)
    ##//==[crops/poky](poky-launch.sh)(=Modify=!!)(poky_launch.sh)
    lvn="poky_launch.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        echo '#!/bin/bash' >> ${lvt}
        echo >> ${lvt}
        echo 'workdir=$1; shift; cd $workdir;' >> ${lvt}
        echo >> ${lvt}
        echo '##登入提示' >> ${lvt}
        echo 'echo "=========="' >> ${lvt}
        echo 'echo '"'"'$@        => '"'"'$@' >> ${lvt}
        echo 'echo '"'"'$workdir  => '"'"'$workdir' >> ${lvt}
        echo "echo '\$HOME     => '\$HOME" >> ${lvt}
        echo "echo '\$USER     => '\$USER" >> ${lvt}
        echo "echo '\$uid \$gid => '\$(id -u) \$(id -g)" >> ${lvt}
        echo "echo \"==========\"" >> ${lvt}
        ##//echo "OSKV=\`uname -r | sed 's/-generic//g'\`" >> ${lvt}
        ##//echo "OSRV=\`cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/DISTRIB_RELEASE=//g'\`" >> ${lvt}
        ##//echo 'echo "[$OSRV] ($OSKV)"' >> ${lvt}
        ##//echo "date" >> ${lvt}
        echo >> ${lvt}
        echo '##環境設定(輔助)(特定)(專用)' >> ${lvt}
        echo 'if [ -f "/usr/bin/dockerpoky.sh" ]; then source "/usr/bin/dockerpoky.sh"; fi;' >> ${lvt}
        echo >> ${lvt}
        echo 'if [ $# -gt 0 ]; then' >> ${lvt}
        echo '    exec "$@"' >> ${lvt}
        echo 'else' >> ${lvt}
        echo '    exec bash -i' >> ${lvt}
        echo 'fi' >> ${lvt}
    fi
    ##//------------------------------------------
    ##//(!進入起點!)[初始環境](權限=>ROOT)
    ##//==[crops/poky](distro-entry.sh)(=Modify=)(dumb-entry.sh)
    lvn="dumb-entry.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        echo '#!/bin/bash' >> ${lvt}
        echo >> ${lvt}
        echo '##環境設定(輔助)(特定)(通用)' >> ${lvt}
        echo 'if [ -f "/usr/bin/dockerdumb.sh" ]; then source "/usr/bin/dockerdumb.sh"; fi;' >> ${lvt}
        echo >> ${lvt}
        echo 'if [ $IDMSG != "0" ]; then echo $@; fi' >> ${lvt}
        echo 'if [ $IDNON == "0" ]; then' >> ${lvt}
        echo '    exec "$@"' >> ${lvt}
        echo 'else' >> ${lvt}
        echo '    sh -c "${4:-bash}"' >> ${lvt}
        echo 'fi' >> ${lvt}
    fi
    ##//------------------------------------------
    ##//(!進入起點!)[初始環境][帳號設定](動態處理)(權限=>ROOT)
    ##//==[crops/poky](poky-entry.py)(=Modify=!!)
    lvn="poky-entry.py"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        echo '#!/usr/bin/env python3' >> ${lvt}
        echo '# -*- coding:utf-8 -*-' >> ${lvt}
        echo '# coding=utf-8' >> ${lvt}
        echo >> ${lvt}
        echo 'import argparse' >> ${lvt}
        echo 'import grp' >> ${lvt}
        echo 'import os' >> ${lvt}
        echo 'import pwd' >> ${lvt}
        echo 'import subprocess' >> ${lvt}
        echo 'import sys' >> ${lvt}
        echo >> ${lvt}
        echo "def sanity_default():" >> ${lvt}
        echo '    uid = 1000' >> ${lvt}
        echo '    gid = 1000' >> ${lvt}
        echo '    return uid, gid' >> ${lvt}
        echo >> ${lvt}
        echo 'parser = argparse.ArgumentParser()' >> ${lvt}
        echo "parser.add_argument('--workdir'," >> ${lvt}
        echo "                    default='/home/sw'," >> ${lvt}
        echo "                    help='The active directory once the container is running.'" >> ${lvt}
        echo "                         'In the abscence of the \"id\" argument, the uid and gid'" >> ${lvt}
        echo "                         'of the workdir will also be used for the user in the container.')" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument('--id'," >> ${lvt}
        echo "                    nargs='?'," >> ${lvt}
        echo "                    help='uid and gid to use for the user inside the container.'" >> ${lvt}
        echo "                         'It should be in the form uid:gid')" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument('cmd'," >> ${lvt}
        echo "                    nargs=argparse.REMAINDER," >> ${lvt}
        echo "                    help='command to run after setting up container,'" >> ${lvt}
        echo "                         'often used for testing.')" >> ${lvt}
        echo >> ${lvt}
        echo 'args = parser.parse_args()' >> ${lvt}
        echo 'args.workdir = os.getcwd()' >> ${lvt}
        echo 'cpath = "/home/"' >> ${lvt}
        echo 'cname = os.getenv("IDSET")' >> ${lvt}
        echo >> ${lvt}
        echo 'if type(cname) != "str":' >> ${lvt}
        echo '    cname = str(cname)' >> ${lvt}
        echo >> ${lvt}
        echo 'if len(os.getenv("IDSET")) != 0:' >> ${lvt}
        echo '    cpath = cpath + cname' >> ${lvt}
        echo 'else:' >> ${lvt}
        echo '    cpath = cpath + "sw"' >> ${lvt}
        echo >> ${lvt}
        echo 'uid = ""' >> ${lvt}
        echo 'gid = ""' >> ${lvt}
        echo 'if args.id:' >> ${lvt}
        echo '    uid, gid = args.id.split(":")' >> ${lvt}
        echo '    if os.getenv("IDMSG") == str(1):' >> ${lvt}
        echo '        print("id select 0")' >> ${lvt}
        echo '##優先權(1) [-w] (對應目錄)' >> ${lvt}
        echo 'elif args.workdir != "/home" and os.path.exists(args.workdir):' >> ${lvt}
        echo '    uid = os.stat(os.getcwd()).st_uid' >> ${lvt}
        echo '    gid = os.stat(os.getcwd()).st_gid' >> ${lvt}
        echo '    if os.getenv("IDMSG") == str(1):' >> ${lvt}
        echo '        print("id select 1")' >> ${lvt}
        echo '##優先權(2) [-e] (對應名稱)' >> ${lvt}
        echo 'elif os.path.exists(cpath):' >> ${lvt}
        echo '    uid = os.stat(cpath).st_uid' >> ${lvt}
        echo '    gid = os.stat(cpath).st_gid' >> ${lvt}
        echo '    if os.getenv("IDMSG") == str(1):' >> ${lvt}
        echo '        print("id select 2")' >> ${lvt}
        echo '##優先權(3) 預設' >> ${lvt}
        echo 'else:' >> ${lvt}
        echo '    uid, gid = sanity_default()' >> ${lvt}
        echo '    if os.getenv("IDMSG") == str(1):' >> ${lvt}
        echo '        print("id select 3")' >> ${lvt}
        echo >> ${lvt}
        echo 'if uid == 0 or gid == 0:' >> ${lvt}
        echo '    if cname != "root":' >> ${lvt}
        echo '        uid, gid = sanity_default()' >> ${lvt}
        echo '    if os.getenv("IDMSG") == str(1):' >> ${lvt}
        echo '        print("change uid|gid")' >> ${lvt}
        echo >> ${lvt}
        echo 'idargs = "--uid={} --gid={}".format(uid, gid)' >> ${lvt}
        echo >> ${lvt}
        echo '##環境資訊' >> ${lvt}
        echo 'if os.getenv("IDMSG") == str(1):' >> ${lvt}
        echo '    print("==========[poky-entry.py]")' >> ${lvt}
        echo '    print("argsid  ",args.id)' >> ${lvt}
        echo '    print("argcmd  ",args.cmd)' >> ${lvt}
        echo '    print("workdir ",args.workdir)' >> ${lvt}
        echo '    print("getcwd  ",os.getcwd())' >> ${lvt}
        echo '    print("st_uid  ",os.stat(os.getcwd()).st_uid)' >> ${lvt}
        echo '    print("st_gid  ",os.stat(os.getcwd()).st_gid)' >> ${lvt}
        echo '    print()' >> ${lvt}
        echo '    print("cname   ",cname)' >> ${lvt}
        echo '    print("cpath   ",cpath)' >> ${lvt}
        echo '    if os.path.exists(cpath):' >> ${lvt}
        echo '        print("st_uid  ",os.stat(cpath).st_uid)' >> ${lvt}
        echo '        print("st_gid  ",os.stat(cpath).st_gid)' >> ${lvt}
        echo '    print("----------")' >> ${lvt}
        echo '    print("uid     ",uid)' >> ${lvt}
        echo '    print("gid     ",gid)' >> ${lvt}
        echo '    print("idargs  ",idargs)' >> ${lvt}
        echo '    print()' >> ${lvt}
        echo >> ${lvt}
        SETENVDIRECT="1"
        if [ "$SETENVDIRECT" = "1" ]; then
        echo 'try:' >> ${lvt}
        echo "    ##檢查是否存在(gid)" >> ${lvt}
        echo '    grp.getgrgid(gid)' >> ${lvt}
        echo 'except KeyError:' >> ${lvt}
        echo "    ##不存在時配置" >> ${lvt}
        echo '    cmd = "sudo poky_groupadd.sh {} {}".format(gid, cname)' >> ${lvt}
        echo '    subprocess.check_call(cmd.split(), stdout=sys.stdout, stderr=sys.stderr)' >> ${lvt}
        echo >> ${lvt}
        echo 'try:' >> ${lvt}
        echo "    ##檢查是否存在(uid)" >> ${lvt}
        echo '    pwd.getpwuid(uid)' >> ${lvt}
        echo 'except KeyError:' >> ${lvt}
        echo "    ##不存在時配置" >> ${lvt}
        echo '    cmd = "sudo poky_useradd.sh {} {} {}".format(uid, gid, cname)' >> ${lvt}
        echo '    subprocess.check_call(cmd.split(), stdout=sys.stdout, stderr=sys.stderr)' >> ${lvt}
        echo >> ${lvt}
        echo 'cmd = "sudo -E -H -u {wn} poky_launch.sh {wd}".format(wn=cname, wd=args.workdir)' >> ${lvt}
        else
        echo 'cmd = """poky_usersetup.py --username={wn} --workdir={wd} {idargs} poky_launch.sh {wd}""" .format(wn=cname, wd=args.workdir, idargs=idargs)' >> ${lvt}
        fi
        echo 'cmd = cmd.split()' >> ${lvt}
        echo "##追加參數" >> ${lvt}
        echo 'if args.cmd:' >> ${lvt}
        echo '    cmd.extend(args.cmd)' >> ${lvt}
        echo >> ${lvt}
        echo 'if os.getenv("IDMSG") == str(1):' >> ${lvt}
        echo '    print("cmd     ",cmd)' >> ${lvt}
        echo >> ${lvt}
        echo 'os.execvp(cmd[0], cmd)' >> ${lvt}
    fi
    ##//------------------------------------------
    ##//[帳號建立](命令執行 & 轉換身分)
    ##//(usersetup.py)(=Modify=)(poky_usersetup.py)
    lvn="poky_usersetup.py"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    if [ "$SETENVDIRECT" != "1" ]; then touch ${lvt}; fi
    if [ -f "${lvt}" ]; then
        echo '#!/usr/bin/env python3' >> ${lvt}
        echo '# -*- coding:utf-8 -*-' >> ${lvt}
        echo '# coding=utf-8' >> ${lvt}
        echo >> ${lvt}
        echo 'import argparse' >> ${lvt}
        echo 'import grp' >> ${lvt}
        echo 'import os' >> ${lvt}
        echo 'import pwd' >> ${lvt}
        echo 'import subprocess' >> ${lvt}
        echo 'import sys' >> ${lvt}
        echo >> ${lvt}
        echo "def sanity_check_workdir(workdir):" >> ${lvt}
        echo "    st = os.stat(workdir)" >> ${lvt}
        echo "    if st.st_uid == 0 or st.st_gid == 0:" >> ${lvt}
        echo "        print('The uid:gid for \"{}\" is \"{}:{}\".'" >> ${lvt}
        echo "              'The uid and gid must be non-zero.'" >> ${lvt}
        echo "              'Please check to make sure the \"volume\" or \"bind\"'" >> ${lvt}
        echo "              'specified using either \"-v\" or \"--mount\" to docker,'" >> ${lvt}
        echo "              'exists and has a non-zero uid:gid.'.format(workdir, st.st_uid, st.st_gid))" >> ${lvt}
        echo "        return False" >> ${lvt}
        echo "    return True" >> ${lvt}
        echo >> ${lvt}
        echo "parser = argparse.ArgumentParser()" >> ${lvt}
        echo "parser.add_argument(\"--uid\"," >> ${lvt}
        echo "                    type=int," >> ${lvt}
        echo "                    help=\"uid to use for the user.\"" >> ${lvt}
        echo "                         \"If not specified, the uid of the owner of WORKDIR is used\")" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument(\"--gid\"," >> ${lvt}
        echo "                    type=int," >> ${lvt}
        echo "                    help=\"gid to use for the initial login group for the user.\"" >> ${lvt}
        echo "                         \"If not specified, the gid of WORKDIR is used\")" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument(\"--skel\"," >> ${lvt}
        echo "                    default=\"\"," >> ${lvt}
        echo "                    help=\"Directory to use as the skeleton for user's home\")" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument(\"--username\"," >> ${lvt}
        echo "                    default='sw'," >> ${lvt}
        echo "                    help=\"username of the user to be modified\")" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument(\"--workdir\"," >> ${lvt}
        echo "                    default=\"/home/sw\"," >> ${lvt}
        echo "                    help=\"directory to base the uid on\")" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument(\"cmd\"," >> ${lvt}
        echo "                    help=\"command to exec after setting up the user\")" >> ${lvt}
        echo >> ${lvt}
        echo "parser.add_argument(\"args\"," >> ${lvt}
        echo "                    default=\"\"," >> ${lvt}
        echo "                    nargs=argparse.REMAINDER)" >> ${lvt}
        echo >> ${lvt}
        echo 'args = parser.parse_args()' >> ${lvt}
        echo >> ${lvt}
        echo 'if not args.uid:' >> ${lvt}
        echo '    st = os.stat(args.workdir)' >> ${lvt}
        echo '    args.uid = st.st_uid' >> ${lvt}
        echo '    if not sanity_check_workdir(args.workdir):' >> ${lvt}
        echo '        sys.exit(1)' >> ${lvt}
        echo >> ${lvt}
        echo 'if not args.gid:' >> ${lvt}
        echo '    st = os.stat(args.workdir)' >> ${lvt}
        echo '    args.gid = st.st_gid' >> ${lvt}
        echo '    if not sanity_check_workdir(args.workdir):' >> ${lvt}
        echo '        sys.exit(1)' >> ${lvt}
        echo >> ${lvt}
        echo 'try:' >> ${lvt}
        echo "    ##檢查是否存在(gid)" >> ${lvt}
        echo '    grp.getgrgid(args.gid)' >> ${lvt}
        echo 'except KeyError:' >> ${lvt}
        echo "    ##不存在時配置" >> ${lvt}
        echo '    cmd = "sudo poky_groupadd.sh {} {}".format(args.gid, args.username)' >> ${lvt}
        echo '    subprocess.check_call(cmd.split(), stdout=sys.stdout, stderr=sys.stderr)' >> ${lvt}
        echo >> ${lvt}
        echo 'try:' >> ${lvt}
        echo "    ##檢查是否存在(uid)" >> ${lvt}
        echo '    pwd.getpwuid(args.uid)' >> ${lvt}
        echo 'except KeyError:' >> ${lvt}
        echo "    ##不存在時配置" >> ${lvt}
        echo '    cmd = "sudo poky_useradd.sh {} {} {} {}".format(args.uid, args.gid, args.username, args.skel)' >> ${lvt}
        echo '    subprocess.check_call(cmd.split(), stdout=sys.stdout, stderr=sys.stderr)' >> ${lvt}
        echo >> ${lvt}
        echo 'usercmd = [ args.cmd ] + args.args' >> ${lvt}
        echo 'cmd = "sudo -E -H -u {} ".format(args.username)' >> ${lvt}
        echo 'cmd = cmd.split() + usercmd' >> ${lvt}
        echo >> ${lvt}
        echo 'os.execvp(cmd[0], cmd)' >> ${lvt}
    fi
    ##//[帳號建立](群組配對)
    ##//(restrict_groupadd.sh)(=Modify=)(poky_groupadd.sh)
    lvn="poky_groupadd.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        echo '#!/bin/bash' >> ${lvt}
        echo >> ${lvt}
        echo 'gid=$(($1))' >> ${lvt}
        echo 'groupname=$2' >> ${lvt}
        echo >> ${lvt}
        echo 'if [ $gid -eq 0 ]; then' >> ${lvt}
        echo '    echo "Refusing to use a gid of 0"' >> ${lvt}
        echo '    exit 1' >> ${lvt}
        echo 'else' >> ${lvt}
        echo '    groupadd -o -g $gid "$groupname"' >> ${lvt}
        echo 'fi' >> ${lvt}
    fi
    ##//[帳號建立](個人配對)
    ##//(restrict_useradd.sh)(=Modify=!!)(poky_useradd.sh)
    lvn="poky_useradd.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        echo '#!/bin/bash' >> ${lvt}
        echo >> ${lvt}
        echo 'uid=$(($1))' >> ${lvt}
        echo 'gid=$(($2))' >> ${lvt}
        echo 'username=$3' >> ${lvt}
        echo 'if [ "$4" != "" ]; then skelarg="-k $4"; fi' >> ${lvt}
        echo >> ${lvt}
        echo 'if [ $uid -eq 0 ]; then' >> ${lvt}
        echo '    echo "Refusing to use a uid of 0 (root)"' >> ${lvt}
        echo '    exit 1' >> ${lvt}
        echo 'elif [ $gid -eq 0 ]; then' >> ${lvt}
        echo '    echo "Refusing to use a gid of 0 (root)"' >> ${lvt}
        echo '    exit 1' >> ${lvt}
        echo 'else' >> ${lvt}
        echo '    ##建立帳號 IDSET <=> username' >> ${lvt}
        echo '    if [ -d "/home/$username" ]; then' >> ${lvt}
        echo '        useradd -M $skelarg -N -g $gid -o -u $uid "$username"' >> ${lvt}
        echo '    else' >> ${lvt}
        echo '        useradd -m $skelarg -N -g $gid -o -u $uid "$username"' >> ${lvt}
        echo '    fi' >> ${lvt}
        echo '    ##添加權限 sudo' >> ${lvt}
        echo '    usermod -aG sudo "$username"' >> ${lvt}
        echo '    ##//sed -i "s/sudo:x:27:/sudo:x:27:$username/g" /etc/group' >> ${lvt}
        echo 'fi' >> ${lvt}
    fi
    ##//==[crops/poky](dockerfile)[e](引用上述文件)
    setup_userenv
}
setup_userenv()
{
    ##//環境設定(輔助)(特定)(通用)(權限=>ROOT)
    lvn="dockerdumb.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        echo '##環境設定(輔助)(特定)(通用)' >> ${lvt}
        echo >> ${lvt}
        echo '##時區對應(客製化)' >> ${lvt}
        echo "if [ \"\$IDTZD\" != \"\" ] && [ \"\$IDTZD\" != \"$IDTZD\" ]; then" >> ${lvt}
        echo "    ln -snf /usr/share/zoneinfo/\"\$IDTZD\" /etc/localtime" >> ${lvt}
        echo "    sh -c 'echo \"\$IDTZD\" > /etc/timezone'" >> ${lvt}
        echo "    sh -c 'dpkg-reconfigure -f noninteractive tzdata'" >> ${lvt}
        echo "fi" >> ${lvt}
        echo >> ${lvt}
        echo '##轉址對應(客製化)' >> ${lvt}
        echo 'if [ -f "/etc/hosts" ]; then' >> ${lvt}
        echo '    ##//echo -e "10.5.254.99\tmce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw" | sudo tee /etc/hosts' >> ${lvt}
        echo '    ##//echo '"'"'echo -e "10.5.254.99\tmce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw" >> /etc/hosts'"'"' | sudo sh' >> ${lvt}
        echo '    ##//sudo sh -c '"'"'echo "10.5.254.99\tmce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw" >> /etc/hosts'"'"'' >> ${lvt}
        echo '    sudo sh -c "echo 10.5.254.99  mce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw >> /etc/hosts"' >> ${lvt}
        echo 'fi' >> ${lvt}
        echo >> ${lvt}
    fi
    ##//環境設定(輔助)(特定)(專用)(權限=>USER)
    lvn="dockerpoky.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        ##//echo '##專用配置' >> ${lvt}
        ##//echo 'if [ -f ~/env.sh ]; then . ~/env.sh;' >> ${lvt}
        ##//echo 'elif [ -f ~/_shell_/env.sh ]; then . ~/_shell_/env.sh; fi;' >> ${lvt}
        ##//echo >> ${lvt}
        echo '##提示去除' >> ${lvt}
        echo 'touch ~/.sudo_as_admin_successful' >> ${lvt}
    fi
    ##//--------------------------------
    ##//收尾
    lvn="dockertask.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then rm -f ${lvt}; fi
    touch ${lvt}; if [ -f "${lvt}" ]; then
        echo 1 > ${lvt}
        sed -i '$a #!/bin/bash'                              ${lvt}
        sed -i '$G'                                          ${lvt}
        sed -i '$a #taskshell()'                             ${lvt}
        sed -i '$a #{'                                       ${lvt}
        sed -i '$a \    chmod 755 /usr/bin/*.sh 2>/dev/null' ${lvt}
        sed -i '$a \    chmod 755 /usr/bin/*.py 2>/dev/null' ${lvt}
        sed -i '$a #}'                                       ${lvt}
        sed -i '$G'                                          ${lvt}
        sed -i '$a #taskshell'                               ${lvt}
        sed -i '1d'                                          ${lvt}
        /bin/bash ${lvt}; sh -c "rm -f ${lvt}"
    fi
}
#//=========================================================
### [N] "===>帳號設定(登入對應)(權限、名稱)(內容修改)"
setup_usertwin_patch()
{
    ##//------------------------------------------
    ##//==[crops/poky]https://github.com/crops/poky-container/blob/master/Dockerfile
    ##//==[crops/poky](dockerfile)[s](引用上述文件)
    ##//------------------------------------------
    ##//ENTRYPOINT & CMD
    ##//[=>]進入點 => 同時存在時以 ENTRYPOINT 為主，CMD 成為 ENTRYPOINT 的參數
    ##//[=>]呼叫時 => ENTRYPOINT 不可被覆寫 而 CMD 可以
    ##//------------------------------------------
    ##//[??]繼承 crops/poky 映像時，新映像如果不指定 ENTRYPOINT，會沿用 crops/poky 映像的 ENTRYPOINT
    ##//[??]繼承 crops/poky 映像時，新映像繼承了所有 crops/poky 建立時 Dockerfile 的行為，所以原先的 ENTRYPOINT 會被執行
    ##//(啟動流程)
    ##//[=>]ENTRYPOINT ["/usr/bin/distro-entry.sh", "/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
    ##//(!進入起點!)
    ##//distro-entry.sh => poky-entry.py
    ##//poky-entry.py => usersetup.py --username=$IDSET --workdir={wd} {idargs} poky-launch.sh {wd}
    ##//usersetup.py => sudo restrict_groupadd.sh & sudo restrict_useradd.sh & "sudo -E -H -u"
    ##//restrict_useradd.sh => useradd -N -g $gid -m $skelarg -o -u $uid "$username" [帳號建立]
    ##//poky-launch.sh => exec "$@" [帳號登入(shell)]
    ##//------------------------------------------
    ##//替換登入名稱
    lvn="poky-entry.py"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "{lvt}" ]; then sed -i "s/pokyuser/$IDSET/g" {lvt}; fi
    ##//動態帳號設定(目錄權限對應)
    lvn="poky-entry.py"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then
        ##修補 => 對應預設
        sed -i "/if os.getcwd()/i\cname = os.getenv(\"IDSET\")" {lvt}
        sed -i "/if os.getcwd()/i\cpath = \'/home/\' + cname" {lvt}
        sed -i "/if os.getcwd()/i\args.workdir = os.getcwd()" {lvt}
        ##sed -i "/if os.getcwd()/i\args.workdir = \"/home/\" + cname" {lvt}
        sed -i '/if os.getcwd()/{x;p;x;}' {lvt}
        sed -i "/if os.getcwd()/,+4d" {lvt}
        sed -i "/elif args.workdir/,+4d" {lvt}
        ##修補 => 對應個人
        ##優先權(1) [-w] 排除預設&處理例外
        sed -i "/usersetup.py --username/i\elif args.workdir != \'/home\' and os.path.exists(args.workdir):" {lvt}
        sed -i "/usersetup.py --username/i\    idargs = \"--uid={} --gid={}\".format(os.stat(os.getcwd()).st_uid, os.stat(os.getcwd()).st_gid)" {lvt}
        sed -i "/usersetup.py --username/i\    if os.stat(os.getcwd()).st_uid == 0 or os.stat(os.getcwd()).st_gid == 0:" {lvt}
        sed -i "/usersetup.py --username/i\        if cname != \"root\":" {lvt}
        sed -i "/usersetup.py --username/i\            idargs = \"--uid=$IDNUM --gid=$IDNUM\"" {lvt}
        sed -i '/usersetup.py --username/{x;p;x;}' {lvt}
        ##優先權(2) [-e] 處理例外
        sed -i "/usersetup.py --username/i\elif os.path.exists(cpath):" {lvt}
        sed -i "/usersetup.py --username/i\    idargs = \"--uid={} --gid={}\".format(os.stat(cpath).st_uid, os.stat(cpath).st_gid)" {lvt}
        sed -i '/usersetup.py --username/{x;p;x;}' {lvt}
        ##優先權(3) 預設
        sed -i "/usersetup.py --username/i\else:" {lvt}
        sed -i "/usersetup.py --username/i\    idargs = \"--uid=$IDNUM --gid=$IDNUM\"" {lvt}
        sed -i '/usersetup.py --username/{x;p;x;}' {lvt}
        ##環境資訊
        MSG_CTL=${MSG_CTL:-NO} && if [ "$MSG_CTL" = "YES" ]; then
        sed -i "/usersetup.py --username/i\print(\"==========[poky-entry.py]\")" {lvt}
        sed -i "/usersetup.py --username/i\print(\"argsid  \",args.id)" {lvt}
        sed -i "/usersetup.py --username/i\print(\"workdir \",args.workdir)" {lvt}
        sed -i "/usersetup.py --username/i\print(\"getcwd  \",os.getcwd())" {lvt}
        sed -i "/usersetup.py --username/i\print(\"st_uid  \",os.stat(os.getcwd()).st_uid)" {lvt}
        sed -i "/usersetup.py --username/i\print(\"st_gid  \",os.stat(os.getcwd()).st_gid)" {lvt}
        sed -i "/usersetup.py --username/i\print(\"cname   \",cname)" {lvt}
        sed -i "/usersetup.py --username/i\print(\"cpath   \",cpath)" {lvt}
        sed -i "/usersetup.py --username/i\print(\"idargs  \",idargs)" {lvt}
        sed -i "/usersetup.py --username/i\print()" {lvt}
        sed -i '/usersetup.py --username/{x;p;x;}' {lvt}
        fi
        sed -i "s/usersetup.py --username=$IDSET/usersetup.py --username={wn}/g" {lvt}
        sed -i 's/.format(wd=args.workdir/.format(wn=cname, wd=args.workdir/g' {lvt}
    fi
    ##//帳號建立
    lvn="restrict_useradd.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then
        sed -i "/useradd -N -g/i\    echo \"==========[restrict_useradd.sh]\"" ${lvt}
        sed -i "/useradd -N -g/i\    echo '\$uid      => '\$uid" ${lvt}
        sed -i "/useradd -N -g/i\    echo '\$gid      => '\$gid" ${lvt}
        sed -i "/useradd -N -g/i\    echo '\$username => '\$username" ${lvt}
        sed -i "/useradd -N -g/i\    echo '\$IDSET    => '\$IDSET" ${lvt}
        sed -i "/useradd -N -g/i\    echo '\$skelarg  => '\$skelarg" ${lvt}
        sed -i "/useradd -N -g/i\    echo '\pwd       => '\$(pwd)" ${lvt}
        sed -i "/useradd -N -g/i\    echo '\whoami    => '\$(whoami)" ${lvt}
        sed -i "/useradd -N -g/{x;p;x;}"  ${lvt}
        ##建立帳號 IDSET <=> username
        sed -i "/useradd -N -g/i\    if [ -d \"\/home\/\$username\" ]; then" ${lvt}
        sed -i "/useradd -N -g/i\        1111111111" ${lvt}
        sed -i "/useradd -N -g/i\    else" ${lvt}
        sed -i "/useradd -N -g/i\        2222222222" ${lvt}
        sed -i "/useradd -N -g/i\    fi" ${lvt}
        sed -i "/useradd -N -g/i\    sed -i \"s/sudo:x:27:/sudo:x:27:\$username/g\" /etc/group" ${lvt}
        sed -i "/useradd -N -g/i\    if [ -f "/etc/sudoers.usersetup" ]; then rm -f /etc/sudoers.usersetup; fi;" ${lvt}
        sed -i "/useradd -N -g/i\    touch /etc/sudoers.usersetup;" ${lvt}
        sed -i "/useradd -N -g/i\    echo \"\$username ALL=(ALL:ALL) NOPASSWD:ALL\" >> /etc/sudoers.usersetup" ${lvt}
        sed -i "/useradd -N -g/i\    echo \"%\$username ALL=(ALL:ALL) NOPASSWD:ALL\" >> /etc/sudoers.usersetup" ${lvt}
        sed -i "/useradd -N -g/{x;p;x;}"  ${lvt}
        ##保留預設帳號(帳號群組保留 IDSET <=> sw)
        USR_CTL=${USR_CTL:-NO} && if [ "$USR_CTL" = "YES" ]; then
        sed -i "/useradd -N -g/i\    if [ \"\$username\" != \"$IDSET\" ]; then" ${lvt}
        sed -i "/useradd -N -g/i\        3333333333" ${lvt}
        ##sed -i "/useradd -N -g/i\        echo \"\$IDSET:x:\$IDNUM\" >> /etc/group" ${lvt}
        sed -i "/useradd -N -g/i\        sed -i \"s/sudo:x:27:\$username/sudo:x:27:\$username,\$IDSET/g\" /etc/group" ${lvt}
        sed -i "/useradd -N -g/i\        echo \"\$IDSET ALL=(ALL:ALL) NOPASSWD:ALL\" >> /etc/sudoers.usersetup" ${lvt}
        ##sed -i "/useradd -N -g/i\        echo \"\%\$IDSET ALL=(ALL:ALL) NOPASSWD:ALL\" >> /etc/sudoers.usersetup" ${lvt}
        ##sed -i "/useradd -N -g/i\        sed -i \'\$d\' /etc/sudoers.\$IDSET" ${lvt}
        sed -i "/useradd -N -g/{x;p;x;}"  ${lvt}
        sed -i "/useradd -N -g/i\    fi" ${lvt}
        fi
        ##原先建立帳號方法停用
        sed -i "s/useradd -N -g/##useradd -N -g/g" ${lvt}
        ##處理原先無法處理替代
        sed -i "s/1111111111/useradd -M \$skelarg -N -g \$gid -o -u \$uid \"\$username\"/g" ${lvt}
        sed -i "s/2222222222/useradd -m \$skelarg -N -g \$gid -o -u \$uid \"\$username\"/g" ${lvt}
        sed -i "s/3333333333/useradd -m \$skelarg -N -g \$IDNUM               \"\$IDSET\"/g" ${lvt}
        ##sed -i "s/3333333333/useradd -m \$skelarg -N -g \$IDNUM -o -u \$IDNUM \"\$IDSET\"/g" ${lvt}
    fi
    ##//個人環境設定
    lvn="poky-launch.sh"; lvp="/usr/bin/"; lvt="${lvp}${lvn}";
    if [ -f "${lvt}" ]; then
        sed -i "/exec \"\$@\"/i\    echo \"==========\"" ${lvt}
        sed -i "/exec \"\$@\"/i\    echo '\$@        => '\$@" ${lvt}
        sed -i "/exec \"\$@\"/i\    echo '\$workdir  => '\$workdir" ${lvt}
        sed -i "/exec \"\$@\"/i\    echo '\$HOME     => '\$HOME" ${lvt}
        sed -i "/exec \"\$@\"/i\    echo '\$USER     => '\$USER" ${lvt}
        sed -i "/exec \"\$@\"/i\    echo '\$uid \$gid => '\$(id -u) \$(id -g)" ${lvt}
        sed -i "/exec \"\$@\"/i\    echo \"==========\"" ${lvt}
        sed -i "/exec \"\$@\"/{x;p;x;}" ${lvt}
        ##轉載GIT設定(個人)
        sed -i "/exec \"\$@\"/i\    if [ \"\$workdir\" != \"\$HOME\" ]; then" ${lvt}
        sed -i "/exec \"\$@\"/i\        if [ -f \".gitconfig\" ]; then cp .git* ~\" fi;" ${lvt}
        sed -i "/exec \"\$@\"/i\    fi" ${lvt}
        sed -i "/exec \"\$@\"/{x;p;x;}" ${lvt}
        ##對應GIT設定(主機)
        sed -i "/exec \"\$@\"/i\    if [ -f \"/etc/hosts\" ]; then" ${lvt}
        #sed -i "/exec \"\$@\"/i\        echo -e \"10.5.254.99\tmce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw\" | sudo tee /etc/hosts" ${lvt}
        #sed -i "/exec \"\$@\"/i\        echo 'echo -e \"10.5.254.99\tmce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw\" >> /etc/hosts' | sudo sh" ${lvt}
        ##sed -i "/exec \"\$@\"/i\        sudo sh -c 'echo -e \"10.5.254.99\tmce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw\" >> /etc/hosts'" ${lvt}
        sed -i "/exec \"\$@\"/i\        sudo sh -c \"echo 10.5.254.99  mce-tfs03  mce-tfs03.taipei.via.com.tw  mce-tfs03.via.com.tw >> /etc/hosts\"" ${lvt}
        sed -i "/exec \"\$@\"/i\    fi" ${lvt}
        sed -i "/exec \"\$@\"/{x;p;x;}" ${lvt}
        ##提示去除
        sed -i "/exec \"\$@\"/i\    touch ~/.sudo_as_admin_successful" ${lvt}
        sed -i "/exec \"\$@\"/{x;p;x;}" ${lvt}
        ##移除無用目錄
        sed -i "/exec \"\$@\"/i\    if [ -d \"\/home\/yoctouser\" ]; then sudo rm -rf /home/yoctouser; fi;" ${lvt}
        sed -i "/exec \"\$@\"/i\    if [ -d \"\/home\/usersetup\" ]; then sudo rm -rf /home/usersetup; fi;" ${lvt}
        sed -i "/exec \"\$@\"/{x;p;x;}"  ${lvt}
    fi
}
#//=========================================================
syntax_clear()
{
    local lvpath=""; lvpath="/usr/bin/";
    rm -f ${lvpath}dockersetup_brain.sh 2>/dev/null

    if false; then
    rm -f ${lvpath}dockersetup_brain.sh \
          2>/dev/null
    fi
}
syntax_default()
{
    SETENVBRAIN="1"
    if [ "$SETENVBRAIN" = "1" ]; then
    	setup_dumb
    	setup_dockerenv
    	setup_usertwin_fixed
    	#//setup_usertwin_patch
    fi
    syntax_clear
}
#//=========================================================
syntax_default