// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "javascript_callback.h"
#include <map>
#include <sstream>
#include "DebugLog.h"
#include "v8utils.h"

template<typename T>
std::string AnyToString(const T& value)
{
    std::ostringstream oss;
    oss << value;
    return oss.str();
}

typedef std::map<int,
                 std::pair<CefRefPtr<CefFrame>, CefRefPtr<CefV8Value> > >
                 JavascriptCallbackMap;

JavascriptCallbackMap g_jsCallbackMap;
int g_jsCallbackMaxId = 0;

CefString PutJavascriptCallback(
        CefRefPtr<CefFrame> frame, CefRefPtr<CefV8Value> jsCallback) {
    // Returns a "####cefpython####" string followed by json encoded data.
    // {"what":"javascript-callback","callbackId":123,
    //  "frameId":123,"functionName":"xx"}
    int callbackId = ++g_jsCallbackMaxId;
    int64 frameId = frame->GetIdentifier();
    CefString functionName = jsCallback->GetFunctionName();
    std::string strCallbackId = "####cefpython####";
    strCallbackId.append("{");
    // JSON format allows only for double quotes.
    strCallbackId.append("\"what\":\"javascript-callback\"");
    strCallbackId.append(",\"callbackId\":").append(AnyToString(callbackId));
    strCallbackId.append(",\"frameId\":").append(AnyToString(frameId));
    strCallbackId.append(",\"functionName\":\"").append(functionName) \
            .append("\"");
    strCallbackId.append("}");
    g_jsCallbackMap.insert(std::make_pair(
            callbackId,
            std::make_pair(frame, jsCallback)));
    return strCallbackId;
}

bool ExecuteJavascriptCallback(int callbackId, CefRefPtr<CefListValue> args) {
    if (g_jsCallbackMap.empty()) {
        DebugLog("Renderer: ExecuteJavascriptCallback() FAILED: " \
                 "callback map is empty");
        return false;
    }
    JavascriptCallbackMap::const_iterator it = g_jsCallbackMap.find(
            callbackId);
    if (it == g_jsCallbackMap.end()) {
        std::string logMessage = "Renderer: ExecuteJavascriptCallback() "
                "FAILED: callback not found, id=";
        logMessage.append(AnyToString(callbackId));
        DebugLog(logMessage.c_str());
        return false;
    }
    CefRefPtr<CefFrame> frame = it->second.first;
    CefRefPtr<CefV8Value> callback = it->second.second;
    CefRefPtr<CefV8Context> context = frame->GetV8Context();
    context->Enter();
    CefV8ValueList v8Arguments = CefListValueToCefV8ValueList(args);
    CefRefPtr<CefV8Value> v8ReturnValue = callback->ExecuteFunction(
            NULL, v8Arguments);
    if (v8ReturnValue.get()) {
        return true;
    } else {
        DebugLog("Renderer: ExecuteJavascriptCallback() FAILED: " \
                "callback->ExecuteFunction() FAILED");
        return false;
    }
}

void RemoveJavascriptCallbacksForFrame(CefRefPtr<CefFrame> frame) {
    if (g_jsCallbackMap.empty()) {
        return;
    }
    JavascriptCallbackMap::iterator it = g_jsCallbackMap.begin();
    int64 frameId = frame->GetIdentifier();
    while (it != g_jsCallbackMap.end()) {
        if (it->second.first->GetIdentifier() == frameId) {
            g_jsCallbackMap.erase(it);
            DebugLog("Renderer: RemoveJavascriptCallbacksForFrame(): " \
                    "removed js callback from the map");
        }
        ++it;
    }
}
