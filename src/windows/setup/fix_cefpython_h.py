"""
Get rid of warnings like this:

    cefpython.h(36) : warning C4190: 'RequestHandler_GetResourceHandler'
    has C-linkage specified, but returns UDT 'CefRefPtr<T>' which is
    incompatible with C
"""

import os


def main():
    if not os.path.exists("cefpython.h"):
        print("[fix_cefpython_h.py] cefpython.h was not yet generated")
        return
    with open("cefpython.h", "r") as fo:
        content = fo.read()
    pragma = "#pragma warning(disable:4190)"
    if pragma in content:
        print("[fix_cefpython_h.py] cefpython.h is already fixed")
        return
    content = ("%s\n\n" % (pragma)) + content
    with open("cefpython.h", "w") as fo:
        fo.write(content)
    print("[fix_cefpython_h.py] Saved cefpthon.h")


if __name__ == '__main__':
    main()
