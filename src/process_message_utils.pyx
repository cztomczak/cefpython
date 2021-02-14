# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# CefListValue->SetXxxx() functions need first param to be be cast
# to (int) because GetSize() returns size_t and generates a warning
# when compiling on VS2008 for x64 platform. Issue reported here:
# https://github.com/cztomczak/cefpython/issues/165
# Here in pyx you also need to convert Py_ssize_t returned by
# enumerate(), to an int.

include "cefpython.pyx"
include "utils.pyx"

# -----------------------------------------------------------------------------
# CEF values to Python values
# -----------------------------------------------------------------------------

cdef object CheckForCefPythonMessageHash(CefRefPtr[CefBrowser] cefBrowser,
        py_string pyString):
    # A javascript callback from the Renderer process is sent as a string.
    # TODO: this could be sent using CefBinaryNamedString in the future,
    #       see this topic "Sending custom data types using process messaging":
    #       http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10881
    cdef py_string cefPythonMessageHash = "####cefpython####"
    cdef JavascriptCallback jsCallback
    cdef py_string jsonData
    cdef object message
    if pyString.startswith(cefPythonMessageHash):
        jsonData = pyString[len(cefPythonMessageHash):]
        message = json.loads(jsonData)
        if message and type(message) == dict and ("what" in message) \
                and message["what"] == "javascript-callback":
            jsCallback = CreateJavascriptCallback(
                    message["callbackId"], cefBrowser,
                    message["frameId"], message["functionName"])
            return jsCallback
    return pyString

cdef object CefValueToPyValue(CefRefPtr[CefValue] cefValue):
    assert cefValue.get().IsValid(), "cefValue is invalid"
    cdef cef_types.cef_value_type_t valueType = cefValue.get().GetType()
    cdef CefRefPtr[CefBinaryValue] binaryValue
    cdef uint32 uint32_value = 0
    cdef int64 int64_value = 0

    if valueType == cef_types.VTYPE_NULL:
        return None
    elif valueType == cef_types.VTYPE_BOOL:
        return bool(cefValue.get().GetBool())
    elif valueType == cef_types.VTYPE_INT:
        return cefValue.get().GetInt()
    elif valueType == cef_types.VTYPE_DOUBLE:
        return cefValue.get().GetDouble()
    elif valueType == cef_types.VTYPE_STRING:
        return CefToPyString(cefValue.get().GetString())
    elif valueType == cef_types.VTYPE_DICTIONARY:
        return CefDictionaryValueToPyDict(
                <CefRefPtr[CefBrowser]>NULL,
                cefValue.get().GetDictionary(),
                1)
    elif valueType == cef_types.VTYPE_LIST:
        return CefListValueToPyList(
                <CefRefPtr[CefBrowser]>NULL,
                cefValue.get().GetList(),
                1)
    elif valueType == cef_types.VTYPE_BINARY:
        binaryValue = cefValue.get().GetBinary()
        if binaryValue.get().GetSize() == sizeof(uint32_value):
            binaryValue.get().GetData(
                    &uint32_value, sizeof(uint32_value), 0)
            return uint32_value
        elif binaryValue.get().GetSize() == sizeof(int64_value):
            binaryValue.get().GetData(
                    &int64_value, sizeof(int64_value), 0)
            return int64_value
        else:
            NonCriticalError("Unknown binary value, size=%s" % \
                    binaryValue.get().GetSize())
            return None
    else:
        raise Exception("Unknown CefValue type=%s" % valueType)

# TODO: Use CefListValue.GetValue to get CefValue and use CefValueToPyValue
#       for dictionary and lists?

