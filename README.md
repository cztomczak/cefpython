# cefpython

<table cellspacing="0" cellpadding="0" border="0" width="100%" align="left"><tr> <td width="180"> <h1>CEF Python</h1> </td> <td valign="top"> <g:plusone size="medium" source="google:projecthosting"></g:plusone> <a title="Tweet" href="https://twitter.com/intent/tweet?text=Python+bindings+for+embedding+Chromium+browser+in+desktop+applications&amp;url=https://code.google.com/p/cefpython/" rel="nofollow"><img src="https://phpdesktop.googlecode.com/git/var/share-buttons/tweet.jpg" width="71" height="24"></img></a>  <a title="Delicious" href="https://delicious.com/save?v=5&amp;provider=cefpython&amp;noui&amp;jump=close&amp;url=https://code.google.com/p/cefpython/&amp;title=Python+bindings+for+embedding+Chromium+browser+in+desktop+applications" rel="nofollow"><img src="https://phpdesktop.googlecode.com/git/var/share-buttons/delicious.png" width="102" height="24"></img></a> <a title="Reddit this!" href="http://www.reddit.com/submit?url=https://code.google.com/p/cefpython/" rel="nofollow"><img src="https://phpdesktop.googlecode.com/git/var/share-buttons/reddit.gif?x=1" width="94" height="24"></img></a> </td> </tr></table>

<h2><a name="Introduction"></a>Introduction<a href="#Introduction" class="section_anchor"></a></h2>

<p>CEF Python is an open source project founded by <a href="http://www.linkedin.com/in/czarektomczak" rel="nofollow">Czarek Tomczak</a> in 2012 to provide python bindings for the <a href="http://code.google.com/p/chromiumembedded/" rel="nofollow">Chromium Embedded Framework</a>. See the growing list of <a href="http://en.wikipedia.org/wiki/Chromium_Embedded_Framework#Applications_using_CEF" rel="nofollow">applications using CEF</a> on wikipedia. Examples of embedding CEF browser are available for many popular GUI toolkits including: <a href="/p/cefpython/wiki/wxPython">wxPython</a>, <a href="/p/cefpython/wiki/PyGTK">PyGTK</a>, <a href="/p/cefpython/wiki/PyQt">PyQt</a>, <a href="/p/cefpython/wiki/PySide">PySide</a>, <a href="/p/cefpython/wiki/Kivy">Kivy</a>, <a href="/p/cefpython/wiki/Panda3D">Panda3D</a> and <a href="https://code.google.com/p/cefpython/source/browse/cefpython/cef3/windows/binaries_32bit/pywin32.py" rel="nofollow">PyWin32</a>. </p><p>Some use cases for CEF: <ul><li>Embed a web browser control with great HTML5 support (based on Chromium) </li><li>Use it to create a HTML5 based GUI in an application. This can act as a replacement for GUI toolkits like wxWidgets/Qt/Gtk. For native communication between javascript and python use <a href="/p/cefpython/wiki/JavascriptBindings">javascript bindings</a>. Another option is to run an internal python web server and use websockets/XMLHttpRequest for js&lt;&gt;python communication. This way you can write a desktop app in the same way you write web apps. </li><li>Render web content off-screen in applications that use custom drawing frameworks. See the <a href="/p/cefpython/wiki/Kivy">Kivy</a> and <a href="/p/cefpython/wiki/Panda3D">Panda3D</a> examples. </li><li>Use it for automated testing of existing web applications. Use it for web scraping, or as a web crawler or other kind of internet bots. </li></ul></p>

<h2><a name="Supported_Python_versions_and_platforms"></a>Supported Python versions and platforms<a href="#Supported_Python_versions_and_platforms" class="section_anchor"></a></h2>

<ul>
<li>Supported Python versions: 2.7 (Python 3.4 will be supported soon, see <a title="Support for Python 3.4"  href="/p/cefpython/issues/detail?id=121">Issue 121</a>) </li>
<li>Supported platforms: Windows, Linux, Mac (both 32bit and 64bit binaries are available for all platforms) </li>
</ul>

<h2><a name="Downloads"></a>Downloads<a href="#Downloads" class="section_anchor"></a></h2>
<ul>
<li>For Windows: see the <a href="/p/cefpython/wiki/Download_CEF3_Windows">Download_CEF3_Windows</a> wiki page. </li>
<li>For Linux: see the <a href="/p/cefpython/wiki/Download_CEF3_Linux">Download_CEF3_Linux</a> wiki page. </li>
<li>For Mac: see the <a href="/p/cefpython/wiki/Download_CEF3_Mac">Download_CEF3_Mac</a> wiki page. </li>
</ul>

