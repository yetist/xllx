GHTTP_CFLAGS = -I$(top_srcdir)/lib/libghttp
GHTTP_LIBS = $(top_builddir)/lib/libghttp/libghttp.la

if ENABLE_DEBUG
DEBUG_FLAGS = 
else
DEBUG_FLAGS = -DNDEBUG
endif

SUBDIRS = libghttp
DIST_SUBDIRS = libghttp

lib_LTLIBRARIES = libxllx.la

libxllx_la_SOURCES = 	\
	xl-http.c 	\
	xl-client.c 	\
	xl-cookies.c 	\
	xl-url.c 	\
	xl-utils.c 	\
	xl-vod.c	\
	xl-json.c	\
	xl-videos.c	\
	smemory.c 	\
	md5.c 	\
	base64.c	\
	logger.c 

libxllx_la_CFLAGS =	\
	$(DEBUG_FLAGS) \
	$(ZLIB_FLAGS) \
	$(GHTTP_CFLAGS)\
	$(JSON_CFLAGS)

libxllx_la_LIBADD =	\
	$(GHTTP_LIBS)	\
	$(ZLIB_LIBS) \
	$(EV_LIBS) \
	$(JSON_LIBS)

libxllx_la_LDFLAGS = -export-dynamic -no-undefined -export-symbols-regex ".*" \
	-version-info $(LT_CURRENT):$(LT_REVISION):$(LT_AGE)

#noinst_HEADERS =
noinst_PROGRAMS = testxl
testxl_SOURCES = main.c
testxl_CFLAGS = -I$(top_srcdir)/lib $(GHTTP_CFLAGS)  $(JSON_CFLAGS)
testxl_LDADD = $(lib_LTLIBRARIES) $(GHTTP_LIBS) $(ZLIB_LIBS) $(GHTTP_LIBS) -lpthread $(JSON_LIBS)

header_DATA = xllx.h xl-http.h xl-client.h xl-cookies.h xl-vod.h xl-errors.h
headerdir = $(includedir)

-include $(top_srcdir)/git.mk
