This is just a draft that outlines topics yet to be written.
TODO: see the CEF General Usage and Javascript Integration wikis.

# Tutorial - intermediate

* Read first Tutorial-beginner.


## Architecture

* subprocess.exe
* browser process
* renderer process
* gpu process
* zygote on linux
* Describe browser process threads


## Handlers

* What are handlers.
* Handler callbacks may be called either on UI thread or IO thread.
  Use functions for posting tasks when need to access UI thread from IO thread.
* Example code how to use handlers - use base code from Tutorial-beginner.
    - keyboard handler F12 devtools and F5
    - loadhandler onloadstart to insert js to all pages
    - loadhandler onloadingstatechange when page completed loading
    - onloaderror


## Javascript integration

* how to expose function to js
* how to communicate two-way js<>python
* callbacks
* js errors handling
* example code how to use - use base code from Tutorial-beginner.


## Plugins

* Load PPAPI flash plugin
    - console window issue on Windows in CEF 47, possible solutions


## Off-screen rendering

* Describe difference between windowed rendering and off-screen rendering.
* Panda3D and Kivy - offscreen
* The rest - windowed
* Describe render handler callbacks in kivy - how this works.