cdef list CefListValueToPyList(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefListValue] cefListValue,
        int nestingLevel=0):
    assert cefListValue.get().IsValid(), "cefListValue is invalid"
    if nestingLevel > 8:
        raise Exception("CefListValueToPyList(): max nesting level (8)"
                " exceeded")
    cdef size_t index
    cdef size_t size = cefListValue.get().GetSize()
    cdef cef_types.cef_value_type_t valueType
    cdef list ret = []
    cdef CefRefPtr[CefBinaryValue] binaryValue
    cdef uint32 uint32_value = 0
    cdef int64 int64_value = 0
    cdef object originallyString
    for index in range(0, size):
        valueType = cefListValue.get().GetType(index)
        if valueType == cef_types.VTYPE_NULL:
            ret.append(None)
        elif valueType == cef_types.VTYPE_BOOL:
            ret.append(bool(cefListValue.get().GetBool(index)))
        elif valueType == cef_types.VTYPE_INT:
            ret.append(cefListValue.get().GetInt(index))
        elif valueType == cef_types.VTYPE_DOUBLE:
            ret.append(cefListValue.get().GetDouble(index))
        elif valueType == cef_types.VTYPE_STRING:
            originallyString = CefToPyString(
                    cefListValue.get().GetString(index))
            if cefBrowser.get():
                originallyString = CheckForCefPythonMessageHash(cefBrowser,
                        originallyString)
            ret.append(originallyString)
        elif valueType == cef_types.VTYPE_DICTIONARY:
            ret.append(CefDictionaryValueToPyDict(
                    cefBrowser,
                    cefListValue.get().GetDictionary(index),
                    nestingLevel + 1))
        elif valueType == cef_types.VTYPE_LIST:
            ret.append(CefListValueToPyList(
                    cefBrowser,
                    cefListValue.get().GetList(index),
                    nestingLevel + 1))
        elif valueType == cef_types.VTYPE_BINARY:
            binaryValue = cefListValue.get().GetBinary(index)
            if binaryValue.get().GetSize() == sizeof(uint32_value):
                binaryValue.get().GetData(
                        &uint32_value, sizeof(uint32_value), 0)
                ret.append(uint32_value)
            elif binaryValue.get().GetSize() == sizeof(int64_value):
                binaryValue.get().GetData(
                        &int64_value, sizeof(int64_value), 0)
                ret.append(int64_value)
            else:
                NonCriticalError("Unknown binary value, size=%s" % \
                    binaryValue.get().GetSize())
                ret.append(None)
        else:
            raise Exception("Unknown CefValue type=%s" % valueType)
    return ret

cdef dict CefDictionaryValueToPyDict(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefDictionaryValue] cefDictionaryValue,
        int nestingLevel=0):
    assert cefDictionaryValue.get().IsValid(), "cefDictionaryValue is invalid"
    if nestingLevel > 8:
        raise Exception("CefDictionaryValueToPyDict(): max nesting level (8)"
                " exceeded")
    cdef cpp_vector[CefString] keyList
    cefDictionaryValue.get().GetKeys(keyList)
    cdef cef_types.cef_value_type_t valueType
    cdef dict ret = {}
    # noinspection PyUnresolvedReferences
    cdef cpp_vector[CefString].iterator iterator = keyList.begin()
    cdef CefString cefKey
    cdef py_string pyKey
    cdef CefRefPtr[CefBinaryValue] binaryValue
    cdef uint32 uint32_value = 0
    cdef int64 int64_value = 0
    cdef object originallyString
    while iterator != keyList.end():
        # noinspection PyUnresolvedReferences
        cefKey = deref(iterator)
        pyKey = CefToPyString(cefKey)
        # noinspection PyUnresolvedReferences
        preinc(iterator)
        valueType = cefDictionaryValue.get().GetType(cefKey)
        if valueType == cef_types.VTYPE_NULL:
            ret[pyKey] = None
        elif valueType == cef_types.VTYPE_BOOL:
            ret[pyKey] = bool(cefDictionaryValue.get().GetBool(cefKey))
        elif valueType == cef_types.VTYPE_INT:
            ret[pyKey] = cefDictionaryValue.get().GetInt(cefKey)
        elif valueType == cef_types.VTYPE_DOUBLE:
            ret[pyKey] = cefDictionaryValue.get().GetDouble(cefKey)
        elif valueType == cef_types.VTYPE_STRING:
            originallyString = CefToPyString(
                    cefDictionaryValue.get().GetString(cefKey))
            if cefBrowser.get():
                originallyString = CheckForCefPythonMessageHash(cefBrowser,
                        originallyString)
            ret[pyKey] = originallyString
        elif valueType == cef_types.VTYPE_DICTIONARY:
            ret[pyKey] = CefDictionaryValueToPyDict(
                    cefBrowser,
                    cefDictionaryValue.get().GetDictionary(cefKey),
                    nestingLevel + 1)
        elif valueType == cef_types.VTYPE_LIST:
            ret[pyKey] = CefListValueToPyList(
                    cefBrowser,
                    cefDictionaryValue.get().GetList(cefKey),
                    nestingLevel + 1)
        elif valueType == cef_types.VTYPE_BINARY:
            binaryValue = cefDictionaryValue.get().GetBinary(cefKey)
            if binaryValue.get().GetSize() == sizeof(uint32_value):
                binaryValue.get().GetData(
                        &uint32_value, sizeof(uint32_value), 0)
                ret[pyKey] = uint32_value
            elif binaryValue.get().GetSize() == sizeof(int64_value):
                binaryValue.get().GetData(
                        &int64_value, sizeof(int64_value), 0)
                ret[pyKey] = int64_value
            else:
                NonCriticalError("Unknown binary value, size=%s" % \
                    binaryValue.get().GetSize())
                ret[pyKey] = None
        else:
            raise Exception("Unknown CefValue type = %s" % valueType)
    return ret

