cefpython_api.h is required for cython compilation,
if you delete it, it won't compile, you will have to do
some steps to generate it again:
1. comment out #include "setup/cefpython_api.h" in ../clienthandler.h
2. run ../compile.bat
3. you will get an error of type: LoadHandler_OnLoadEnd (or other) unresolved name
4. cefpython_api.h should be generated now, edit ../clienthandler.h and add setup/cefpython_api.h to include.
5. run ../compile.bat - it should run OK now.