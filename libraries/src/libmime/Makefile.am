# Needs to be linked with GLib2.

AM_CPPFLAGS = -I. -I/usr/include -I../../../../sdk -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include `getconf LFS_CFLAGS` # -g3
AM_CFLAGS = -Wall
AM_LDFLAGS = -shared -Wl,-soname,libmime.so.1

OS_TARGET = @target_os@
CPU_TARGET = @target_cpu@

all: clean libmime

clean-local:
	rm -f *.o *.a *.so.*
	rm -rf ../../$(CPU_TARGET)-$(OS_TARGET)

SUFFIXES = .c

.c.o:
	$(CC) $(CFLAGS) $(AM_CPPFLAGS) $(AM_CFLAGS) `pkg-config glib-2.0 gio-2.0 --cflags` -c $<

libmime: mime-action.o mime-cache.o mime-type.o mime-util.o
	$(AR) rc libmime.a *.o
	mkdir -p ../../$(CPU_TARGET)-$(OS_TARGET)
	cp libmime.a ../../$(CPU_TARGET)-$(OS_TARGET)

sharedlibrary:
	$(CC) @LDFLAGS@ $(AM_LDFLAGS) -o libmime.so.1.0.1 libmime.a
	ln -s libmime.so.1 libmime.so
