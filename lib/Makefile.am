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
	http.c 	\
	smemory.c 	\
	client.c 	\
	md5.c 	\
	url.c 	\
	logger.c 

libxllx_la_CFLAGS =	\
	$(DEBUG_FLAGS) \
	$(ZLIB_FLAGS) \
	$(GHTTP_CFLAGS)

libxllx_la_LIBADD =	\
	$(GHTTP_LIBS)	\
	$(ZLIB_LIBS) \
	$(EV_LIBS)

libxllx_la_LDFLAGS = -export-dynamic -no-undefined -export-symbols-regex ".*" \
	-version-info $(LT_CURRENT):$(LT_REVISION):$(LT_AGE)

#noinst_HEADERS =
noinst_PROGRAMS = testxl
testxl_SOURCES = main.c
testxl_CFLAGS = -I$(top_srcdir)/lib $(GHTTP_CFLAGS)
testxl_LDADD = $(lib_LTLIBRARIES) $(GHTTP_LIBS) $(ZLIB_LIBS) $(GHTTP_LIBS) -lpthread

header_DATA = xllx.h
headerdir = $(includedir)

-include $(top_srcdir)/git.mk
