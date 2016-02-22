### Requirements

Before running any of tools install dependencies using PIP:
```cmd
pip install -r requirements.txt
```

### Tools

```text
apidocs.py      - generate API docs from Cython sources
automate.py     - download CEF binaries, build and optionally install/run
build.py        - build the cefpython module
doctoc.py       - generate table of contents for all .md in docs/
make_distrib.py - make distribution packages (msi, wheel, deb pkg and more)
run.py          - rebuild and install if changed, and run example(s)
setpython.bat   - change python installation in PATH (Windows)
setpython.sh    - change python installation in PATH (Linux and Mac)
test_distrib.py - for all distribution packages install each of them
                  and run unit tests and all examples
translator.py   - generate code from the CEF header files
unittests.py    - run unit tests
```
