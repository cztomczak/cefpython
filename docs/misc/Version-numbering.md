# Version numbering #

The naming convention for CEF Python versions is XX.YY (for example 29.4), where XX is the Chromium major version, and YY is the cefpython internal version.

#### Chromium version ####
An example Chromium version is 29.0.1547.80, where 29 is the major version, 0 is the minor version (this one never changes), 1547 is the build version (otherwise known as branch), and 80 is the patch version.

#### Current CEF version (Bitbucket) ####
Newer CEF versions consists of: CEF3+[branch](https://bitbucket.org/chromiumembedded/cef/branches/)+git-commit-count+git-revision/short-hash. An example would be: `3.2526.1366.g8617e7c`

#### Old CEF version (GoogleCode) ####
Old CEF versions consist of [CEF branch](https://code.google.com/p/chromiumembedded/source/browse/branches/) and [CEF SVN revision](https://code.google.com/p/chromiumembedded/source/list). The branch is the one from the Chromium version.

### Building from source ###
When building CEF and CEF Python from sources, you should use the CEF and Chromium versions listed in the [BUILD\_COMPATIBILITY.txt](../blob/master/cefpython/cef3/BUILD_COMPATIBILITY.txt) file.