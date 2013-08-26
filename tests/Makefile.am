XLLX_LIBS = $(top_builddir)/lib/libxllx.la

noinst_PROGRAMS = tests
tests_SOURCES = main.c
tests_CFLAGS = -I$(top_srcdir)/lib $(JSON_CFLAGS)
tests_LDADD = $(XLLX_LIBS) $(ZLIB_LIBS) $(GHTTP_LIBS) -lpthread $(JSON_LIBS) -lcurl
