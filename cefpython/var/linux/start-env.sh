#!/bin/sh

echo "Adding depot_tools to PATH"
export PATH="$PATH":`pwd`/depot_tools

echo "Switching chroot to Precise32 (Ubuntu 12.04 LTS 32 bit)"
precise32

