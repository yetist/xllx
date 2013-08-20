bin_PROGRAMS = xllx-server

LIBS	= -lev -lpthread -lxllx

xllx_server_CFLAGS = -I/usr/include/xllx

xllx_server_SOURCES = 	\
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

