#!/bin/sh
#//#!/bin/bash

##//[N] 查詢當前系統安裝套件

#//=========================================================
syntax_default()
{
    dpkg -l | awk {' print $2 '} > dpkg.txt
}
#//=========================================================
syntax_default