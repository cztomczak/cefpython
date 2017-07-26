[API categories](API-categories.md) | [API index](API-index.md)


# DragData (object)


Table of contents:
* [Methods](#methods)
  * [AddFile](#addfile)
  * [IsLink](#islink)
  * [IsFile](#isfile)
  * [IsFragment](#isfragment)
  * [GetLinkUrl](#getlinkurl)
  * [GetLinkTitle](#getlinktitle)
  * [GetFileName](#getfilename)
  * [GetFileNames](#getfilenames)
  * [GetFragmentText](#getfragmenttext)
  * [GetFragmentHtml](#getfragmenthtml)
  * [GetImage](#getimage)
  * [GetImageHotspot](#getimagehotspot)
  * [HasImage](#hasimage)
  * [SetFragmentText](#setfragmenttext)
  * [SetFragmentHtml](#setfragmenthtml)

## Methods

### AddFile

| | |
| --- | --- |
| path | string |
| display_name  | string |
| __Return__ | void |

Add a file that is being dragged into the webview.


### IsLink

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the drag data is a link.


### IsFile

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the drag data is a file.


### IsFragment

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the drag data is a text or html fragment.


### GetLinkUrl

| | |
| --- | --- |
| __Return__ | string |


Return the link URL that is being dragged.


### GetLinkTitle

| | |
| --- | --- |
| __Return__ | string |

Return the title associated with the link being dragged.


### GetFileName

| | |
| --- | --- |
| __Return__ | string |


Return the name of the file being dragged out of the browser window.


### GetFileNames

| | |
| --- | --- |
| __Return__ | list |


Return the list of file names that are being dragged into the browser window.


### GetFragmentText

| | |
| --- | --- |
| __Return__ | string |

Return the plain text fragment that is being dragged.


### GetFragmentHtml

| | |
| --- | --- |
| __Return__ | string |

Return the text/html fragment that is being dragged.


### GetImage

| | |
| --- | --- |
| __Return__ | [Image](Image.md) |

Linux-only currently (#251).

Get image representation of drag data. Check with HasImage() first,
otherwise if there is no image an exception is thrown.


### GetImageHotspot

| | |
| --- | --- |
| __Return__ | [Image](Image.md) |

Linux-only currently (#251).

Get image hotspot (drag start location relative to image dimensions).


### HasImage

| | |
| --- | --- |
| __Return__ | bool |

Linux-only currently (#251).

Whether image representation of drag data is available.

### SetFragmentText

| | |
| --- | --- |
| text | string |
| __Return__ | void |

Set the plain text fragment that is being dragged.

### SetFragmentHtml

| | |
| --- | --- |
| html | string |
| __Return__ | void |

Set the text/html fragment that is being dragged.
