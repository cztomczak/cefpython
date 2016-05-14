# jQuery selectBox: A styleable replacement for SELECT elements

_Licensed under the MIT license: http://opensource.org/licenses/MIT_

## Features

* Supports OPTGROUPS
* Supports standard dropdown controls
* Supports multi-select controls (i.e. multiple="multiple")
* Supports inline controls (i.e. size="5")
* Fully accessible via keyboard
* Shift + click (or shift + enter) to select a range of options in multi-select controls
* Type to search when the control has focus
* Auto-height based on the size attribute (to use, omit the height property in your CSS!)
* Tested in IE7-IE9, Firefox 3-4, recent WebKit browsers, and Opera


## Usage

Link to the JS file:

```html
<script src="jquery.selectbox.min.js" type="text/javascript"></script>
```

Add the CSS file (or append contents to your own stylesheet):

```html
<link href="jquery.selectbox.css" rel="stylesheet" type="text/css" />
```

To initialize:

```javascript
// default
$('select').selectBox();

// or with custom settings
$('select').selectBox({
    mobile: true,
    menuSpeed: 'fast'
});
```

## Settings

| Key            | Default       | Values                     |  Description                                     |
| ---------------|:-------------:|---------------------------:|-------------------------------------------------:|
| mobile         | `false`       | Boolean                    | Disables the widget for mobile devices           |
| menuTransition | `default`     | `default`, `slide`, `fade` | The show/hide transition for dropdown menus      |
| menuSpeed      | `normal`      | `slow`, `normal`, `fast`   | The show/hide transition speed                   |
| loopOptions    | `false`       | Boolean                    | Flag to allow arrow keys to loop through options |


To specify settings after the init, use this syntax:

```javascript
$('select').selectBox('settings', {settingName: value, ... });
```

## Methods

To call a method use this syntax:

```javascript
$('select').selectBox('methodName', [option]);
```

### Available methods


| Key            | Description                                                                                   |
| ---------------|-----------------------------------------------------------------------------------------------|
| create         | Creates the control (default)                                                                 |
| destroy        | Destroys the selectBox control and reverts back to the original form control                  |
| disable        | Disables the control (i.e. disabled="disabled")                                               |
| enable         | Enables the control                                                                           |
| value          | If passed with a value, sets the control to that value; otherwise returns the current value   |
| options        | If passed either a string of HTML or a JSON object, replaces the existing options; otherwise Returns the options container element as a jQuery object |
| control        | Returns the selectBox control element (an anchor tag) for working with directly               |
| refresh        | Updates the selectBox control's options based on the original controls options                |
| instance       | Returns the SelectBox instance, where you have more methods available (only in v1.2.0-dev     |
                 | available) as in the `SelectBox` class below.                                                 |

## API `SelectBox`

You can instantiate the selectBox also through a classic OOP way:

```javascript
var selectBox = new SelectBox($('#mySelectBox'), settings = {});
selectBox.showMenu();
```

The public methods are:

```javascript
refresh()
destroy()
disable()
enable()

getLabelClass()
getLabelText()
getSelectElement()
getOptions(String type = 'inline'|'dropdown')

hideMenus()
showMenu()

setLabel()
setOptions(Object options)
setValue(String value)

removeHover(HTMLElement li)
addHover(HTMLElement li)

disableSelection(HTMLElement selector)
generateOptions(jQuery self, jQuery options)
handleKeyDown(event)
handleKeyPress(event)
init(options)
keepOptionInView(jQuery li, Boolean center)
refresh()
removeHover(HTMLElement li)
selectOption(HTMLElement li, event)
```

## Events

Events are fired on the original select element. You can bind events like this:

```javascript
$('select').selectBox().change(function () {
    alert($(this).val());
});
```

### Available events

| Key            | Description                                                                                   |
| ---------------|-----------------------------------------------------------------------------------------------|
| focus          | Fired when the control gains focus                                                            |
| blur           | Fired when the control loses focus                                                            |
| change         | Fired when the value of a control changes                                                     |
| beforeopen     | Fired before a dropdown menu opens (cancelable)                                               |
| open           | Fired after a dropdown menu opens (not cancelable)                                            |
| beforeclose    | Fired before a dropdown menu closes (cancelable)                                              |
| close          | Fired after a dropdown menu closes (not cancelable)                                           |

### Known Issues

* The blur and focus callbacks are not very reliable in IE7. The change callback works fine.

## Credits

Original plugin by Cory LaViska of A Beautiful Site, LLC. (http://www.abeautifulsite.net/)