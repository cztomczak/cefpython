# -g - extra debug information
# -O1 - more precise backtraces
# -fPIC - required when using -shared option

INC = -I./../ -I/usr/include/python2.7 -I/usr/include/gtk-2.0 -I/usr/include/glib-2.0 -I/usr/lib/i386-linux-gnu/gtk-2.0/include -I/usr/lib/i386-linux-gnu/glib-2.0/include -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/atk-1.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/lib/x86_64-linux-gnu/gtk-2.0/include

LIB = -L./../linux/setup/lib_64bit -L./../linux/setup/lib_32bit

subprocess:
	# Cython compiler options:
	# -shared -Wl,-O1 -Wl,-Bsymbolic-functions -Wl,-Bsymbolic-functions -Wl,-z,relro
	g++ -fPIC $(INC) $(LIB) main.cpp -lcef_dll_wrapper -lcef -o subprocess -Wl,-rpath,.
