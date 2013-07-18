# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef list CefListValueToPyList(
        CefRefPtr[CefListValue] cefListValue,
        int nestingLevel=0):
    assert cefListValue.IsValid(), "cefListValue is invalid"
    if nestingLevel > 8:
        raise Exception("CefListValueToPyList(): max nesting level (8)"
                " exceeded")
    cdef int index
    cdef int size = cefListValue.GetSize()
    cdef cef_types.cef_value_type_t valueType
    cdef list ret
    for index in range(0, size):
        valueType = cefListValue.GetType(index)
        if valueType == cef_types.VTYPE_NULL:
            ret.append(None)
        elif valueType == cef_types.VTYPE_BOOL:
            ret.append(bool(cefListValue.GetBool(index)))
        elif valueType == cef_types.VTYPE_INT:
            ret.append(cefListValue.GetInt(index))
        elif valueType == cef_types.VTYPE_DOUBLE:
            ret.append(cefListValue.GetDouble(index))
        elif valueType == cef_types.VTYPE_STRING:
            ret.append(CefToPyString(cefListValue.GetString(index)))
        elif valueType == cef_types.VTYPE_BINARY:
            raise Exception("VTYPE_BINARY not supported")
        elif valueType == cef_types.VTYPE_DICTIONARY:
            ret.append(CefDictionaryValueToPyDict(
                    cefListValue.GetDictionary(index),
                    nestingLevel + 1))
        elif valueType == cef_types.VTYPE_LIST:
            ret.append(CefListValueToPyList(
                    cefListValue.GetList(index), 
                    nestingLevel + 1))
        else:
            raise Exception("Unknown value type = %s" % valueType)
    return ret

cdef dict CefDictionaryValueToPyDict(
        CefRefPtr[CefDictionaryValue] cefDictionaryValue,
        int nestingLevel=0):
    assert cefDictionaryValue.IsValid(), "cefDictionaryValue is invalid"
    if nestingLevel > 8:
        raise Exception("CefDictionaryValueToPyDict(): max nesting level (8)"
                " exceeded")
    cdef cpp_vector[CefString] keyList
    cefDictionaryValue.GetKeys(keyList)
    cdef cef_types.cef_value_type_t valueType
    cdef dict ret
    cdef cpp_vector[CefString].iterator iterator = keyList.begin()
    cdef CefString cefKey
    cdef py_string pyKey
    while iterator != keyList.end():
        cefKey = deref(iterator)
        pyKey = CefToPyString(cefKey)
        preinc(iterator)
        valueType = cefDictionaryValue.GetType(cefKey)
        if valueType == cef_types.VTYPE_NULL:
            ret[pyKey] = None
        elif valueType == cef_types.VTYPE_BOOL:
            ret[pyKey] = bool(cefDictionaryValue.GetBool(cefKey))
        elif valueType == cef_types.VTYPE_INT:
            ret[pyKey] = cefDictionaryValue.GetInt(cefKey)
        elif valueType == cef_types.VTYPE_DOUBLE:
            ret[pyKey] = cefDictionaryValue.GetDouble(cefKey)
        elif valueType == cef_types.VTYPE_STRING:
            ret[pyKey] = CefToPyString(cefDictionaryValue.GetString(cefKey))
        elif valueType == cef_types.VTYPE_BINARY:
            raise Exception("VTYPE_BINARY not supported")
        elif valueType == cef_types.VTYPE_DICTIONARY:
            ret[pyKey] = CefDictionaryValueToPyDict(
                    cefDictionaryValue.GetDictionary(cefKey),
                    nestingLevel + 1)
        elif valueType == cef_types.VTYPE_LIST:
            ret[pyKey] = CefListValueToPyList(
                    cefDictionaryValue.GetList(cefKey), 
                    nestingLevel + 1)
        else:
            raise Exception("Unknown value type = %s" % valueType)
    return ret

