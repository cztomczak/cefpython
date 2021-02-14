CCFLAGS = -fPIC $(CEF_CCFLAGS)

SRC = PaintBuffer.cpp
OBJ = $(SRC:.cpp=.o)
OUT = libcpp_utils.a

INC = -I./../ -I/usr/include/gtk-2.0 \
	-I/usr/include/glib-2.0 -I/usr/lib/i386-linux-gnu/gtk-2.0/include \
	-I/usr/lib/i386-linux-gnu/glib-2.0/include -I/usr/include/cairo \
	-I/usr/include/pango-1.0 -I/usr/include/harfbuzz -I/usr/include/gdk-pixbuf-2.0 \
	-I/usr/include/atk-1.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include \
	-I/usr/lib/x86_64-linux-gnu/gtk-2.0/include \
	-I/usr/lib64/glib-2.0/include -I/usr/lib64/gtk-2.0/include \
	-I/usr/lib/glib-2.0/include -I/usr/lib/gtk-2.0/include

.cpp.o:
	$(CXX) $(INC) $(CCFLAGS) -c $< -o $@

$(OUT): $(OBJ)
	ar rcs $(OUT) $(OBJ)
