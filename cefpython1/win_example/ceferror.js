"use strict";

/*global window*/

// Handling javascript errors, calling HandleJavascriptError which
// was binded using javascript bindings, see cefadvanced.py.

window.onerror = function (errorMessage, url, lineNumber)
{
	window.HandleJavascriptError(errorMessage, url, lineNumber);
	return false;
};
