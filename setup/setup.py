from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [Extension(
	"cefpython",
	["cefpython.pyx"],
	language='c++',
	include_dirs=[r'./../cefexample/'],
	library_dirs=[r'./', '"c:/Program Files/Microsoft SDKs/Windows/v7.1/Lib/'],
	libraries=['libcef', 'libcef_dll_wrapper', 'User32'],
	extra_compile_args=['/EHsc'],
	extra_link_args=['/NODEFAULTLIB:libcmt']
	#extra_link_args=['/NODEFAULTLIB:msvcrt', '/NODEFAULTLIB:msvcprt']
)]

setup(
	name = 'cefpython',
	cmdclass = {'build_ext': build_ext},
	ext_modules = ext_modules
)