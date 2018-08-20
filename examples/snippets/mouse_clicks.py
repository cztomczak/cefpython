# Perform mouse clicks and mouse movements programmatically.

from cefpython3 import cefpython as cef


def main():
    cef.Initialize()
    browser = cef.CreateBrowserSync(
        url="data:text/html,<h1>Mouse clicks snippet</h1>"
            "This text will be selected after one second.<br>"
            "This text will be selected after two seconds.",
        window_title="Mouse clicks")
    browser.SetClientHandler(LifespanHandler())
    cef.MessageLoop()
    del browser
    cef.Shutdown()


def click_after_1_second(browser):
    print("Click after 1 second")
    # Mouse move to the top-left corner of the text
    browser.SendMouseMoveEvent(0, 70, False, 0)
    # Left mouse button click in the top-left corner of the text
    browser.SendMouseClickEvent(0, 70, cef.MOUSEBUTTON_LEFT, False, 1)
    # Mouse move to the bottom-right corner of the text,
    # while holding left mouse button.
    browser.SendMouseMoveEvent(400, 80, False, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)
    # Release left mouse button
    browser.SendMouseClickEvent(400, 80, cef.MOUSEBUTTON_LEFT, True, 1)
    cef.PostDelayedTask(cef.TID_UI, 1000, click_after_2_seconds, browser)


def click_after_2_seconds(browser):
    print("Click after 2 seconds")
    browser.SendMouseMoveEvent(0, 90, False, 0)
    browser.SendMouseClickEvent(0, 90, cef.MOUSEBUTTON_LEFT, False, 1)
    browser.SendMouseMoveEvent(400, 99, False, cef.EVENTFLAG_LEFT_MOUSE_BUTTON)
    browser.SendMouseClickEvent(400, 99, cef.MOUSEBUTTON_LEFT, True, 1)
    cef.PostDelayedTask(cef.TID_UI, 1000, click_after_1_second, browser)


class LifespanHandler(object):
    def OnLoadEnd(self, browser, **_):
        # Execute function with a delay of 1 second after page
        # has completed loading.
        print("Page loading is complete")
        cef.PostDelayedTask(cef.TID_UI, 1000, click_after_1_second, browser)


if __name__ == '__main__':
    main()
