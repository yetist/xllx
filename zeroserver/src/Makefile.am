bin_PROGRAMS = htpcos

LIBS	= -lev -lpthread -lxllx

htpcos_CFLAGS = -I/usr/include/xllx

htpcos_SOURCES = 	\
	htpcos_server.c \
	zero_server.c \
	zero_thread.c \
	zero_queue.c \
	message.c	\
	debug.c

noinst_HEADERS =    \
	zero_server.h \
	zero_common.h \
	zero_queue.h  \
	zero_thread.h



#EXTRA_DIST = README.html README-WIN32.html

-include $(top_srcdir)/git.mk

