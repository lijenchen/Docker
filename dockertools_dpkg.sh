#!/bin/sh
#//#!/bin/bash

##//[N] �d�߷��e�t�Φw�ˮM��

#//=========================================================
syntax_default()
{
    dpkg -l | awk {' print $2 '} > dpkg.txt
}
#//=========================================================
syntax_default