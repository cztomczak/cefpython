# -g - extra debug information
# -O1 - more precise backtraces
# -fPIC - required when using -shared option, required for use with Cython
# -Wall - show important warnings
# -Werror - treat warnings as errors

# Cython compiler options:
# -fPIC -shared -Wl,-O1 -Wl,-Bsymbolic-functions -Wl,-Bsymbolic-functions \
# 	-Wl,-z,relro

UNAME_S = $(shell uname -s)

CC = g++
CCFLAGS = -g -fPIC -Wall -Werror $(CEF_CCFLAGS)

SRC = client_handler.cpp cookie_visitor.cpp resource_handler.cpp \
		web_request_client.cpp string_visitor.cpp request_context_handler.cpp \
		task.cpp

OBJ = $(SRC:.cpp=.o)

ifeq ($(UNAME_S), Darwin)
	OBJ += util_mac.o
endif

OUT = libclient_handler.a

INC = -I./../ -I/usr/include/python2.7 -I/usr/include/gtk-2.0 \
	-I/usr/include/glib-2.0 -I/usr/lib/i386-linux-gnu/gtk-2.0/include \
	-I/usr/lib/i386-linux-gnu/glib-2.0/include -I/usr/include/cairo \
	-I/usr/include/pango-1.0 -I/usr/include/gdk-pixbuf-2.0 \
	-I/usr/include/atk-1.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include \
	-I/usr/lib/x86_64-linux-gnu/gtk-2.0/include \
	-I/usr/lib64/glib-2.0/include -I/usr/lib64/gtk-2.0/include \
	-I/usr/lib/glib-2.0/include -I/usr/lib/gtk-2.0/include

.cpp.o:
	@echo [Makefile] Building $@ from $<...
	$(CC) $(CCFLAGS) $(INC) -c $< -o $@

$(OUT): $(OBJ)
	@echo [Makefile] Creating library $(OUT) from $(OBJ)...
	ar rcs $(OUT) $(OBJ)

util_mac.o: util_mac.mm
	@echo [Makefile] Building $@ from $<...
	$(CC) $(CCFLAGS) $(INC) -c $< -o $@

clean:
	rm *.o *.a
