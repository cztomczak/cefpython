# Additional and wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#-------------------------------------------------------------------------------

def ExceptHook(excType, excValue, traceObject):
    import traceback, os
    errorMsg = "\n".join(traceback.format_exception(
            excType, excValue, traceObject))
    if type(errorMsg) == bytes:
        errorMsg = errorMsg.decode(encoding="ascii", errors="replace")
    else:
        errorMsg = errorMsg.encode("ascii", errors="replace")
        errorMsg = errorMsg.decode("ascii", errors="replace")
    print("\n"+errorMsg+"\n")
    #cefpython.QuitMessageLoop()
    #cefpython.Shutdown()
    # So that "finally" does not execute.
    #os._exit(1)
