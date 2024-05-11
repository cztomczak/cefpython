// Copyright (c) 2016 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

#ifndef CEF_TESTS_SHARED_BROWSER_MAIN_MESSAGE_LOOP_EXTERNAL_PUMP_H_
#define CEF_TESTS_SHARED_BROWSER_MAIN_MESSAGE_LOOP_EXTERNAL_PUMP_H_
#pragma once

#include "main_message_loop_std.h"

// This MessageLoop implementation simulates the embedding of CEF into an
// existing host application that runs its own message loop. The scheduling
// implementation provided by this class is very simplistic and does not handle
// all cases (for example, nested message loops on Windows will not function
// correctly). See comments in Chromium's platform-specific
// base/message_loop/message_pump_* source files for additional guidance when
// implementing CefBrowserProcessHandler::OnScheduleMessagePumpWork() in your
// application. Run cefclient or ceftests with the
// "--external-message-pump" command-line flag to test this mode.
class MainMessageLoopExternalPump : public MainMessageLoopStd {
 public:
  // Creates the singleton instance of this object. Must be called on the main
  // application thread.
  static std::unique_ptr<MainMessageLoopExternalPump> Create();

  // Returns the singleton instance of this object. Safe to call from any
  // thread.
  static MainMessageLoopExternalPump* Get();

  // Called from CefBrowserProcessHandler::OnScheduleMessagePumpWork() on any
  // thread. The platform subclass must implement this method and schedule a
  // call to OnScheduleWork() on the main application thread.
  virtual void OnScheduleMessagePumpWork(int64_t delay_ms) = 0;

 protected:
  // Only allow deletion via std::unique_ptr.
  friend std::default_delete<MainMessageLoopExternalPump>;

  // Construct and destruct this object on the main application thread.
  MainMessageLoopExternalPump();
  ~MainMessageLoopExternalPump();

  // The platform subclass calls this method on the main application thread in
  // response to the OnScheduleMessagePumpWork() call.
  void OnScheduleWork(int64_t delay_ms);

  // The platform subclass calls this method on the main application thread when
  // the pending work timer times out.
  void OnTimerTimeout();

  // Control the pending work timer in the platform subclass. Only called on
  // the main application thread.
  virtual void SetTimer(int64_t delay_ms) = 0;
  virtual void KillTimer() = 0;
  virtual bool IsTimerPending() = 0;

 private:
  // Handle work processing.
  void DoWork();
  bool PerformMessageLoopWork();

  bool is_active_;
  bool reentrancy_detected_;
};

#endif  // CEF_TESTS_SHARED_BROWSER_MAIN_MESSAGE_LOOP_EXTERNAL_PUMP_H_