# -----------------------------------------------------------------------------
# Python values to CEF values
# -----------------------------------------------------------------------------

cdef CefRefPtr[CefListValue] PyListToCefListValue(
        int browserId,
        object frameId,
        list pyList,
        int nestingLevel=0) except *:
    if nestingLevel > 8:
        raise Exception("PyListToCefListValue(): max nesting level (8)"
                " exceeded")
    cdef type valueType
    cdef CefRefPtr[CefListValue] ret = CefListValue_Create()
    cdef CefRefPtr[CefBinaryValue] binaryValue
    cdef size_t index
    for index_size_t, value in enumerate(pyList):
        index = int(index_size_t)
        valueType = type(value)
        if valueType == type(None):
            ret.get().SetNull(index)
        elif valueType == bool:
            ret.get().SetBool(index, bool(value))
        elif valueType == int or valueType == long:  # In Py3 int and long types are the same type.
            # Int32 range is -2147483648..2147483647
            if INT_MIN <= value <= INT_MAX:
                ret.get().SetInt(index, int(value))
            else:
                # Long values become strings.
                ret.get().SetString(index, PyToCefStringValue(str(value)))
        elif valueType == float:
            ret.get().SetDouble(index, float(value))
        elif valueType == bytes or valueType == str \
                or (PY_MAJOR_VERSION < 3 and valueType == unicode):
            # The unicode type is not defined in Python 3.
            ret.get().SetString(index, PyToCefStringValue(str(value)))
        elif valueType == dict:
            ret.get().SetDictionary(index, PyDictToCefDictionaryValue(
                    browserId, frameId, value, nestingLevel + 1))
        elif valueType == list or valueType == tuple:
            if valueType == tuple:
                value = list(value)
            ret.get().SetList(index, PyListToCefListValue(
                    browserId, frameId, value, nestingLevel + 1))
        elif IsFunctionOrMethod(valueType):
            ret.get().SetBinary(index, PutPythonCallback(
                    browserId, frameId, value))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is
            # probably redundant, but casting to string will do no harm.
            # This will handle the "type" type.
            ret.get().SetString(index, PyToCefStringValue(str(value)))
    return ret

