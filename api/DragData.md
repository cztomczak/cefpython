[API categories](API-categories.md) | [API index](API-index.md)


# DragData (object)


Table of contents:
* [Methods](#methods)
  * [IsFile](#isfile)
  * [IsLink](#islink)
  * [IsFragment](#isfragment)
  * [GetFileName](#getfilename)
  * [GetFileNames](#getfilenames)
  * [GetLinkUrl](#getlinkurl)
  * [GetLinkTitle](#getlinktitle)
  * [GetFragmentText](#getfragmenttext)
  * [GetFragmentHtml](#getfragmenthtml)
  * [GetImage](#getimage)
  * [GetImageHotspot](#getimagehotspot)
  * [HasImage](#hasimage)


## Methods

### IsFile

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the drag data is a file.

### IsLink

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the drag data is a link.


### IsFragment

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the drag data is a text or html fragment.


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

