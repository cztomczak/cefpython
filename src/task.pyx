# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

g_taskMaxId = 0
g_tasks = {}

def PostTask(int thread, object func, *args):
    global g_tasks, g_taskMaxId

    # Validate threadId.
    if thread not in g_browserProcessThreads:
        raise Exception("PostTask failed: requires a browser process thread")

    # Validate func.
    if not IsFunctionOrMethod(type(func)):
        raise Exception("PostTask failed: not a function nor method")

    # Params.
    cdef list params = list(args)

    # Keep func and params until PyTaskRunnable is called.
    g_taskMaxId += 1
    g_tasks[str(g_taskMaxId)] = {
        "func": func,
        "params": params
    }

    # Call C++ wrapper.
    cdef int cTaskId = int(g_taskMaxId)
    with nogil:
        PostTaskWrapper(thread, cTaskId)


def PostDelayedTask(int thread, int delay_ms, object func, *args):
    global g_tasks, g_taskMaxId

    # Validate threadId.
    if thread not in g_browserProcessThreads:
        raise Exception("PostTask failed: requires a browser process thread")

    # Validate func.
    if not IsFunctionOrMethod(type(func)):
        raise Exception("PostTask failed: not a function nor method")

    # Params.
    cdef list params = list(args)

    # Keep func and params until PyTaskRunnable is called.
    g_taskMaxId += 1
    g_tasks[str(g_taskMaxId)] = {
        "func": func,
        "params": params
    }

    # Call C++ wrapper.
    cdef int cTaskId = int(g_taskMaxId)
    with nogil:
        PostDelayedTaskWrapper(thread, delay_ms, cTaskId)


cdef public void PyTaskRunnable(int taskId) except * with gil:
    cdef object func
    cdef list params
    cdef object task

    try:
        global g_tasks

        # Validate if task exist.
        if str(taskId) not in g_tasks:
            raise Exception("PyTaskRunnable failed: invalid taskId=%s" \
                    % taskId)

        # Fetch task: func and params.
        task = g_tasks[str(taskId)]
        func = task["func"]
        params = task["params"]
        del g_tasks[str(taskId)]

        # Execute user func.
        Debug("PyTaskRunnable: taskId=%s, func=%s" % (taskId, func.__name__))
        func(*params)

    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

