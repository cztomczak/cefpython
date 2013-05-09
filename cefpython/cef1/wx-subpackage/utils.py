# Additional and wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#-------------------------------------------------------------------------------

import sys
import os

def GetApplicationPath(myFile=None):
    import re, os
    # If myFile is None return current directory without trailing slash.
    if myFile is None:
        myFile = ""
    # Only when relative path.
    if not myFile.startswith("/") and not myFile.startswith("\\") and not re.search(r"^[\w-]+:", myFile):
        if hasattr(sys, "frozen"):
            path = os.path.dirname(sys.executable)
        elif "__file__" in globals():
            path = os.path.dirname(os.path.realpath(__file__))
        else:
            path = os.getcwd()
        path = path + os.sep + myFile
        path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        path = re.sub(r"[/\\]+$", "", path)
        return path
    return str(myFile)