cdef void PyListToExistingCefListValue(
        int browserId,
        object frameId,
        list pyList,
        CefRefPtr[CefListValue] cefListValue,
        int nestingLevel=0) except *:
    # When sending process messages you must use an existing
    # CefListValue, see browser.pyx > SendProcessMessage().
    if nestingLevel > 8:
        raise Exception("PyListToCefListValue(): max nesting level (8)"
                " exceeded")
    cdef type valueType
    cdef CefRefPtr[CefListValue] newCefListValue
    cdef size_t index
    for index_size_t, value in enumerate(pyList):
        index = int(index_size_t)
        valueType = type(value)
        if valueType == type(None):
            cefListValue.get().SetNull(index)
        elif valueType == bool:
            cefListValue.get().SetBool(index, bool(value))
        elif valueType == int or valueType == long:  # In Py3 int and long types are the same type.
            # Int32 range is -2147483648..2147483647
            if INT_MIN <= value <= INT_MAX:
                cefListValue.get().SetInt(index, int(value))
            else:
                # Long values become strings.
                cefListValue.get().SetString(index, PyToCefStringValue(str(
                        value)))
        elif valueType == float:
            cefListValue.get().SetDouble(index, float(value))
        elif valueType == bytes or valueType == str \
                or (PY_MAJOR_VERSION < 3 and valueType == unicode):
            # The unicode type is not defined in Python 3.
            cefListValue.get().SetString(index, PyToCefStringValue(str(value)))
        elif valueType == dict:
            cefListValue.get().SetDictionary(index, PyDictToCefDictionaryValue(
                    browserId, frameId, value, nestingLevel + 1))
        elif valueType == list or valueType == tuple:
            if valueType == tuple:
                value = list(value)
            newCefListValue = CefListValue_Create()
            PyListToExistingCefListValue(browserId, frameId, value,
                    newCefListValue, nestingLevel + 1)
            cefListValue.get().SetList(index, newCefListValue)
        elif IsFunctionOrMethod(valueType):
            cefListValue.get().SetBinary(index, PutPythonCallback(
                        browserId, frameId, value))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is
            # probably redundant, but casting to string will do no harm.
            # This will handle the "type" type.
            cefListValue.get().SetString(index, PyToCefStringValue(str(value)))

cdef CefRefPtr[CefDictionaryValue] PyDictToCefDictionaryValue(
        int browserId,
        object frameId,
        dict pyDict,
        int nestingLevel=0) except *:
    if nestingLevel > 8:
        raise Exception("PyDictToCefDictionaryValue(): max nesting level (8)"
                " exceeded")
    cdef type valueType
    cdef CefRefPtr[CefDictionaryValue] ret = CefDictionaryValue_Create()
    cdef CefString cefKey
    cdef object value
    for pyKey in pyDict:
        value = pyDict[pyKey]
        valueType = type(value)
        PyToCefString(pyKey, cefKey)
        if valueType == type(None):
            ret.get().SetNull(cefKey)
        elif valueType == bool:
            ret.get().SetBool(cefKey, bool(value))
        elif valueType == int or valueType == long:  # In Py3 int and long types are the same type.
            # Int32 range is -2147483648..2147483647
            if INT_MIN <= value <= INT_MAX:
                ret.get().SetInt(cefKey, int(value))
            else:
                # Long values become strings.
                ret.get().SetString(cefKey, PyToCefStringValue(str(value)))
        elif valueType == float:
            ret.get().SetDouble(cefKey, float(value))
        elif valueType == bytes or valueType == str \
                or (PY_MAJOR_VERSION < 3 and valueType == unicode):
            # The unicode type is not defined in Python 3.
            ret.get().SetString(cefKey, PyToCefStringValue(str(value)))
        elif valueType == dict:
            ret.get().SetDictionary(cefKey, PyDictToCefDictionaryValue(
                    browserId, frameId, value, nestingLevel + 1))
        elif valueType == list or valueType == tuple:
            if valueType == tuple:
                value = list(value)
            ret.get().SetList(cefKey, PyListToCefListValue(
                    browserId, frameId, value, nestingLevel + 1))
        elif IsFunctionOrMethod(valueType):
            ret.get().SetBinary(cefKey, PutPythonCallback(
                    browserId, frameId, value))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is
            # probably redundant, but casting to string will do no harm.
            # This will handle the "type" type.
            ret.get().SetString(cefKey, PyToCefStringValue(str(value)))
    return ret
