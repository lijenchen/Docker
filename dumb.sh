#!/bin/sh
#//#!/bin/bash
##//[N] 建立對應目錄的帳號並轉換映射身分
#//=========================================================
syntax_default()
{
    ##exec /usr/bin/dumb-init -- /usr/bin/poky-entry.py bash
    ##exec /usr/bin/dumb-init /usr/bin/poky-entry.py bash
    ##在 Dockerfile 中，加入 -- ，避免 dumb-init 參數混淆
    #exec docker.dumb.sh
    bash docker.dumb.sh
}
#//=========================================================
syntax_default "$@"