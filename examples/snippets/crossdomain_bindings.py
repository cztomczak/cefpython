"""
Test JavaScript bindings across a cross-domain navigation flow.

Simulates an SSO/auth redirect scenario:
  Step 1 - Target app page loads (example.com)
            OnContextCreated detects target domain -> injects JS -> binding fires
  Step 2 - Simulated redirect to auth/login domain (python.org)
            OnContextCreated detects non-target domain -> skips injection -> no callback
  Step 3 - Simulated auth complete, return to target app page (example.com)
            OnContextCreated detects target domain again -> binding fires again

Key points demonstrated:
- JS bindings (V8 globals) are registered for every page in the browser instance,
  including intermediate auth/login pages on other domains.
- It is the user's responsibility to filter in OnContextCreated by URL/domain before
  injecting JS so that callbacks only fire for the intended landing page.
- Each domain's V8 context is isolated: globals registered for example.com are not
  accessible to python.org and vice versa.
"""

import threading
from cefpython3 import cefpython as cef

TARGET_HOST = "example.com"
AUTH_URL = "https://www.python.org/"   # visually distinct: simulates Okta/login page
TARGET_URL = "https://example.com/"
NAV_DELAY_SEC = 3.0

# Navigation state machine: avoid re-triggering on multiple OnLoadEnd fires
STATE_INIT = "init"
STATE_ON_TARGET_1 = "on_target_1"    # first example.com load complete
STATE_GOING_AUTH = "going_auth"       # timer fired, navigating to auth
STATE_ON_AUTH = "on_auth"            # auth page load complete
STATE_GOING_TARGET = "going_target"  # timer fired, navigating back
STATE_ON_TARGET_2 = "on_target_2"    # final example.com load complete


def main():
    print(__doc__)

    def on_context_initialized():
        # Under CEF's Chrome runtime the browser context initializes
        # asynchronously, so create the browser here rather than right after
        # cef.Initialize().
        browser = cef.CreateBrowserSync(
            url=TARGET_URL,
            window_title="Cross-domain JS binding test")
        handler = CrossDomainHandler(browser)
        browser.SetClientHandler(handler)
        bindings = cef.JavascriptBindings()
        bindings.SetFunction("OnTargetPageReady", handler["_OnTargetPageReady"])
        browser.SetJavascriptBindings(bindings)

    # Register before cef.Initialize(); OnContextInitialized may fire during it.
    cef.SetGlobalClientCallback("OnContextInitialized", on_context_initialized)
    cef.Initialize()
    cef.MessageLoop()
    cef.Shutdown()


class CrossDomainHandler(object):
    def __init__(self, browser):
        self.browser = browser
        self._state = STATE_INIT

    def __getitem__(self, key):
        return getattr(self, key)

    def OnContextCreated(self, browser, frame, **_):
        if not frame.IsMain():
            return
        url = frame.GetUrl()
        if not url or url == "about:blank":
            return
        if TARGET_HOST in url:
            print("[OnContextCreated] Target domain — injecting JS binding: %s" % url)
            browser.ExecuteJavascript("""
                if (document.readyState === "complete"
                        || document.readyState === "interactive") {
                    requestAnimationFrame(function() { OnTargetPageReady(); });
                } else {
                    window.addEventListener("load", function() {
                        requestAnimationFrame(function() { OnTargetPageReady(); });
                    });
                }
            """)
        else:
            print("[OnContextCreated] Non-target domain — skipping JS: %s" % url)

    def OnLoadEnd(self, browser, frame, http_code, **_):
        if not frame.IsMain():
            return
        url = frame.GetUrl()
        if not url or url == "about:blank":
            return
        print("[OnLoadEnd] state=%s url=%s" % (self._state, url))

        if self._state == STATE_INIT and TARGET_HOST in url:
            self._state = STATE_ON_TARGET_1
            print("[OnLoadEnd] Step 1 done. Redirecting to auth in %gs..." % NAV_DELAY_SEC)
            threading.Timer(NAV_DELAY_SEC, self._navigate_auth).start()

        elif self._state == STATE_GOING_AUTH and TARGET_HOST not in url:
            self._state = STATE_ON_AUTH
            print("[OnLoadEnd] Step 2 done (auth page). Returning to app in %gs..." % NAV_DELAY_SEC)
            threading.Timer(NAV_DELAY_SEC, self._navigate_target).start()

        elif self._state == STATE_GOING_TARGET and TARGET_HOST in url:
            self._state = STATE_ON_TARGET_2
            print("[OnLoadEnd] Step 3 done. Close window to exit.")

    def _navigate_auth(self):
        self._state = STATE_GOING_AUTH
        print("[Nav] Navigating to auth domain: %s" % AUTH_URL)
        self.browser.GetMainFrame().LoadUrl(AUTH_URL)

    def _navigate_target(self):
        self._state = STATE_GOING_TARGET
        print("[Nav] Navigating back to target: %s" % TARGET_URL)
        self.browser.GetMainFrame().LoadUrl(TARGET_URL)

    def _OnTargetPageReady(self):
        url = self.browser.GetMainFrame().GetUrl()
        print("[Python callback] OnTargetPageReady fired! state=%s url=%s"
              % (self._state, url))
        self.browser.ExecuteJavascript(
            'setTimeout(function(){'
            ' alert("JS binding works!\\nState: %s\\nURL: " + window.location.href);'
            ' }, 0);' % self._state
        )


if __name__ == "__main__":
    main()
