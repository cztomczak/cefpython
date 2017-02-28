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
	-I/usr/lib/arm-linux-gnueabihf/gtk-2.0/include \
	-I/usr/lib/arm-linux-gnueabihf/gtk-unix-print-2.0 \
	-I/usr/lib/arm-linux-gnueabihf/glib-2.0/include \
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
	LIB_DIRS = -L./../../build/cef_linux64/bin \
			   -L./../../build/cef_linux32/bin \
			   -L./../../build/cef_linuxarm/bin \
			   -L./../../build/cef_linux64/lib \
			   -L./../../build/cef_linux32/lib \
			   -L./../../build/cef_linuxarm/lib
else ifeq ($(UNAME_S), Darwin)
	LIB_DIRS = -F$(CEF_BIN) \
			   -L$(CEF_LIB)
endif

ifeq ($(UNAME_S), Linux)
	CPP_FILES = print_handler_gtk.cpp
	LIBS = -lcef -lgobject-2.0 -lglib-2.0 -lgtk-x11-2.0
else ifeq ($(UNAME_S), Darwin)
	CPP_FILES =
	LIBS = -framework Chromium\ Embedded\ Framework
endif


CCFLAGS = -g -std=c++11 -Wall -Werror -DRENDERER_PROCESS $(CEF_CCFLAGS)

ifeq ($(UNAME_S), Darwin)
    MACFLAGS = -O3 -DNDEBUG -stdlib=libstdc++ \
				-Wl,-search_paths_first -Wl,-ObjC -Wl,-pie -Wl,-dead_strip
else
    MACFLAGS =
endif


subprocess:
	# -fPIC is required only for libraries included by Cython.
	@echo [SUBPROCESS] Building the 'subprocess' executable
	g++ $(CCFLAGS) $(MACFLAGS) $(INC) $(LIB_DIRS) main.cpp cefpython_app.cpp \
		v8function_handler.cpp v8utils.cpp javascript_callback.cpp \
		$(CPP_FILES) \
		$(LIBS) -lcef_dll_wrapper -o subprocess -Wl,-rpath,.
