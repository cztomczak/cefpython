Patch to fix HTTPS cache problems on pages with certificate errors:
https://github.com/cztomczak/cefpython/issues/125

Apply the patch in the "chromium/src/" directory.
Modifications are made to the HttpCache::Transaction::
WriteResponseInfoToEntry function.
