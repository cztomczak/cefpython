REM CTags provides code completion, finding definition/use of an identifier,
REM it supports 41 languages including Cython, see: http://ctags.sourceforge.net/
REM Many editors are supported, see http://ctags.sourceforge.net/tools.html ,
REM though there are much more, but unlisted there.

REM kinds: p = function prototypes [off by default]
REM --c++-kinds=+p

call C:\ctags58\ctags.exe -R --c++-kinds=+p --exclude=setup --exclude=cefpython_py27.py --exclude=cefpython_py32.py -f ctags
pause