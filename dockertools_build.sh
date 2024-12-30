#!/bin/sh
#//#!/bin/bash

##//[N] 根據設定檔[手動&自動]建立映像

#//=========================================================
docker_clear()
{
    rm *.bak 2>/dev/null;
    docker builder prune -f; docker buildx prune -f;
    docker images;
}
docker_cmd()
{
    if [ -n "$1" ]; then
    #if [ "$1" != "" ]; then
        if [ "$debug" = "1" ]; then echo $1; else $1; fi
    fi;
}
#//=========================================================
docker_clean()
{
    lists="u22 u18"; lvtv="v2";
    for var in $lists; do lvtag="$var:$lvtv"; docker rmi $lvtag; done
    lists="u22 u18"; lvtv="v2v";
    for var in $lists; do lvtag="$var:$lvtv"; docker rmi $lvtag; done
}
#//=========================================================
docker_twin()
{
    #if [ -n "$lvtag" ]; then
    if [ "$lvtag" != "" ]; then
        lvcmd="docker tag $lvtag welkinchen/$lvtag"; docker_cmd "$lvcmd";
        lvcmd="docker push welkinchen/$lvtag"; docker_cmd "$lvcmd";
        lvcmd="docker rmi welkinchen/$lvtag"; docker_cmd "$lvcmd";
        #---------------------
        lvtmp="$lvtn""latest";
        lvcmd="docker tag $lvtag welkinchen/$lvtmp"; docker_cmd "$lvcmd";
        lvcmd="docker push welkinchen/$lvtmp"; docker_cmd "$lvcmd";
        lvcmd="docker rmi welkinchen/$lvtmp"; docker_cmd "$lvcmd";
    fi;
}
#//=========================================================
docker_build()
{
    if [ "$lvfile" != "" ] && [ -f "$lvfile" ] ; then
        lvcmd="docker build --no-cache -t $lvtag -f $lvfile ."; docker_cmd "$lvcmd";
    fi;
}
docker_auto()
{
    #lists="Dockerfile.poky.18 Dockerfile.poky.22";
    lists="Dockerfile.ubuntu.18 Dockerfile.ubuntu.22";
    #lists="Dockerfile.ubuntu.16 Dockerfile.ubuntu.18 Dockerfile.ubuntu.22";
    local lvtv="v2";
    local debug="0";
    for var in $lists; do
        ##//lvnum=`echo $var | sed 's/Dockerfile.ubuntu.//g'`;
        lvnum=`echo $var | cut -d '.' -f3`;
        lvtn="u$lvnum:";
        lvtag="$lvtn$lvtv";
        lvfile=$var;
        docker_build;
        #//docker_twin;
        echo
    done
}
#//=========================================================
docker_foot()
{
    #lvtag="u22:v2v"; lvfile="Dockerfile.under"; docker_build;

    lvtag="u22:v2v"; lvfile="Dockerfile.under.ubuntu.22"; docker_build;
    lvtag="u18:v2v"; lvfile="Dockerfile.under.ubuntu.18"; docker_build;
    #lvtag="p22:v2v"; lvfile="Dockerfile.under.poky.22"; docker_build;

    #//lvtag="u24:v2"; lvfile="Dockerfile.above.ubuntu.24"; docker_build;
    #//lvtag="u22:v2"; lvfile="Dockerfile.above.ubuntu.22"; docker_build;
    #//lvtag="u18:v2"; lvfile="Dockerfile.above.ubuntu.18"; docker_build;
    #//lvtag="u16:v2"; lvfile="Dockerfile.above.ubuntu.16"; docker_build;
    ##//lvtag="p22:v2"; lvfile="Dockerfile.above.poky.22"; docker_build;
    ##//lvtag="p18:v2"; lvfile="Dockerfile.above.poky.18"; docker_build;
    #
    #docker build --no-cache -t u18:v2 -f Dockerfile.above.ubuntu.18 .
    #docker build --no-cache -t u22:v2 -f Dockerfile.above.ubuntu.22 .
    #
    echo .
}
docker_tail()
{   #本機產出替換
    lvtv="v2"; lvtag="u18"; docker rmi $lvtag; docker tag $lvtag:$lvtv $lvtag; docker rmi $lvtag:$lvtv;
}
docker_down()
{   #主機下載替換
    lvtag="u18"; docker rmi $lvtag; docker pull welkinchen/$lvtag; docker tag welkinchen/$lvtag $lvtag; docker rmi welkinchen/$lvtag;
}
#//=========================================================
syntax_default()
{
    #docker_auto
    #docker_foot
    docker_clear
}
#//=========================================================
syntax_default