cdef py_void PyListToCefListValue(
        list pyList,
        CefRefPtr[CefListValue] cefListValue,
        int nestingLevel=0):
    if nestingLevel > 8:
        raise Exception("PyListToCefListValue(): max nesting level (8)"
                " exceeded")
    cdef type valueType
    cdef CefRefPtr[CefListValue] newCefListValue
    for index, value in enumerate(pyList):
        valueType = type(value)
        if valueType == type(None):
            cefListValue.SetNull(index)
        elif valueType == bool:
            cefListValue.SetBool(index, bool(value))
        elif valueType == int:
            cefListValue.SetInt(index, int(value))
        elif valueType == long:
            # Int32 range is -2147483648..2147483647, we've increased the
            # minimum size by one as Cython was throwing a warning:
            # "unary minus operator applied to unsigned type, result still 
            # unsigned".
            if value <= 2147483647 and value >= -2147483647:
                cefListValue.SetInt(index, int(value))
            else:
                # Long values become strings.
                cefListValue.SetString(index, PyToCefStringValue(str(value)))
        elif valueType == float:
            cefListValue.SetDouble(index, float(value))
        elif valueType == bytes or valueType == unicode:
            cefListValue.SetString(index, PyToCefStringValue(str(value)))
        elif valueType == dict:
            cefListValue.SetDictionary(index, PyDictToCefDictionaryValue(
                    value, nestingLevel + 1))
        elif valueType == list:
            newCefListValue = CefListValue_Create()
            PyListToCefListValue(value, newCefListValue, nestingLevel + 1)
            cefListValue.SetList(index, newCefListValue)
        elif valueType == type:
            cefListValue.SetString(index, PyToCefStringValue(str(value)))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is 
            # probably redundant, but casting to string will do no harm.
            cefListValue.SetString(index, PyToCefStringValue(str(value)))
    return None

cdef CefRefPtr[CefDictionaryValue] PyDictToCefDictionaryValue(
        dict pyDict,
        int nestingLevel=0):
    if nestingLevel > 8:
        raise Exception("PyDictToCefDictionaryValue(): max nesting level (8)"
                " exceeded")
    cdef type valueType
    cdef CefRefPtr[CefListValue] newCefListValue
    cdef CefRefPtr[CefDictionaryValue] ret = CefDictionaryValue_Create()
    cdef CefString cefKey
    for pyKey in pyDict:
        valueType = type(value)
        value = pyDict[pyKey]
        PyToCefString(pyKey, cefKey)
        if valueType == type(None):
            ret.SetNull(cefKey)
        elif valueType == bool:
            ret.SetBool(cefKey, bool(value))
        elif valueType == int:
            ret.SetInt(cefKey, int(value))
        elif valueType == long:
            # Int32 range is -2147483648..2147483647, we've increased the
            # minimum size by one as Cython was throwing a warning:
            # "unary minus operator applied to unsigned type, result still 
            # unsigned".
            if value <= 2147483647 and value >= -2147483647:
                ret.SetInt(cefKey, int(value))
            else:
                # Long values become strings.
                ret.SetString(cefKey, PyToCefStringValue(str(value)))
        elif valueType == float:
            ret.SetDouble(cefKey, float(value))
        elif valueType == bytes or valueType == unicode:
            ret.SetString(cefKey, PyToCefStringValue(str(value)))
        elif valueType == dict:
            ret.SetDictionary(cefKey, PyDictToCefDictionaryValue(
                    value, nestingLevel + 1))
        elif valueType == list:
            newCefListValue = CefListValue_Create()
            PyListToCefListValue(value, newCefListValue, nestingLevel + 1)
            ret.SetList(cefKey, newCefListValue)
        elif valueType == type:
            ret.SetString(cefKey, PyToCefStringValue(str(value)))
        else:
            # Raising an exception probably not a good idea, why
            # terminate application when we can cast it to string,
            # the data may contain some non-standard object that is 
            # probably redundant, but casting to string will do no harm.
            ret.SetString(cefKey, PyToCefStringValue(str(value)))
    return ret
