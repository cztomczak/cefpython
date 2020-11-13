# -g - extra debug information
# -O1 - more precise backtraces
# -fPIC - required when using -shared option, required for use with Cython
# -Wall - show important warnings
# -Werror - treat warnings as errors

UNAME_S = $(shell uname -s)
INC = -I./../ -I./../common/ -I$(PYTHON_INCLUDE) \
	-I/usr/include/gtk-2.0 \
	-I/usr/include/gtk-unix-print-2.0 \
	-I/usr/include/glib-2.0 \
	-I/usr/include/cairo \
	-I/usr/include/pango-1.0 \
	-I/usr/include/harfbuzz \
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
	LIB_DIRS = -L$(CEF_BIN) \
							-L$(CEF_LIB)
else ifeq ($(UNAME_S), Darwin)
	LIB_DIRS = -F$(CEF_BIN) \
							-L$(CEF_LIB)
endif

ifeq ($(UNAME_S), Linux)
	CPP_FILES = print_handler_gtk.cpp ../client_handler/x11.cpp
	LIBS = -lcef -lX11 -lgobject-2.0 -lglib-2.0 -lgtk-x11-2.0 -lgdk-x11-2.0
else ifeq ($(UNAME_S), Darwin)
	CPP_FILES =
	# Include framework before libcef_dll_wrapper
	LIBS = -framework "Chromium Embedded Framework"
endif

CCFLAGS = -DRENDERER_PROCESS $(CEF_CCFLAGS)

subprocess:
	# -fPIC is required only for libraries included by Cython.
	@echo [SUBPROCESS] Building the 'subprocess' executable
	$(CXX) $(CCFLAGS) $(INC) $(LIB_DIRS) main.cpp cefpython_app.cpp \
		v8function_handler.cpp v8utils.cpp javascript_callback.cpp \
		$(CPP_FILES) \
		$(CEF_LINK_FLAGS) \
		$(LIBS) -lcef_dll_wrapper \
		-o subprocess -Wl,-rpath,@loader_path/
