#!/bin/bash

PATH=/usr/local/bin:$PATH
export PATH
alias python="arch -i386 python"

CEF_CCFLAGS="-arch i386"
export CEF_CCFLAGS

ARCHFLAGS="-arch i386"
export ARCHFLAGS

export CC=gcc
export CXX=g++
