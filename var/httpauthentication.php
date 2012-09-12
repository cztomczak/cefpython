<?php

# Remember that CefRequestHandler::GetAuthCredentials() is called
# on IO thread, you need to use CefPostTask() on GUI thread to display
# a form for entering username/password.

HttpAuthentication();

function HttpAuthentication()
{
	if (!isset($_SERVER['PHP_AUTH_USER'])) {
		
		header('WWW-Authenticate: Basic realm="CEF Realm"');
		header('HTTP/1.0 401 Unauthorized');		
		print 'The process of authentication was cancelled.';		
		exit();

	} else {
		
		$username = $_SERVER['PHP_AUTH_USER'];
		$password = $_SERVER['PHP_AUTH_PW'];

		print "Authenticated successfully.<br>";
		print "Username=$username<br>";
		print "Password=$password<br>";

	}
}

?>