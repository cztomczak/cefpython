# Security #

The quote from the CEF forum regarding the security in CEF:<br>
<a href='http://magpcss.org/ceforum/viewtopic.php?f=10&t=10222'>http://magpcss.org/ceforum/viewtopic.php?f=10&amp;t=10222</a>

<blockquote>CEF offers significant integration capabilities beyond what is offered by a standard Google Chrome browser installation. The trade off for these additional capabilities is that organizations using CEF must take responsibility for their own application security. CEF and the underlying open source projects (Chromium, WebKit, etc) involve a significant amount of code and offer no warranties. Organizations should document and follow best practices to minimize potential security risks. Here are some recommended best practices that organizations can consider:</blockquote>

<ul><li>Only load known/trusted content. This is by far the best way to avoid potential security issues.<br>
</li><li>Disable plugins. This will avoid a large category of security issues caused by buggy versions of Flash, Java, etc.<br>
</li><li>Do not explicitly disable or bypass security features in your application. For example, do not enable CefBrowserSettings that bypass security features or add fake headers to bypass HTTP access control.<br>
</li><li>Keep your application up to date with the newest CEF release branch. You may want to update the underlying Chromium release version and perform your own builds to take immediate advantage of any bug fixes.<br>
</li><li>Enforce good programming practices. Every organization should have best practices for design, testing and verification.<br>
</li><li>Audit your application for potential security issues. Every decision that may have security consequences should be evaluated by people who are knowledgeable about security considerations.