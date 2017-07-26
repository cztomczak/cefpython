# Contributing code

This document provides information for those who would like to
contribute new code to the CEF Python project.


Table of contents:
* [Requirements](#requirements)
* [Tools](#tools)
* [Python / Cython style guidelines](#python--cython-style-guidelines)
* [How to debug CEF stack trace](#how-to-debug-cef-stack-trace)


## Requirements

- Pull requests should be sent for the master branch
- Your code should follow the [style guidelines](#python--cython-style-guidelines)
- Pull request should implement only one feature at a time, so that
  reviewing them is easy. If you have implemented several features
  then send them as sepearate pull requests. If not sure then ask
  on the [Forum](https://groups.google.com/group/cefpython).
- When adding or exposing new API you should update API docs as well
  (the api/ directory)
  - Update or create new documents if necessary
  - To update table of contents (TOC) in the document run the
    tools/toc.py script
  - To update API index run the tools/apidocs.py tool
- When adding or exposing new API you should create unit tests
  for the new functionality (the unittests/ directory). If creating
  unit tests is not feasible or extremely difficult then you should
  at least provide an example through [gist.github.com](https://gist.github.com/).
- Test your code before sending PR. Run unit tests. Run various
  examples to see if your new code didn't break them. Running unit tests,
  hello_world.py, tutorial.py and screenshot.py examples is an absolute
  minimum that you must do. Please try also testing examples for
  various GUI frameworks.
- Python code should be tested using multiple Python versions. See
  [Issue #249](../../../issue/249) ("How to use pyenv to manage multiple
  Python versions on Ubuntu/Mac")
- In most cases new code should run fine on all platforms, but in
  some cases it might be required to test on all platforms before
  PR is merged
- In your pull request modify also the [Authors](../Authors) file
  to add your name and encoded email
- If you want to update CEF version then take a look at
  [Issue #264](../../../issues/264)("Workflow when updating CEF version").
- Edit Python/Cython code using PyCharm IDE to see if there are any
  style warnings for the file you're editing. If you don't see a green
  tick in the upper-right corner of the editor's code area that means
  something is wrong with your code and must be fixed. See the Tools
  section below for how to configure PyCharm for editing cefpython's
  code.


## Tools

It is recommended to use PyCharm IDE to edit Cython code. See
[Issue #232](../../../issues/232)("Using PyCharm IDE to edit
cefpython's Cython code") for details.


## Python / Cython style guidelines

* Try to comply with the [PEP 8 style guide](http://www.python.org/dev/peps/pep-0008/)
* Limit all lines to a maximum of 79 characters (comments should be shorter, max 60-65 chars)
* Do your best for the new code to be consistent with existing code base
* Use 4 spaces for indentation
* Commit unix-style newlines (\n)


## How to debug CEF stack trace

On Linux/Mac you can use gdb/lldb, see instructions on the
[KB page](Knowledge-Base.md#python-crashes-with-segmentation-fault---how-to-debug).
