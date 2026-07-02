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
* [GIL](#gil)
* [Authors](#authors)
* [Updating CEF version](#updating-cef-version)
  * [Re-importing the CEF headers](#re-importing-the-cef-headers)


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

## GIL

In the pxd file, functions should be defined as "nogil" to avoid
deadlocks when calling CEF functions. In the pyx file the call must
use the "with nogil" statement.

From [Cython's documentation](http://docs.cython.org/src/userguide/external_C_code.html#acquiring-and-releasing-the-gil):

> Note that acquiring the GIL is a blocking thread-synchronising operation,
> and therefore potentially costly. It might not be worth releasing the GIL
> for minor calculations. Usually, I/O operations and substantial computations
> in parallel code will benefit from it.

Revision [ec1ce78](https://github.com/cztomczak/cefpython/commit/ec1ce788373bb9e0fd2cedd71e900c3877e9185a) removes the GIL lock from the
following calls: Initialize(), Shutdown(), CreateBrowserSync(),
SetOsModalLoop(), QuitMessageLoop(), CefExecuteProcess(). There still
might be some more functions from which the GIL lock should be removed.

## Authors

In your pull request modify also the [Authors](../Authors) file
to add your name and encoded email.

## Updating CEF version

For the general workflow see
[Issue #264](../../../issues/264) ("Workflow when updating CEF version").

### Re-importing the CEF headers

cefpython compiles against the CEF headers vendored in `src/include/` (the
include path starts at `src/`, so `#include "include/cef_*.h"` resolves there).
On every CEF upgrade these headers must be re-imported cleanly from the upstream
**CEF source repository** — not copied from the binary distribution — so they
stay byte-identical to upstream and don't accumulate stale/edited content.

`src/include/` holds only the stable, hand-written public headers. The
following **generated** headers are intentionally *not* vendored; they are
produced during CEF release packaging (and differ per platform), and are
resolved at build time from `CEF_ROOT/include` instead:

- `cef_version.h`, `cef_config.h`, `cef_api_versions.h`
- `cef_color_ids.h`, `cef_command_ids.h`
- `cef_pack_resources.h`, `cef_pack_strings.h`
- `base/internal/cef_net_error_list.h`

`tools/automate.py --prebuilt-cef` copies the distribution's `include/` into the
prebuilt `CEF_ROOT` directory so those generated headers are available, and the
CMake include path lists `CEF_ROOT` *after* `src/` so the vendored source
headers always take precedence. The `capi/` C API headers are not used by
cefpython and are not vendored either.

Steps:

1. Bump the version fields in `src/version/cef_version_{win,linux,macarm64}.h`
   (`CEF_VERSION`, `CEF_COMMIT_*`, `CHROME_VERSION_*`, `CEF_SANDBOX_COMPAT_HASH`).
   The CEF **API hash** is not stored here — it is read from CEF's generated
   `cef_api_versions.h` (in `CEF_ROOT/include`) by `tools/cmake_prepare_pyx.py`,
   so there is nothing to hand-edit for it.

2. Find the CEF source commit — it is the `g<hash>` in the `CEF_VERSION`
   string. For `147.0.10+gd58e84d+chromium-147.0.7727.118` the commit is
   `d58e84d`.

3. Fetch that exact source tree and replace `src/include/`:

   ```bash
   commit=d58e84d   # from CEF_VERSION above
   curl -sL "https://codeload.github.com/chromiumembedded/cef/tar.gz/$commit" \
       | tar xz
   rm -rf src/include
   cp -r "cef-$commit/include" src/include
   # capi/ and base/internal/cef_net_error_list.h are placeholder stubs in the
   # source tree (the stub #includes a Chromium path and is replaced with the
   # real content during CEF packaging). Remove them so the build resolves the
   # real versions from CEF_ROOT/include.
   rm -rf src/include/capi
   rm -f  src/include/base/internal/cef_net_error_list.h
   # Drop any non-header docs the source tree ships under include/ (e.g. *.md):
   find src/include -type f ! -name '*.h' ! -name '*.inc' -delete
   ```

   The remaining generated headers (`cef_version.h`, `cef_config.h`,
   `cef_api_versions.h`, `cef_color_ids.h`, `cef_command_ids.h`,
   `cef_pack_resources.h`, `cef_pack_strings.h`) do **not** exist in the source
   tree at all — they are created during CEF packaging — so a clean source
   import already excludes them and there is nothing to delete. They are
   resolved from `CEF_ROOT/include` at build time.

4. Sanity check: the vendored headers should be byte-identical to the same
   files in the downloaded CEF binary distribution's `include/` (ignoring the
   Windows distribution's CRLF line endings). Then rebuild and run the unit
   tests (`unittests/_test_runner.py`).
