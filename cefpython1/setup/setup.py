from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import sys

ext_modules = [Extension(
	"cefpython",
	["cefpython.pyx"],
	language='c++',
	include_dirs=[r'./../', r'./../pyinclude/'],
	library_dirs=[
		r'./',
		r"c:/Program Files (x86)/Windows Kits/8.0/Lib/win8/um/x86/",
		r'./../httpauth/Release/',
		r'./../v8functionhandler/Release/',
		r'./../clienthandler/Release_py%s%s/' % (sys.version_info.major, sys.version_info.minor)
	],
	libraries=[
		'libcef',
		'libcef_dll_wrapper',
		'User32',
		'httpauth',
		'v8functionhandler',
		'clienthandler_py%s%s' % (sys.version_info.major, sys.version_info.minor)
	],
	# To get rid of errors there are 2 options:
	# 1) compile '/clr' + link '/NODEFAULTLIB:libcmt', '/NODEFAULTLIB:msvcprt' (CLR will probably require .NET framework? YES)
	# 2) compile '/EHsc' + link '/NODEFAULTLIB:libcmt', '/NODEFAULTLIB:msvcprt'], '/ignore:4217'
	extra_compile_args=['/EHsc'], # '/EHsc', '/clr'
	# extra_objects=[],
	extra_link_args=['/NODEFAULTLIB:libcmt', '/NODEFAULTLIB:msvcprt', '/ignore:4217'] # '/ignore:4217'
	#extra_link_args=['/NODEFAULTLIB:libcmt', '/NODEFAULTLIB:libcpmt', '/NODEFAULTLIB:msvcrt', '/NODEFAULTLIB:msvcprt']	

	# /ignore:4049 - DialogTemplate.cpp includes <string> and linker generates warnings:
	#>Creating library build\temp.win32-2.7\Release\cefpython.lib and object build\temp.win32-2.7\Release\cefpython.exp
	#>DialogTemplate.obj : warning LNK4049: locally defined symbol ??0?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@
	#>std@@QAE@ABV01@@Z (public: __thiscall std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> >:
	#>:basic_string<char,struct std::char_traits<char>,class std::allocator<char> >(class std::basic_string<char,struct std::c
	#>har_traits<char>,class std::allocator<char> > const &)) imported

	# libcmt - C, libcpmt - C++ (CP = C Plus)
	# libcef_dll_wrapper.lib directives: libcmt, libcpmt, oldnames.

	# When compiling with /clr Dependency Walker shows "mscoree.dll" dependency, and this file is:
	# "Microsoft .NET Runtime Execution Engine".

	# '/NODEFAULTLIB:libcmt' - otherwise errors "LIBCMT.lib... already defined in MSVCRT.lib(MSVCR90.dll)"
	# - that is because libcef_dll_wrapper is compiled statically /MT and includes LIBCMT.lib and PYD file is compiled
	#	using /MD and includes MSVCRT.lib, both of these .lib cannot be used at the same time as there are conflicts.
	
	# '/NODEFAULTLIB:msvcprt' - otherwise errors "msvcprt.lib(MSVCP90.dll)... basic_string already defined in libcef_dll_wrapper.lib"	
	# - msvcprt.lib (msvcp90.dll) is a Standard C++ Library and was already included in libcef_dll_wrapper.
	
	# libcmt.lib - multithreaded, static link
	# msvcrt.lib - multithreaded, dynamic link
	# msvcmrt.lib - runtime for managed code
	# msvcprt.lib - standard c++ library for runtime

	# msvcm90.dll - Runtime for managed code, when using /clr option
	# msvcp90.dll - Applications that use the Standard C++ Library.
)]

setup(
	name = 'cefpython',
	cmdclass = {'build_ext': build_ext},
	ext_modules = ext_modules
)