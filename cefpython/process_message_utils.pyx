# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef list CefListValueToPyList(
        CefRefPtr[CefListValue] cefListValue,
        int nestingLevel=0):
    assert cefListValue.get().IsValid(), "cefListValue is invalid"
    if nestingLevel > 8:
        raise Exception("CefListValueToPyList(): max nesting level (8)"
                " exceeded")
    cdef int index
    cdef int size = cefListValue.get().GetSize()
    cdef cef_types.cef_value_type_t valueType
    cdef list ret = []
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
            ret.append(CefToPyString(cefListValue.get().GetString(index)))
        elif valueType == cef_types.VTYPE_BINARY:
            raise Exception("VTYPE_BINARY not supported")
        elif valueType == cef_types.VTYPE_DICTIONARY:
            ret.append(CefDictionaryValueToPyDict(
                    cefListValue.get().GetDictionary(index),
                    nestingLevel + 1))
        elif valueType == cef_types.VTYPE_LIST:
            ret.append(CefListValueToPyList(
                    cefListValue.get().GetList(index), 
                    nestingLevel + 1))
        else:
            raise Exception("Unknown value type = %s" % valueType)
    return ret

cdef dict CefDictionaryValueToPyDict(
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
    cdef cpp_vector[CefString].iterator iterator = keyList.begin()
    cdef CefString cefKey
    cdef py_string pyKey
    while iterator != keyList.end():
        cefKey = deref(iterator)
        pyKey = CefToPyString(cefKey)
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
            ret[pyKey] = CefToPyString(cefDictionaryValue.get().GetString(cefKey))
        elif valueType == cef_types.VTYPE_BINARY:
            raise Exception("VTYPE_BINARY not supported")
        elif valueType == cef_types.VTYPE_DICTIONARY:
            ret[pyKey] = CefDictionaryValueToPyDict(
                    cefDictionaryValue.get().GetDictionary(cefKey),
                    nestingLevel + 1)
        elif valueType == cef_types.VTYPE_LIST:
            ret[pyKey] = CefListValueToPyList(
                    cefDictionaryValue.get().GetList(cefKey), 
                    nestingLevel + 1)
        else:
            raise Exception("Unknown value type = %s" % valueType)
    return ret

cdef CefRefPtr[CefListValue] PyListToCefListValue(
        list pyList,
        int nestingLevel=0) except *:
    if nestingLevel > 8:
        raise Exception("PyListToCefListValue(): max nesting level (8)"
                " exceeded")
    cdef type valueType
    cdef CefRefPtr[CefListValue] ret = CefListValue_Create()
    for index, value in enumerate(pyList):
        valueType = type(value)
        if valueType == type(None):
            ret.get().SetNull(index)
        elif valueType == bool:
            ret.get().SetBool(index, bool(value))
        elif valueType == int:
            ret.get().SetInt(index, int(value))
        elif valueType == long:
            # Int32 range is -2147483648..2147483647, we've increased the
            # minimum size by one as Cython was throwing a warning:
            # "unary minus operator applied to unsigned type, result still 
            # unsigned".
            if value <= 2147483647 and value >= -2147483647:
                ret.get().SetInt(index, int(value))
            else:
                # Long values become strings.
                ret.get().SetString(index, PyToCefStringValue(str(value)))
        elif valueType == float:
            ret.get().SetDouble(index, float(value))
        elif valueType == bytes or valueType == unicode:
            ret.get().SetString(index, PyToCefStringValue(str(value)))
        elif valueType == dict:
            ret.get().SetDictionary(index, PyDictToCefDictionaryValue(value,
                    nestingLevel + 1))
        elif valueType == list:
            ret.get().SetList(index, PyListToCefListValue(value, 
                    nestingLevel + 1))
        elif valueType == type:
            ret.get().SetString(index, PyToCefStringValue(str(value)))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is 
            # probably redundant, but casting to string will do no harm.
            ret.get().SetString(index, PyToCefStringValue(str(value)))
    return ret

cdef void PyListToExistingCefListValue(
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
    for index, value in enumerate(pyList):
        valueType = type(value)
        if valueType == type(None):
            cefListValue.get().SetNull(index)
        elif valueType == bool:
            cefListValue.get().SetBool(index, bool(value))
        elif valueType == int:
            cefListValue.get().SetInt(index, int(value))
        elif valueType == long:
            # Int32 range is -2147483648..2147483647, we've increased the
            # minimum size by one as Cython was throwing a warning:
            # "unary minus operator applied to unsigned type, result still 
            # unsigned".
            if value <= 2147483647 and value >= -2147483647:
                cefListValue.get().SetInt(index, int(value))
            else:
                # Long values become strings.
                cefListValue.get().SetString(index, PyToCefStringValue(str(value)))
        elif valueType == float:
            cefListValue.get().SetDouble(index, float(value))
        elif valueType == bytes or valueType == unicode:
            cefListValue.get().SetString(index, PyToCefStringValue(str(value)))
        elif valueType == dict:
            cefListValue.get().SetDictionary(index, PyDictToCefDictionaryValue(value,
                    nestingLevel + 1))
        elif valueType == list:
            newCefListValue = CefListValue_Create()
            PyListToExistingCefListValue(value, newCefListValue, 
                    nestingLevel + 1)
            cefListValue.get().SetList(index, newCefListValue)
        elif valueType == type:
            cefListValue.get().SetString(index, PyToCefStringValue(str(value)))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is 
            # probably redundant, but casting to string will do no harm.
            cefListValue.get().SetString(index, PyToCefStringValue(str(value)))

cdef CefRefPtr[CefDictionaryValue] PyDictToCefDictionaryValue(
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
        elif valueType == int:
            ret.get().SetInt(cefKey, int(value))
        elif valueType == long:
            # Int32 range is -2147483648..2147483647, we've increased the
            # minimum size by one as Cython was throwing a warning:
            # "unary minus operator applied to unsigned type, result still 
            # unsigned".
            if value <= 2147483647 and value >= -2147483647:
                ret.get().SetInt(cefKey, int(value))
            else:
                # Long values become strings.
                ret.get().SetString(cefKey, PyToCefStringValue(str(value)))
        elif valueType == float:
            ret.get().SetDouble(cefKey, float(value))
        elif valueType == bytes or valueType == unicode:
            ret.get().SetString(cefKey, PyToCefStringValue(str(value)))
        elif valueType == dict:
            ret.get().SetDictionary(cefKey, PyDictToCefDictionaryValue(
                    value, nestingLevel + 1))
        elif valueType == list:
            ret.get().SetList(cefKey, PyListToCefListValue(value, 
                    nestingLevel + 1))
        elif valueType == type:
            ret.get().SetString(cefKey, PyToCefStringValue(str(value)))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is 
            # probably redundant, but casting to string will do no harm.
            ret.get().SetString(cefKey, PyToCefStringValue(str(value)))
    return ret
