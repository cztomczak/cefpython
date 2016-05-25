#!/bin/bash

PATH=/usr/local/bin:$PATH
export PATH

CEF_CCFLAGS="-arch x86_64"
export CEF_CCFLAGS

ARCHFLAGS="-arch x86_64"
export ARCHFLAGS

export CC=gcc
export CXX=g++
