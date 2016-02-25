Patch to Chromium. Fixes HTTPS cache problems on sites with certificate errors:
https://github.com/cztomczak/cefpython/issues/125

Apply the patch in the "chromium/src/" directory.
It modifies WriteResponseInfoToEntry().
