#GHTTP_CFLAGS = -I$(top_srcdir)/lib/libghttp
#GHTTP_LIBS = $(top_builddir)/lib/libghttp/libghttp.la

if ENABLE_DEBUG
DEBUG_FLAGS = 
else
DEBUG_FLAGS = -DNDEBUG
endif

XLLX_C_FILES = 		\
	xl-client.c 	\
	xl-http.c 	\
	xl-json.c	\
	xl-url.c 	\
	xl-utils.c 	\
	xl-videos.c	\
	xl-vod.c	\
	base64.c	\
	logger.c 	\
	md5.c 		\
	smemory.c 

INST_H_FILES = 		\
	xllx.h		\
	xl-client.h	\
	xl-errors.h	\
	xl-videos.h	\
	xl-http.h	\
   	xl-url.h	\
   	xl-vod.h

NOINST_H_FILES =	\
	xl-http.h	\
	xl-json.h	\
	xl-utils.h	\
	base64.h	\
	list_head.h	\
	logger.h	\
	md5.h		\
	smemory.h


lib_LTLIBRARIES = libxllx.la

libxllx_la_SOURCES = 	\
	$(XLLX_C_FILES)	\
	$(INST_H_FILES)	\
	$(NOINST_H_FILES)

libxllx_la_CFLAGS =	\
	$(DEBUG_FLAGS) \
	$(ZLIB_FLAGS) \
	$(JSON_CFLAGS)

libxllx_la_LIBADD =	\
	$(ZLIB_LIBS) \
	-lcurl \
	$(JSON_LIBS)

libxllx_la_LDFLAGS = -export-dynamic -no-undefined -export-symbols-regex ".*" \
	-version-info $(LT_CURRENT):$(LT_REVISION):$(LT_AGE)

header_DATA = $(INST_H_FILES)
headerdir = $(includedir)/xllx

EXTRA_DIST =	\
		$(noinst_HEADERS)

-include $(top_srcdir)/git.mk
