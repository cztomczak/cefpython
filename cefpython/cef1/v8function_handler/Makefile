CC = g++

INC = -I$PYTHONPATH/include
INC = -I./../

CFLAGS = -Wall -g $(INC)
utilObjs = v8function_handler.o

v8function_handler.a: $(utilObjs)
	ar rc $@ $(utilObjs)
	ranlib $@

v8function_handler: v8function_handler.o v8function_handler.a
	$(CC) $(CFLAGS) v8function_handler.o -L ./ -lutil -o $@

v8function_handler.o: v8function_handler.cpp v8function_handler.h
	$(CC) $(CFLAGS) -c $<

clean:
	rm -rf *.o v8function_handler.a v8function_handler

all: v8function_handler
.PHONY: all clean