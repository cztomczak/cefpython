#!/bin/bash

# Stop on first error:
# set -e

bash ./build_all.sh 99.99

if [ ! -d "dist/" ]; then echo "ERROR: dist/ does not exist" && exit 1; fi;
cd dist/

cwd=$(pwd)
yes | pip uninstall cefpython3

pip install --upgrade cefpython3 --no-index --find-links=file://$cwd
if [ $? -ne 0 ]; then echo "ERROR: pip install cefpython3..." && exit 1; fi;
cd ../

cd ../../wx-subpackage/examples/

python sample1.py
#if [ $? -ne 0 ]; then echo "ERROR: python sample1.py" && exit 1; fi;

python sample2.py
#if [ $? -ne 0 ]; then echo "ERROR: python sample2.py" && exit 1; fi;

python sample3.py
#if [ $? -ne 0 ]; then echo "ERROR: python sample3.py" && exit 1; fi;

cd ../../mac/installer/

yes | pip uninstall cefpython3
