"use strict";

/*global window*/

// Handling javascript errors, calling PyJavascriptError which
// was binded using javascript bindings, see cefadvanced.py.

window.onerror = function (errorMessage, url, lineNumber)
{
	window.PyJavascriptError(errorMessage, url, lineNumber);
	return false;
};
