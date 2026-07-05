# coding=utf8
from cefpython3 import cefpython as cef
import sys

html = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<script>
  window.onload = function() {
   fetch('http://127.0.0.1:8000', {
       method: 'POST',
       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
       body: 'key=' + encodeURI('🍣 asd'),
   }).then().catch();
  }
</script>
</body>
</html>
"""


class RequestHandler:
    def GetResourceHandler(self, browser, frame, request):
        print(request.GetPostData())
        return None

def main():
    sys.excepthook = cef.ExceptHook
    cef.Initialize()
    browser = cef.CreateBrowserSync(url=cef.GetDataUrl(html))
    browser.SetClientHandler(RequestHandler())
    cef.MessageLoop()
    del browser
    cef.Shutdown()


if __name__ == '__main__':
    main()
