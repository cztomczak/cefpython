# WindowUtils class #

All methods of this class are static. Access this class through [cefpython](cefpython).`WindowUtils`.

def **OnSetFocus**(int `windowHandle`, long `msg`, long `wparam`, long `lparam`)

> This method processes WM\_SETFOCUS message which is sent to a window after it has gained the keyboard focus.

def **OnSize**(int `windowHandle`, long `msg`, long `wparam`, long `lparam`)

> This method processes WM\_SIZE message which is sent to a window after its size has changed.

def **OnEraseBackground**(int `windowHandle`, long `msg`, long `wparam`, long `lparam`)

> This method processes WM\_ERASEBKGND message which is sent when the window background must be erased (for example, when a window is resized).

> This is a Windows-only function.

def **SetTitle**([Browser](Browser) `browser`, str `title`)

> Set the title for the main window or popup window. The default implementation of [DisplayHandler](DisplayHandler).`OnTitleChange()` calls this method to set the title for a window.

def **SetIcon**([Browser](Browser) `browser`, string `icon`="inherit")

> Set the icon for the popup window. The default implementation of [DisplayHandler](DisplayHandler).`OnTitleChange()` calls this method to set the icon for a window that wasn't created explicitily (for example a popup window), the icon is inherited from the parent window. Icon parameter accepts only "inherit", you cannot pass here a path to an icon (currently not implemented).

def **GetParentHandle**(int `windowHandle`)

> Get a parent handle.

def **IsWindowHandle**(int `windowHandle`)

> Check whether this is a valid window handle.

def **gtk\_plug\_new**(long long `GdkNativeWindow`)

> Available only on Linux. This method is utilized in the pyqt example.

def **gtk\_widget\_show**(long long `GtkWidget*`)

> Available only on Linux. This method is utilized in the pyqt example.