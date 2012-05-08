from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [Extension(
	"cefapi",
	["cefapi.pyx"],
	language='c++',
	include_dirs=[r'./../'],
	library_dirs=[r'./', 'd:/winsdk7/Lib/'],
	libraries=['libcef', 'libcef_dll_wrapper', 'User32'],
	extra_compile_args=['/EHsc'],
	extra_link_args=['/NODEFAULTLIB:libcmt']
	#extra_link_args=['/NODEFAULTLIB:msvcrt', '/NODEFAULTLIB:msvcprt']
)]

setup(
	name = 'cefapi',
	cmdclass = {'build_ext': build_ext},
	ext_modules = ext_modules
)