<h2><a name="Help"></a>Help<a href="#Help" class="section_anchor"></a></h2>
<ul>
<li>Documentation is on the <a href="http://code.google.com/p/cefpython/w/list" rel="nofollow">wiki pages</a>. Start with the <a href="/p/cefpython/wiki/API">API</a> page. </li>
<li>Ask questions and report problems on the <a href="https://groups.google.com/group/cefpython" rel="nofollow">CEF Python Forum</a>. </li>
<li>Please do not use the <a href="http://code.google.com/p/cefpython/issues/list" rel="nofollow">Issue Tracker</a> for asking questions. </li>
<li>Instructions on how to enable Flash Player are on the <a href="/p/cefpython/wiki/Plugins">Plugins</a> wiki page. </li>
<li>Having problems with playing audio or video? See the <a href="/p/cefpython/wiki/AudioVideo">AudioVideo</a> wiki page. </li>
</ul>

<h2><a name="Watch_the_project"></a>Watch the project<a href="#Watch_the_project" class="section_anchor"></a></h2>
<ul>
<li>To watch all issues updates subscribe to the <a href="https://code.google.com/feeds/p/cefpython/issueupdates/basic"> issue updates RSS feed</a> </li>
<li>To watch Git commits subscribe to the <a href="https://code.google.com/feeds/p/cefpython/gitchanges/basic">gitchanges RSS feed</a> </li>
<li>Starring issue gets you email notifications when issue is updated </li>
<li>Join the <a href="http://groups.google.com/group/cefpython">Forum</a> and set membership settings to send Daily summaries via email </li>
</ul>

<h2><a name="Support_development"></a>Support development<a href="#Support_development" class="section_anchor"></a></h2>
<p><a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=95W9VHNSFWRUN"><img align="right" src="https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif"></img></a> If you are interested in donating time to help with the CEF Python development please see the <a href="/p/cefpython/wiki/InternalDevelopment">InternalDevelopment</a> wiki page. If you would like to support general CEF Python development efforts by making a donation please click the Paypal &quot;Donate&quot; button to the right. At this time CEF Python is unable to accept donations that sponsor the development of specific features. If you are interested in sponsorship opportunities please contact Czarek directly. </p>

<h3><a name="Thanks"></a>Thanks<a href="#Thanks" class="section_anchor"></a></h3>
<ul>
<li>Thanks to the numerous individuals that made a Paypal donation: Walter Purvis, Rokas Stupuras, Alex Rattray, Greg Kacy, Paul Korzhyk. </li>
<li>Thanks to those that have donated their time through code contributions: see the  <a href="https://code.google.com/p/cefpython/source/browse/cefpython/AUTHORS.txt">AUTHORS.txt</a> file. Patches can be attached in the issue tracker. </li>
<li><a href="http://www.cyaninc.com/"><img align="right" width="200" height="42" src="https://cefpython.googlecode.com/git/cefpython/var/cyan_new_logo.png"></img></a>Many thanks to <a href="http://www.cyaninc.com/">Cyan Inc.</a> for sponsoring this project, making CEF Python 3 more mature. Lots of new features were added, including javascript bindings and Linux support.  </li>
<li>Thanks to <a href="http://www.rentouch.ch/">Rentouch GmbH</a> for sponsoring the development of the off-screen rendering support in CEF Python 3. </li>
<li>Thanks to Thomas Wusatiuk for sponsoring the development of the web response reading features in CEF Python 3. </li>
<li>Thanks to Adam Duston for donating a Macbook to aid the development of the Mac port. </li>
</ul>

<h2><a name="Built_a_cool_app?"></a>Built a cool app?<a href="#Built_a_cool_app?" class="section_anchor"></a></h2>

<p>Built a cool app using CEF Python and would like to share info with the community? Talk about it on the <a href="https://groups.google.com/group/cefpython?hl=en" rel="nofollow">CEF Python Forum</a>. </p>

<h2><a name="Familiar_with_PHP_or_Go?"></a>Familiar with PHP or Go?<a href="#Familiar_with_PHP_or_Go?" class="section_anchor"></a></h2>

The author of CEF Python is also working on CEF bindings for other languages such as PHP and Go. For PHP take a look at the <a href="http://code.google.com/p/phpdesktop/">PHP Desktop</a> project. For Go see the <a href="https://github.com/CzarekTomczak/cef2go">CEF2go</a> project on GitHub.
