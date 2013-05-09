# Additional and wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#-------------------------------------------------------------------------------

def ExceptHook(type, value, traceObject):
    import traceback, os
    # This hook does the following: in case of exception display it,
    # write to error.log, shutdown CEF and exit application.
    error = "\n".join(traceback.format_exception(type, value, traceObject))
    print("\n"+error+"\n")
    #cefpython.QuitMessageLoop()
    #cefpython.Shutdown()
    # So that "finally" does not execute.
    #os._exit(1)
