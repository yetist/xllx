GHTTP_CFLAGS = -I$(top_srcdir)/lib/libghttp
GHTTP_LIBS = $(top_builddir)/lib/libghttp/libghttp.la
XLLX_LIBS = $(top_builddir)/lib/libxllx.la

noinst_PROGRAMS = tests
tests_SOURCES = main.c
tests_CFLAGS = -I$(top_srcdir)/lib $(GHTTP_CFLAGS)  $(JSON_CFLAGS)
tests_LDADD = $(XLLX_LIBS) $(GHTTP_LIBS) $(ZLIB_LIBS) $(GHTTP_LIBS) -lpthread $(JSON_LIBS)
