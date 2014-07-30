set -o verbose
sudo rm -rf cefpython3-31.0-linux-64bit-setup/
python make-setup.py -v 31.0
cd cefpython3-31.0-linux-64bit-setup/
sudo python setup.py install
cd examples/wx/
python sample1.py
