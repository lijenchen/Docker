#!/bin/sh
#//#!/bin/bash
##//[N] �إ߹����ؿ����b�����ഫ�M�g����
#//=========================================================
syntax_default()
{
    ##exec /usr/bin/dumb-init -- /usr/bin/poky-entry.py bash
    ##exec /usr/bin/dumb-init /usr/bin/poky-entry.py bash
    ##�b Dockerfile ���A�[�J -- �A�קK dumb-init �ѼƲV�c
    #exec docker.dumb.sh
    bash docker.dumb.sh
}
#//=========================================================
syntax_default "$@"