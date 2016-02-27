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
make_distrib.py - make distribution packages (msi, wheel, deb pkg and more)
run.py          - rebuild and install if changed, and run example(s)
test_distrib.py - for all distribution packages install each of them
                  and run unit tests and all examples
toc.py          - generate Table of contents for .md files
translator.py   - generate code from the CEF header files
unittests.py    - run unit tests
```
