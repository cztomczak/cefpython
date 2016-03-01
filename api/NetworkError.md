[API categories](API-categories.md) | [API index](API-index.md)


# Network error

These constants are defined in the main [cefpython](cefpython.md) module. They are for use with:
* [LoadHandler](LoadHandler.md).OnLoadError()
* [WebRequestClient](WebRequestClient.md).OnError()
* [RequestHandler](RequestHandler.md).OnCertificateError()

For an up-to-date list of error codes see [net_error_list.h](http://src.chromium.org/viewvc/chrome/trunk/src/net/base/net_error_list.h?view=markup) in Chromium.


Table of contents:
* [Constants](#constants)
  * [ERR_NONE](#errnone)
  * [ERR_ABORTED](#erraborted)
  * [ERR_ACCESS_DENIED](#erraccessdenied)
  * [ERR_ADDRESS_INVALID](#erraddressinvalid)
  * [ERR_ADDRESS_UNREACHABLE](#erraddressunreachable)
  * [ERR_CACHE_MISS](#errcachemiss)
  * [ERR_CERT_AUTHORITY_INVALID](#errcertauthorityinvalid)
  * [ERR_CERT_COMMON_NAME_INVALID](#errcertcommonnameinvalid)
  * [ERR_CERT_CONTAINS_ERRORS](#errcertcontainserrors)
  * [ERR_CERT_DATE_INVALID](#errcertdateinvalid)
  * [ERR_CERT_END](#errcertend)
  * [ERR_CERT_INVALID](#errcertinvalid)
  * [ERR_CERT_NO_REVOCATION_MECHANISM](#errcertnorevocationmechanism)
  * [ERR_CERT_REVOKED](#errcertrevoked)
  * [ERR_CERT_UNABLE_TO_CHECK_REVOCATION](#errcertunabletocheckrevocation)
  * [ERR_CONNECTION_ABORTED](#errconnectionaborted)
  * [ERR_CONNECTION_CLOSED](#errconnectionclosed)
  * [ERR_CONNECTION_FAILED](#errconnectionfailed)
  * [ERR_CONNECTION_REFUSED](#errconnectionrefused)
  * [ERR_CONNECTION_RESET](#errconnectionreset)
  * [ERR_DISALLOWED_URL_SCHEME](#errdisallowedurlscheme)
  * [ERR_EMPTY_RESPONSE](#erremptyresponse)
  * [ERR_FAILED](#errfailed)
  * [ERR_FILE_NOT_FOUND](#errfilenotfound)
  * [ERR_FILE_TOO_BIG](#errfiletoobig)
  * [ERR_INSECURE_RESPONSE](#errinsecureresponse)
  * [ERR_INTERNET_DISCONNECTED](#errinternetdisconnected)
  * [ERR_INVALID_ARGUMENT](#errinvalidargument)
  * [ERR_INVALID_CHUNKED_ENCODING](#errinvalidchunkedencoding)
  * [ERR_INVALID_HANDLE](#errinvalidhandle)
  * [ERR_INVALID_RESPONSE](#errinvalidresponse)
  * [ERR_INVALID_URL](#errinvalidurl)
  * [ERR_METHOD_NOT_SUPPORTED](#errmethodnotsupported)
  * [ERR_NAME_NOT_RESOLVED](#errnamenotresolved)
  * [ERR_NO_SSL_VERSIONS_ENABLED](#errnosslversionsenabled)
  * [ERR_NOT_IMPLEMENTED](#errnotimplemented)
  * [ERR_RESPONSE_HEADERS_TOO_BIG](#errresponseheaderstoobig)
  * [ERR_SSL_CLIENT_AUTH_CERT_NEEDED](#errsslclientauthcertneeded)
  * [ERR_SSL_PROTOCOL_ERROR](#errsslprotocolerror)
  * [ERR_SSL_RENEGOTIATION_REQUESTED](#errsslrenegotiationrequested)
  * [ERR_SSL_VERSION_OR_CIPHER_MISMATCH](#errsslversionorciphermismatch)
  * [ERR_TIMED_OUT](#errtimedout)
  * [ERR_TOO_MANY_REDIRECTS](#errtoomanyredirects)
  * [ERR_TUNNEL_CONNECTION_FAILED](#errtunnelconnectionfailed)
  * [ERR_UNEXPECTED](#errunexpected)
  * [ERR_UNEXPECTED_PROXY_AUTH](#errunexpectedproxyauth)
  * [ERR_UNKNOWN_URL_SCHEME](#errunknownurlscheme)
  * [ERR_UNSAFE_PORT](#errunsafeport)
  * [ERR_UNSAFE_REDIRECT](#errunsaferedirect)


## Constants


### ERR_NONE

No error.


### ERR_ABORTED

An operation was aborted (due to user action).


### ERR_ACCESS_DENIED

Permission to access a resource, other than the network, was denied.


### ERR_ADDRESS_INVALID

The IP address or port number is invalid (e.g., cannot connect to the IP address 0 or the port 0).


### ERR_ADDRESS_UNREACHABLE

The IP address is unreachable.  This usually means that there is no route to the specified host or network.


### ERR_CACHE_MISS

The cache does not have the requested entry.


### ERR_CERT_AUTHORITY_INVALID

The server responded with a certificate that is signed by an authority
we don't trust. That could mean:

  1. An attacker has substituted the real certificate for a cert that contains his public key and is signed by his cousin.
  1. The server operator has a legitimate certificate from a CA we don't know about, but should trust.
  1. The server is presenting a self-signed certificate, providing no defense against active attackers (but foiling passive attackers).


### ERR_CERT_COMMON_NAME_INVALID

The server responded with a certificate whose common name did not match
the host name.  This could mean:

  1. An attacker has redirected our traffic to his server and is  presenting a certificate for which he knows the private key.
  1. The server is misconfigured and responding with the wrong cert.
  1. The user is on a wireless network and is being redirected to the network's login page.
  1. The OS has used a DNS search suffix and the server doesn't have a certificate for the abbreviated name in the address bar.


### ERR_CERT_CONTAINS_ERRORS

The server responded with a certificate that contains errors.
This error is not recoverable. MSDN describes this error as follows:
"The SSL certificate contains errors."
NOTE: It's unclear how this differs from ERR_CERT_INVALID. For consistency,
use that code instead of this one from now on.


### ERR_CERT_DATE_INVALID

The server responded with a certificate that, by our clock, appears to
either not yet be valid or to have expired.  This could mean:

  1. An attacker is presenting an old certificate for which he has managed to obtain the private key.
  1. The server is misconfigured and is not presenting a valid cert.
  1. Our clock is wrong.


### ERR_CERT_END

The value immediately past the last certificate error code.


### ERR_CERT_INVALID

The server responded with a certificate that is invalid.
This error is not recoverable.
MSDN describes this error as follows:
"The SSL certificate is invalid."


### ERR_CERT_NO_REVOCATION_MECHANISM

The certificate has no mechanism for determining if it is revoked.  In
effect, this certificate cannot be revoked.


### ERR_CERT_REVOKED

The server responded with a certificate has been revoked.
We have the capability to ignore this error, but it is probably not the
thing to do.


### ERR_CERT_UNABLE_TO_CHECK_REVOCATION

Revocation information for the security certificate for this site is not
available.  This could mean:

  1. An attacker has compromised the private key in the certificate and is blocking our attempt to find out that the cert was revoked.
  1. The certificate is unrevoked, but the revocation server is busy or unavailable.


### ERR_CONNECTION_ABORTED

A connection timed out as a result of not receiving an ACK for data sent.
This can include a FIN packet that did not get ACK'd.


### ERR_CONNECTION_CLOSED

A connection was closed (corresponding to a TCP FIN).


### ERR_CONNECTION_FAILED

A connection attempt failed.


### ERR_CONNECTION_REFUSED

A connection attempt was refused.


### ERR_CONNECTION_RESET

A connection was reset (corresponding to a TCP RST).


### ERR_DISALLOWED_URL_SCHEME

The scheme of the URL is disallowed.


### ERR_EMPTY_RESPONSE

The server closed the connection without sending any data.


### ERR_FAILED

A generic failure occurred.


### ERR_FILE_NOT_FOUND

The file or directory cannot be found.


### ERR_FILE_TOO_BIG

The file is too large.


### ERR_INSECURE_RESPONSE

The server's response was insecure (e.g. there was a cert error).


### ERR_INTERNET_DISCONNECTED

The Internet connection has been lost.


### ERR_INVALID_ARGUMENT

An argument to the function is incorrect.


### ERR_INVALID_CHUNKED_ENCODING

Error in chunked transfer encoding.


### ERR_INVALID_HANDLE

The handle or file descriptor is invalid.


### ERR_INVALID_RESPONSE

The server's response was invalid.


### ERR_INVALID_URL

The URL is invalid.


### ERR_METHOD_NOT_SUPPORTED

The server did not support the request method.


### ERR_NAME_NOT_RESOLVED

The host name could not be resolved.


### ERR_NO_SSL_VERSIONS_ENABLED

No SSL protocol versions are enabled.


### ERR_NOT_IMPLEMENTED

The operation failed because of unimplemented functionality.


### ERR_RESPONSE_HEADERS_TOO_BIG

The headers section of the response is too large.


### ERR_SSL_CLIENT_AUTH_CERT_NEEDED

The server requested a client certificate for SSL client authentication.


### ERR_SSL_PROTOCOL_ERROR

An SSL protocol error occurred.


### ERR_SSL_RENEGOTIATION_REQUESTED

The server requested a renegotiation (rehandshake).


### ERR_SSL_VERSION_OR_CIPHER_MISMATCH

The client and server don't support a common SSL protocol version or
cipher suite.


### ERR_TIMED_OUT

An operation timed out.


### ERR_TOO_MANY_REDIRECTS

Attempting to load an URL resulted in too many redirects.


### ERR_TUNNEL_CONNECTION_FAILED

A tunnel connection through the proxy could not be established.


### ERR_UNEXPECTED

An unexpected error.  This may be caused by a programming mistake or an
invalid assumption.


### ERR_UNEXPECTED_PROXY_AUTH

The response was 407 (Proxy Authentication Required), yet we did not send
the request to a proxy.


### ERR_UNKNOWN_URL_SCHEME

The scheme of the URL is unknown.


### ERR_UNSAFE_PORT

Attempting to load an URL with an unsafe port number.  These are port
numbers that correspond to services, which are not robust to spurious input
that may be constructed as a result of an allowed web construct (e.g., HTTP
looks a lot like SMTP, so form submission to port 25 is denied).


### ERR_UNSAFE_REDIRECT

Attempting to load an URL resulted in an unsafe redirect (e.g., a redirect
to file:// is considered unsafe).
