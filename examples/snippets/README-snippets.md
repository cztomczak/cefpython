# Snippets README

Table of contents:
* [Hello World!](#hello-world)
* [Snippets](#snippets)


## Hello World!

Instructions to install the cefpython3 package, clone
the repository and run the `javascript_bindings.py` snippet:

```
pip install cefpython3==66.0
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/examples/snippets/
python javascript_bindings.py
```


## Snippets

Below are small code snippets that show various CEF features and
are easy to understand. These are available in the [examples/snippets/](./)
directory. If looking for non-trivial examples then see the
[README-examples.md](../README-examples.md) document.


- [cookies.py](cookies.py) - Shows how to fetch all cookies,
    all cookies for a given url and how to delete a specific cookie.
- [javascript_bindings.py](javascript_bindings.py) - Communicate
    between Python and Javascript asynchronously using
    inter-process messaging with the use of Javascript Bindings.
- [javascript_errors.py](javascript_errors.py) - Two ways for
    intercepting Javascript errors.
- [mouse_clicks.py](mouse_clicks.py) - Perform mouse clicks
    and mouse movements programmatically.
- [network_cookies.py](network_cookies.py) - Implement
    interfaces to block or allow cookies over network requests.
- [onbeforeclose.py](onbeforeclose.py) - Implement interface
    to execute custom code before browser window closes.
- [ondomready.py](ondomready.py) - Execute custom Python code
    on a web page as soon as DOM is ready.
- [onpagecomplete.py](onpagecomplete.py) - Execute custom
    Python code on a web page when page loading is complete.
- [setcookie.py](setcookie.py) - Shows how to set a cookie
- [window_size.py](window_size.py) - Set initial window size
    without use of any third party GUI framework.
