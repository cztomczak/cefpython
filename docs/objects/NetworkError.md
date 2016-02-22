# Network error constants #

These constants are for use with: [LoadHandler](LoadHandler).`OnLoadError()`, [WebRequestClient](WebRequestClient).`OnError()`, [RequestHandler](RequestHandler).`OnCertificateError()`.

For an up-to-date list of error codes see "net\_error\_list.h" in the Chromium trunk: http://src.chromium.org/viewvc/chrome/trunk/src/net/base/net_error_list.h?view=markup

cefpython.**ERR\_NONE**

> No error.

cefpython.**ERR\_ABORTED**

> An operation was aborted (due to user action).

cefpython.**ERR\_ACCESS\_DENIED**

> Permission to access a resource, other than the network, was denied.

cefpython.**ERR\_ADDRESS\_INVALID**

> The IP address or port number is invalid (e.g., cannot connect to the IP address 0 or the port 0).

cefpython.**ERR\_ADDRESS\_UNREACHABLE**

> The IP address is unreachable.  This usually means that there is no route to the specified host or network.

cefpython.**ERR\_CACHE\_MISS**

> The cache does not have the requested entry.

cefpython.**ERR\_CERT\_AUTHORITY\_INVALID**

> The server responded with a certificate that is signed by an authority
> we don't trust. That could mean:

  1. An attacker has substituted the real certificate for a cert that contains his public key and is signed by his cousin.
  1. The server operator has a legitimate certificate from a CA we don't know about, but should trust.
  1. The server is presenting a self-signed certificate, providing no defense against active attackers (but foiling passive attackers).

cefpython.**ERR\_CERT\_COMMON\_NAME\_INVALID**

> The server responded with a certificate whose common name did not match
> the host name.  This could mean:

  1. An attacker has redirected our traffic to his server and is  presenting a certificate for which he knows the private key.
  1. The server is misconfigured and responding with the wrong cert.
  1. The user is on a wireless network and is being redirected to the network's login page.
  1. The OS has used a DNS search suffix and the server doesn't have a certificate for the abbreviated name in the address bar.

cefpython.**ERR\_CERT\_CONTAINS\_ERRORS**

> The server responded with a certificate that contains errors.
> This error is not recoverable. MSDN describes this error as follows:
> "The SSL certificate contains errors."
> NOTE: It's unclear how this differs from ERR\_CERT\_INVALID. For consistency,
> use that code instead of this one from now on.

cefpython.**ERR\_CERT\_DATE\_INVALID**

> The server responded with a certificate that, by our clock, appears to
> either not yet be valid or to have expired.  This could mean:

  1. An attacker is presenting an old certificate for which he has managed to obtain the private key.
  1. The server is misconfigured and is not presenting a valid cert.
  1. Our clock is wrong.

cefpython.**ERR\_CERT\_END**

> The value immediately past the last certificate error code.

cefpython.**ERR\_CERT\_INVALID**

> The server responded with a certificate that is invalid.
> This error is not recoverable.
> MSDN describes this error as follows:
> "The SSL certificate is invalid."

cefpython.**ERR\_CERT\_NO\_REVOCATION\_MECHANISM**

> The certificate has no mechanism for determining if it is revoked.  In
> effect, this certificate cannot be revoked.

cefpython.**ERR\_CERT\_REVOKED**

> The server responded with a certificate has been revoked.
> We have the capability to ignore this error, but it is probably not the
> thing to do.

cefpython.**ERR\_CERT\_UNABLE\_TO\_CHECK\_REVOCATION**

> Revocation information for the security certificate for this site is not
> available.  This could mean:

  1. An attacker has compromised the private key in the certificate and is blocking our attempt to find out that the cert was revoked.
  1. The certificate is unrevoked, but the revocation server is busy or unavailable.

cefpython.**ERR\_CONNECTION\_ABORTED**

> A connection timed out as a result of not receiving an ACK for data sent.
> This can include a FIN packet that did not get ACK'd.

