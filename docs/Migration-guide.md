# Migration guide from v31 to latest v55+ (STILL UNDER WORKS.. #293)


Table of contents:
* [Distribution packages](#distribution-packages)
* [Handlers' callbacks and other interfaces](#handlers-callbacks-and-other-interfaces)


## Distribution packages

In latest CEF Python there are only two distribution packages
available. The first one is a wheel package distributed through
PyPI, which you can install using the pip tool (8.1+ required
on Linux). The second one is a setup package available for
download on the GitHub Releases pages, instructions on how to
install it are provided in README.txt.

On Windows many of the distribution packages such as MSI, EXE,
ZIP and InnoSetup files, are no more available. It is too much
hassle to support these.

On Linux the debian package is not supported anymore. Since
pip 8.1+ added support for manylinux1 wheel packages, you can
now easily install cefpython on Linux using the pip tool.
Installing cefpython on Ubuntu using pip should work out of
the box, all OS dependencies on Ubuntu should be satisfied
by default. However since upstream CEF has OS dependencies
that might not be installed by default on other OSes like e.g.
Fedora, and since debian packages allow to list these and install
in an automated manner, it might be reconsidered in the future
to provide debian packages again.


## Handlers' callbacks and other interfaces

Since v55.3 all handlers' callbacks and other interfaces such as
CookieVisitor, StringVisitor and WebRequestClient, are now called
using keyword arguments (Issue [#291](../../../issues/291)).
This will cause many of existing code to break. This is how you
should declare callbacks using the new style:

```
def OnLoadStart(self, browser, **_):
	pass

def OnLoadStart(self, **kwargs):
	browser = kwargs["browser"]
```

In the first declaration you see that only one argument is
declared, the browser, the others unused will be in the "_"
variable (the name of the variable is so that PyCharm doesn't
warn about unused variable).

Even if you specify and use all arguments, always add the
unused kwargs (`**_`) at the end:

```
def OnLoadStart(self, browser, frame, **_):
	pass
```

This will be handy in the future, in a case when upstream CEF
adds a new argument to the API, your code won't break. When
an argument is removed in upstream CEF API, if it's possible
CEF Python will try to keep backward compatibility by
emulating behavior of the old argument.

In case of OnLoadStart, when you've used "browser" and "frame"
names for the arguments, your code won't break. However in
many other callbacks, where you've used argument names that
differed from how they were named in API docs, your code will
break. Also argument names were changed from camelCase
to underscores. For example the OnLoadEnd callback has renamed
the `httpStatusCode` argument to `http_code`. So in this case
your code will definitely break, unless you've also used
"http_code" for argument name.




