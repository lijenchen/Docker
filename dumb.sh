#!/bin/sh
#//#!/bin/bash
#//=========================================================
syntax_default()
{
    ##exec /usr/bin/dumb-init -- /usr/bin/poky-entry.py bash
    ##exec /usr/bin/dumb-init /usr/bin/poky-entry.py bash
    ##在 Dockerfile 中，加入 -- ，避免 dumb-init 參數混淆
    #exec /usr/bin/dockersetup_dumb.sh
    bash /usr/bin/dockersetup_dumb.sh
}
#//=========================================================
syntax_default "$@"