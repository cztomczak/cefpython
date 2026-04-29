# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"

cimport cef_types
from cef_types cimport TID_UI, cef_event_flags_t

# ---------------------------------------------------------------------------
# Minimal CefMenuModel and CefRunContextMenuCallback declarations.
# cef_context_menu_handler.h includes cef_menu_model.h so one block suffices.
# ---------------------------------------------------------------------------

cdef extern from "include/cef_context_menu_handler.h":
    # CefMenuModel methods (subset used by RunContextMenu)
    cdef cppclass CefMenuModel:
        size_t GetCount() noexcept
        int GetCommandIdAt(size_t index) noexcept
        CefString GetLabelAt(size_t index) noexcept
        int GetTypeAt(size_t index) noexcept  # returns cef_menu_item_type_t as int
        cpp_bool IsEnabledAt(size_t index) noexcept

    cdef cppclass CefRunContextMenuCallback:
        void Continue(int command_id, cef_event_flags_t event_flags) noexcept
        void Cancel() noexcept

# ---------------------------------------------------------------------------
# Python wrapper: RunContextMenuCallback
# ---------------------------------------------------------------------------

cdef class RunContextMenuCallback:
    cdef CefRefPtr[CefRunContextMenuCallback] _cb
    cdef bint _done

    def __init__(self):
        self._done = False

    def Continue(self, int command_id, int event_flags=0):
        if not self._done:
            self._done = True
            self._cb.get().Continue(command_id,
                                    <cef_event_flags_t>event_flags)

    def Cancel(self):
        if not self._done:
            self._done = True
            self._cb.get().Cancel()

cdef RunContextMenuCallback _MakeRunContextMenuCallback(
        CefRefPtr[CefRunContextMenuCallback] cb):
    cdef RunContextMenuCallback obj = RunContextMenuCallback.__new__(
            RunContextMenuCallback)
    obj._cb = cb
    obj._done = False
    return obj

# ---------------------------------------------------------------------------
# Python wrapper: MenuModel (read-only snapshot for RunContextMenu).
# ---------------------------------------------------------------------------

cdef class MenuModel:
    # Snapshot taken at callback time so Python code can iterate freely
    # without worrying about CEF model lifetime.
    cdef list _items  # list of dicts

    def __init__(self):
        self._items = []

    def GetCount(self):
        return len(self._items)

    def GetTypeAt(self, int index):
        return self._items[index]['type']

    def GetLabelAt(self, int index):
        return self._items[index]['label']

    def GetCommandIdAt(self, int index):
        return self._items[index]['command_id']

    def IsEnabledAt(self, int index):
        return self._items[index]['enabled']

cdef MenuModel _SnapshotMenuModel(CefRefPtr[CefMenuModel] cef_model):
    cdef MenuModel obj = MenuModel.__new__(MenuModel)
    cdef size_t count = cef_model.get().GetCount()
    cdef size_t i
    obj._items = []
    for i in range(count):
        item_type = int(cef_model.get().GetTypeAt(i))
        label = CefToPyString(cef_model.get().GetLabelAt(i))
        command_id = cef_model.get().GetCommandIdAt(i)
        enabled = bool(cef_model.get().IsEnabledAt(i))
        obj._items.append({
            'type': item_type,
            'label': label,
            'command_id': command_id,
            'enabled': enabled,
        })
    return obj

# ---------------------------------------------------------------------------
# CEF menu item type constants exposed to Python (from cef_types.h).
# ---------------------------------------------------------------------------

MENUITEMTYPE_NONE      = 0
MENUITEMTYPE_COMMAND   = 1
MENUITEMTYPE_CHECK     = 2
MENUITEMTYPE_RADIO     = 3
MENUITEMTYPE_SEPARATOR = 4
MENUITEMTYPE_SUBMENU   = 5

# ---------------------------------------------------------------------------
# C-level dispatch called from context_menu_handler.cpp
# ---------------------------------------------------------------------------

cdef public int ContextMenuHandler_RunContextMenu(
        CefRefPtr[CefBrowser] cef_browser,
        CefRefPtr[CefMenuModel] cef_model,
        CefRefPtr[CefRunContextMenuCallback] cef_callback
        ) noexcept with gil:
    cdef PyBrowser browser
    cdef py_bool ret
    try:
        assert IsThread(TID_UI), "Must be called on the UI thread"
        browser = GetPyBrowser(cef_browser, "RunContextMenu")
        callback_py = browser.GetClientCallback("RunContextMenu")
        if not callback_py:
            return 0  # no Python handler — fall back to CEF default
        model_py = _SnapshotMenuModel(cef_model)
        cb_py = _MakeRunContextMenuCallback(cef_callback)
        ret = callback_py(browser=browser,
                          model=model_py,
                          callback=cb_py)
        return 1 if ret else 0
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
        return 0
