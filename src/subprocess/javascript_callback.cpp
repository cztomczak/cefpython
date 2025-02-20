// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "javascript_callback.h"
#include <map>
#include <sstream>
#include "v8utils.h"
#include "cefpython_app.h"
#include "include/base/cef_logging.h"

template<typename T>
inline std::string AnyToString(const T& value)
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
    //  "frameId":"123","functionName":"xx"}
    int callbackId = ++g_jsCallbackMaxId;
    CefString frameId = frame->GetIdentifier();
    CefString functionName = jsCallback->GetFunctionName();
    std::string strCallbackId = "####cefpython####";
    strCallbackId.append("{");
    // JSON format allows only for double quotes.
    strCallbackId.append("\"what\":\"javascript-callback\"");
    strCallbackId.append(",\"callbackId\":").append(AnyToString(callbackId));
    strCallbackId.append(",\"frameId\":\"").append(AnyToString(frameId));
    strCallbackId.append("\",\"functionName\":\"").append(functionName) \
            .append("\"");
    strCallbackId.append("}");
    g_jsCallbackMap.insert(std::make_pair(
            callbackId,
            std::make_pair(frame, jsCallback)));
    return strCallbackId;
}

bool ExecuteJavascriptCallback(int callbackId, CefRefPtr<CefListValue> args) {
    if (g_jsCallbackMap.empty()) {
        LOG(ERROR) << "[Renderer process] ExecuteJavascriptCallback():"
                      " callback map is empty";
        return false;
    }
    JavascriptCallbackMap::const_iterator it = g_jsCallbackMap.find(
            callbackId);
    if (it == g_jsCallbackMap.end()) {
        std::string logMessage = "[Renderer process]"
                                 " ExecuteJavascriptCallback():"
                                 " callback not found, id=";
        logMessage.append(AnyToString(callbackId));
        LOG(ERROR) << logMessage.c_str();
        return false;
    }
    CefRefPtr<CefFrame> frame = it->second.first;
    CefRefPtr<CefV8Value> callback = it->second.second;
    CefRefPtr<CefV8Context> context = frame->GetV8Context();
    context->Enter();
    CefV8ValueList v8Arguments = CefListValueToCefV8ValueList(args);
    CefRefPtr<CefV8Value> v8ReturnValue = callback->ExecuteFunction(
            nullptr, v8Arguments);
    if (v8ReturnValue.get()) {
        context->Exit();
        return true;
    } else {
        context->Exit();
        LOG(ERROR) << "[Renderer process] ExecuteJavascriptCallback():"
                      " callback->ExecuteFunction() failed";
        return false;
    }
}

void RemoveJavascriptCallbacksForFrame(CefRefPtr<CefFrame> frame) {
    if (g_jsCallbackMap.empty()) {
        return;
    }
    JavascriptCallbackMap::iterator it = g_jsCallbackMap.begin();
    CefString frameId = frame->GetIdentifier();
    while (it != g_jsCallbackMap.end()) {
        if (it->second.first->GetIdentifier() == frameId) {
            // Pass current iterator and increment it after passing
            // to the function, but before erase() is called, this 
            // is important for it to work in a loop. You can't do this:
            // | if (..) erase(it);
            // | ++it;
            // This would cause an infinite loop.
            g_jsCallbackMap.erase(it++);
            LOG(INFO) << "[Renderer process]"
                         " RemoveJavascriptCallbacksForFrame():"
                         " removed js callback from the map";
        } else {
            ++it;
        }
    }
}
