// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class ClientHandler : public CefClient
{
public:
  ClientHandler(){}
  virtual ~ClientHandler(){}

protected:
   
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ClientHandler);
  
  // Include the default locking implementation.
  IMPLEMENT_LOCKING(ClientHandler);

};
