[API categories](API-categories.md) | [API index](API-index.md)


# V8ContextHandler (interface)

Implement this interface to handle javascript exceptions globally.


Table of contents:
* [Notes](#notes)
* [Callbacks](#callbacks)
  * [OnContextCreated](#oncontextcreated)
  * [OnContextReleased](#oncontextreleased)


## Notes

Callbacks available in upstream CEF, but not yet exposed in CEF Python:
* OnUncaughtException


## Callbacks


### OnContextCreated

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| __Return__ | void |

Called shortly after (process message delay) the V8 context for
a frame has been created.

If the page does not contain `<script>` tags then this method
won't get called.


### OnContextReleased

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| __Return__ | void |

Called shortly after (process message delay) the V8 context for
a frame was released.

Due to multi-process architecture in CEF 3, this function won't
get called for the main frame in main browser. To send a message
from the renderer process a parent browser is used. If this is
the main frame then this would mean that the browser is being
destroyed, thus we can't send a process message using this browser.
There is no guarantee that this will get called for frames in the
main browser, if the browser is destroyed shortly after the frames
were released.
