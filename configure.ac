#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.57])

m4_define([xllx_major_version], [13])
m4_define([xllx_minor_version], [8])
m4_define([xllx_micro_version], [2])
m4_define([xllx_interface_age], [1])
m4_define([xllx_binary_age], [m4_eval(100 * xllx_minor_version + xllx_micro_version)])
m4_define([xllx_version], xllx_major_version.xllx_minor_version.xllx_micro_version)
m4_define([xllx_lt_release], [xllx_major_version.xllx_minor_version])
m4_define([xllx_lt_current], [m4_eval(100 * xllx_minor_version + xllx_micro_version - xllx_interface_age)])
m4_define([xllx_lt_revision], [xllx_interface_age])
m4_define([xllx_lt_age], [m4_eval(xllx_binary_age - xllx_interface_age)])

AC_INIT([xllx], [xllx_version], [http://bugs.htpcos.org])
AC_CONFIG_SRCDIR([lib/xl-client.c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AC_DEFINE(XLLX_MAJOR_VERSION, xllx_major_version, [Mimgr major version])
AC_SUBST(XLLX_MAJOR_VERSION, xllx_major_version)
AC_DEFINE(XLLX_MINOR_VERSION, xllx_minor_version, [Mimgr minor version])
AC_SUBST(XLLX_MINOR_VERSION, xllx_minor_version)
AC_DEFINE(XLLX_MICRO_VERSION, xllx_micro_version, [Mimgr micro version])
AC_SUBST(XLLX_MICRO_VERSION, xllx_micro_version)
AC_DEFINE(XLLX_API_VERSION, xllx_interface_age, [Mimgr api version])
AC_DEFINE(API_VERSION, ["xllx_interface_age"], [Mimgr api version])
AC_SUBST(API_VERSION, ["xllx_interface_age"])

AM_INIT_AUTOMAKE([1.11 tar-ustar dist-xz no-dist-gzip -Wno-portability])
AM_MAINTAINER_MODE([enable])

AM_SILENT_RULES([yes])
CFLAGS="-Wall"

# libtool versioning
LT_RELEASE=xllx_lt_release
LT_CURRENT=xllx_lt_current
LT_REVISION=xllx_lt_revision
LT_AGE=xllx_lt_age
LT_CURRENT_MINUS_AGE=xllx_lt_current_minus_age
AC_SUBST(LT_RELEASE)
AC_SUBST(LT_CURRENT)
AC_SUBST(LT_REVISION)
AC_SUBST(LT_AGE)
AC_SUBST(LT_CURRENT_MINUS_AGE)

# Checks for programs.
AC_PROG_CC
AM_PROG_LIBTOOL
PKG_PROG_PKG_CONFIG
AC_SUBST(ACLOCAL_AMFLAGS, "$ACLOCAL_FLAGS -I m4")

# Initialize libtool
LT_PREREQ([2.2.6])
LT_INIT(disable-static)

# Checks for library functions.
AC_CHECK_FUNCS([strdup])

# Checks for header files.
AC_HEADER_STDC
AC_FUNC_ALLOCA
AC_CHECK_HEADERS([fcntl.h memory.h netdb.h netinet/in.h stdint.h stdlib.h string.h sys/socket.h sys/time.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_INT64_T
AC_TYPE_SIZE_T
AC_TYPE_UINT64_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_MKTIME
AC_FUNC_REALLOC
AC_CHECK_FUNCS([gethostbyname gettimeofday memmove memset socket strcasecmp strchr strdup strerror strndup strstr strtol])

dnl *********************
dnl *** debug options ***
dnl *********************
enable_debug="yes"
AC_ARG_ENABLE([debug],
	AS_HELP_STRING([--disable-debug],[Disable debug(default: enabled)]),
	[enable_debug=$enableval],
	[enable_debug=yes])

AM_CONDITIONAL(ENABLE_DEBUG, test x"$enable_debug" = "xyes")

dnl *********************
dnl *** JSON checks ***
dnl *********************
JSON_REQUIRED_VERSION=0.11
PKG_CHECK_MODULES(JSON, json >= $JSON_REQUIRED_VERSION)
AC_SUBST(JSON_CFLAGS)
AC_SUBST(JSON_LIBS)

dnl *************************
dnl *** libev     checks ***
dnl *************************
AC_CHECK_LIB(ev, ev_run, [AC_CHECK_HEADER(ev.h, found_ev=yes)], found_ev=no)
if test "x$found_ev" = "xno" ; then
	AC_MSG_ERROR([*** Working libev not found ***])
fi
EV_LIBS='-lev'
AC_SUBST(EV_LIBS)

# checks for zlib
PKG_CHECK_MODULES(ZLIB, [zlib >= 1.2], [AC_DEFINE(USE_ZLIB, 1, [Use ZLIB])])
AC_SUBST(ZLIB_CFLAGS)
AC_SUBST(ZLIB_LIBS)


AC_CONFIG_FILES([
Makefile
lib/xllx.h
lib/Makefile
lib/libghttp/Makefile
])

AC_OUTPUT