cefpython.**ERR\_CONNECTION\_CLOSED**

> A connection was closed (corresponding to a TCP FIN).

cefpython.**ERR\_CONNECTION\_FAILED**

> A connection attempt failed.

cefpython.**ERR\_CONNECTION\_REFUSED**

> A connection attempt was refused.

cefpython.**ERR\_CONNECTION\_RESET**

> A connection was reset (corresponding to a TCP RST).

cefpython.**ERR\_DISALLOWED\_URL\_SCHEME**

> The scheme of the URL is disallowed.

cefpython.**ERR\_EMPTY\_RESPONSE**

> The server closed the connection without sending any data.

cefpython.**ERR\_FAILED**

> A generic failure occurred.

cefpython.**ERR\_FILE\_NOT\_FOUND**

> The file or directory cannot be found.

cefpython.**ERR\_FILE\_TOO\_BIG**

> The file is too large.

cefpython.**ERR\_INSECURE\_RESPONSE**

> The server's response was insecure (e.g. there was a cert error).

cefpython.**ERR\_INTERNET\_DISCONNECTED**

> The Internet connection has been lost.

cefpython.**ERR\_INVALID\_ARGUMENT**

> An argument to the function is incorrect.

cefpython.**ERR\_INVALID\_CHUNKED\_ENCODING**

> Error in chunked transfer encoding.

cefpython.**ERR\_INVALID\_HANDLE**

> The handle or file descriptor is invalid.

cefpython.**ERR\_INVALID\_RESPONSE**

> The server's response was invalid.

cefpython.**ERR\_INVALID\_URL**

> The URL is invalid.

cefpython.**ERR\_METHOD\_NOT\_SUPPORTED**

> The server did not support the request method.

cefpython.**ERR\_NAME\_NOT\_RESOLVED**

> The host name could not be resolved.

cefpython.**ERR\_NO\_SSL\_VERSIONS\_ENABLED**

> No SSL protocol versions are enabled.

cefpython.**ERR\_NOT\_IMPLEMENTED**

> The operation failed because of unimplemented functionality.

cefpython.**ERR\_RESPONSE\_HEADERS\_TOO\_BIG**

> The headers section of the response is too large.

cefpython.**ERR\_SSL\_CLIENT\_AUTH\_CERT\_NEEDED**

> The server requested a client certificate for SSL client authentication.

cefpython.**ERR\_SSL\_PROTOCOL\_ERROR**

> An SSL protocol error occurred.

cefpython.**ERR\_SSL\_RENEGOTIATION\_REQUESTED**

> The server requested a renegotiation (rehandshake).

cefpython.**ERR\_SSL\_VERSION\_OR\_CIPHER\_MISMATCH**

> The client and server don't support a common SSL protocol version or
> cipher suite.

cefpython.**ERR\_TIMED\_OUT**

> An operation timed out.

cefpython.**ERR\_TOO\_MANY\_REDIRECTS**

> Attempting to load an URL resulted in too many redirects.

cefpython.**ERR\_TUNNEL\_CONNECTION\_FAILED**

> A tunnel connection through the proxy could not be established.

cefpython.**ERR\_UNEXPECTED**

> An unexpected error.  This may be caused by a programming mistake or an
> invalid assumption.

cefpython.**ERR\_UNEXPECTED\_PROXY\_AUTH**

> The response was 407 (Proxy Authentication Required), yet we did not send
> the request to a proxy.

cefpython.**ERR\_UNKNOWN\_URL\_SCHEME**

> The scheme of the URL is unknown.

cefpython.**ERR\_UNSAFE\_PORT**

> Attempting to load an URL with an unsafe port number.  These are port
> numbers that correspond to services, which are not robust to spurious input
> that may be constructed as a result of an allowed web construct (e.g., HTTP
> looks a lot like SMTP, so form submission to port 25 is denied).

cefpython.**ERR\_UNSAFE\_REDIRECT**

> Attempting to load an URL resulted in an unsafe redirect (e.g., a redirect
> to file:// is considered unsafe).