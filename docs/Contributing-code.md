# Contributing code

This document provides information for those who would like to
contribute new code to the CEF Python project.


Table of contents:
* [Pull requests](#pull-requests)
* [Code style](#code-style)
* [Code warnings in PyCharm](#code-warnings-in-pycharm)
* [Test your code](#test-your-code)
* [API docs](#api-docs)
* [Unit tests](#unit-tests)
* [Platforms](#platforms)
* [Authors](#authors)
* [Updating CEF version](#updating-cef-version)


## Pull requests

- Pull requests should be sent for the master branch
- Pull request should implement only one feature at a time, so that
  reviewing them is easy. If you have implemented several features
  then send them as sepearate pull requests. If not sure then ask
  on the [Forum](https://groups.google.com/group/cefpython).


## Code style

* Try to comply with the [PEP 8 style guide](http://www.python.org/dev/peps/pep-0008/)
* Follow docstring conventions described in [PEP 257](https://www.python.org/dev/peps/pep-0257/)
* Limit all lines to a maximum of 79 characters (comments should
  be shorter, max 60-65 chars)
* Do your best for the new code to be consistent with existing code base
* Use 4 spaces for indentation
* Commit unix-style newlines (\n)


## Code warnings in PyCharm

Edit Python/Cython code using PyCharm IDE to see if there are any
style warnings for the file you're editing. If you don't see a green
tick in the upper-right corner of the editor's code area that means
something is wrong with your code and must be fixed. See
[Issue #232](../../../issues/232)("Using PyCharm IDE to edit
cefpython's Cython code") for details.


## Test your code

Test your code before sending PR. Run unit tests. Run various
examples to see if your new code didn't break them. Running unit tests,
hello_world.py, tutorial.py and screenshot.py examples is an absolute
minimum that you must do. Please try also testing examples for
various GUI frameworks.

Pure Python code should be tested using multiple Python versions
(Python 2 and Python 3 at least). See [Issue #249](../../../issue/249)
("How to use pyenv to manage multiple Python versions on Ubuntu/Mac").


## API docs

When adding or exposing new API you should update API docs as well
(the api/ directory):

- Update or create new documents if necessary
- To update table of contents (TOC) in the document run the
  tools/toc.py script
- To update API index run the tools/apidocs.py script


## Unit tests

When adding or exposing new API you should create unit tests
for the new functionality (the unittests/ directory).If creating
unit tests is not feasible or extremely difficult then you should
at least provide an example through [gist.github.com](https://gist.github.com/).

CEF imposes some limits on the structure of unit tests. Most of
CEF API requires that CEF is initialized before its API is used.
So each test must start with a call to cef.Initialize, however
CEF can be initialized only once during app's lifetime. The way
python unittest module works doesn't allow to define for example
test methods named "test_1_initialize", "test_2_some", "test_3_shutdown",
after doing so some strange things happen (maybe unittest is
running these methods in separate threads). So with these
restrictions the way it works currently is that there is a
single method named test_main() in which muliple sub-tests are
run. A function named subtest_message() was defined to be able
to output results of the multiple subtests that are running inside
the test_main() method.

In main_test.py there were implemented automated assert checks
in handlers and in the external object. When class (handler or external)
defines a property that ends with "_True" or "_False" then it will
be automatically checked  whether it asserts to these values just
before CEF shutdown. There is one limitation for these type
of automatic asserts - its values should be set first
before executing normal kind of asserts, so that they are reported
correctly, otherwise you might see misleading reports about failed
asserts.

CEF Python's unit tests are run using a special script named
_test_runner.py. This script implements a way to run all unit
tests (by default with no arguments passed) and also implements
some special features like Isolated Tests along with some other
minor features for CEF special case. An isolated test is run
using a separate Python intepreter (a separate process). To mark
a Test class an isolated test just append "_IsolatedTest" in
its name. Isolated tests are required for running CEF tests
properly. The _test_runner.py script allows to run multiple CEF
isolated tests in one execution. You can define multiple
test classes like "MyTest1_IsolatedTest" and "MyTest2_IsolatedTest"
in one file, but keep in mind that you can define only a single
test method in these classes as explained earlier. Each of such
tests should have logic to initialize and shutdown CEF properly.


## Platforms

In most cases new code should run fine on all platforms, but in
some cases it might be required to test on all platforms before
PR is merged.

## Authors

In your pull request modify also the [Authors](../Authors) file
to add your name and encoded email.

## Updating CEF version

If you want to update CEF version then take a look at
[Issue #264](../../../issues/264)("Workflow when updating CEF version").
