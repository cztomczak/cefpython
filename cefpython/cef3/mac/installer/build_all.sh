#!/bin/bash

if [ -z "$1" ]; then
    echo "ERROR: Provide an argument: version number eg. 31.2"
    exit 1
fi

echo "Removing old directories"
rm -rf cefpython3-*-setup/
rm -rf dist/

echo "Running make-setup.py"
python make-setup.py -v $1
if [ $? -ne 0 ]; then echo "ERROR: make-setup.py" && exit 1; fi;

setup_dirs=(cefpython3-*-setup)
setup_dir=${setup_dirs[0]}

echo "Packing setup directory to .tar.gz"
tar -zcvf $setup_dir.tar.gz $setup_dir/
if [ $? -ne 0 ]; then echo "ERROR: tar -zcvf $setup_dir..." && exit 1; fi;

echo "Moving setup.tar.gz to dist/"
mkdir dist/
mv $setup_dir.tar.gz dist/
if [ $? -ne 0 ]; then echo "ERROR: mv $setup_dir..." && exit 1; fi;

echo "Installing the wheel package"
pip install wheel
if [ $? -ne 0 ]; then echo "ERROR: pip install wheel" && exit 1; fi;

echo "Creating a Python Wheel package"
cd $setup_dir
python setup.py bdist_wheel
if [ $? -ne 0 ]; then echo "ERROR: python setup.py bdist_wheel" && exit 1; fi;

echo "Moving .whl package to dist/"
mv dist/*.whl ../dist/
if [ $? -ne 0 ]; then echo "ERROR: mv dist/*.whl..." && exit 1; fi;

cd ../

cd dist/
echo "Files in the dist/ directory:"
ls -l

echo "DONE"
