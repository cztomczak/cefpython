This is just a draft that outlines topics yet to be written.
TODO: see the CEF Tutorial wiki

# Tutorial


## Download and install

* download from Releases/
* types of packages for each platform
* install from PyPI using pip (Win/Mac)


## Simple example using wxPython

* paste code, most simple example loading www.google.com,
  shouldn't be more than 20 lines.

* Explain all functions from the example:
    - initialize()
        you can call initialize and shutdown only once
    - shutdown()
        - to exit cleanly
        - cookies or other storage might not be saved (flushed every 30 secs)
          process might freeze (XP experienced)
    - messageloop
    - messageloopwork
        - messageloop faster, but this one allows integration into
          existing message loop

* ExceptHook in examples so that all processes are closed in
  case of a python error

* there are more examples in the examples/ directory.


## Settings

* Describe a few most commonly used settings.
* Command-line switches from Chromium.
* Disable developer-tools or context menu
    - application settings context menu dict.


## Documentation and help

* see the api/ directory.
    - API categories.md and API full index.md
      will help you navigate through API.

* knowledge base document

* "Search this repository" to search through documentation and code

* Try google "cef +search-phrase"

* Forum - ask questions and report problems there, not in Issue Tracker

* See Tutorial-intermediate.
