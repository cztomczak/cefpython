# -g - extra debug information
# -O1 - more precise backtraces
# -fPIC - required when using -shared option, required for use with Cython
# -Wall - show important warnings
# -Werror - treat warnings as errors

UNAME_S = $(shell uname -s)
INC = -I./../ -I./../common/ -I/usr/include/python2.7 \
	-I/usr/include/gtk-2.0 \
	-I/usr/include/gtk-unix-print-2.0 \
	-I/usr/include/glib-2.0 \
	-I/usr/include/cairo \
	-I/usr/include/pango-1.0 \
	-I/usr/include/gdk-pixbuf-2.0 \
	-I/usr/include/atk-1.0 \
	-I/usr/lib/x86_64-linux-gnu/gtk-2.0/include \
	-I/usr/lib/x86_64-linux-gnu/gtk-unix-print-2.0 \
	-I/usr/lib/x86_64-linux-gnu/glib-2.0/include \
	-I/usr/lib/i386-linux-gnu/gtk-2.0/include \
	-I/usr/lib/i386-linux-gnu/gtk-unix-print-2.0 \
	-I/usr/lib/i386-linux-gnu/glib-2.0/include \
	-I/usr/lib64/gtk-2.0/include \
	-I/usr/lib64/gtk-unix-print-2.0 \
	-I/usr/lib64/glib-2.0/include \
	-I/usr/lib/gtk-2.0/include \
	-I/usr/lib/gtk-2.0/gtk-unix-print-2.0 \
	-I/usr/lib/glib-2.0/include

ifeq ($(UNAME_S), Linux)
	LIB_DIRS = -L./../linux/binaries_64bit -L./../linux/binaries_32bit \
			   -L./../linux/setup/lib_64bit -L./../linux/setup/lib_32bit
else ifeq ($(UNAME_S), Darwin)
	LIB_DIRS = -L./../mac/binaries_64bit/ -L./../mac/binaries_32bit/ \
			   -L./../mac/setup/lib_64bit -L./../mac/setup/lib_32bit
endif

ifeq ($(UNAME_S), Linux)
	CPP_FILES = print_handler_gtk.cpp
	LIBS = -lgobject-2.0 -lglib-2.0 -lgtk-x11-2.0
else
	CPP_FILES =
	LIBS =
endif

CCFLAGS = -g -std=gnu++11 -Wall -Werror -DRENDERER_PROCESS $(CEF_CCFLAGS)


subprocess:
	# -fPIC is required only for libraries included by Cython.
	@echo [SUBPROCESS] Building the 'subprocess' executable
	g++ $(CCFLAGS) $(INC) $(LIB_DIRS) main.cpp cefpython_app.cpp \
		v8function_handler.cpp v8utils.cpp javascript_callback.cpp \
		$(CPP_FILES) \
		$(LIBS) -lcef -lcef_dll_wrapper -o subprocess -Wl,-rpath,.
