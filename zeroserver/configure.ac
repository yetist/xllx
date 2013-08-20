#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.57])

	m4_define([xllx-server_major_version], [13])
	m4_define([xllx-server_minor_version], [7])
	m4_define([xllx-server_micro_version], [12])
	m4_define([xllx-server_interface_age], [1])
	m4_define([xllx-server_binary_age], [m4_eval(100 * xllx-server_minor_version + xllx-server_micro_version)])
	m4_define([xllx-server_version], xllx-server_major_version.xllx-server_minor_version.xllx-server_micro_version)
	m4_define([xllx-server_lt_release], [xllx-server_major_version.xllx-server_minor_version])
	m4_define([xllx-server_lt_current], [m4_eval(100 * xllx-server_minor_version + xllx-server_micro_version - xllx-server_interface_age)])
	m4_define([xllx-server_lt_revision], [xllx-server_interface_age])
m4_define([xllx-server_lt_age], [m4_eval(xllx-server_binary_age - xllx-server_interface_age)])

	AC_INIT([xllx-server], [xllx-server_version], [http://bugs.xllx-server.org])
#AC_CONFIG_SRCDIR([lib/xllx-server.c])
	AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

	AC_DEFINE(MIMGR_MAJOR_VERSION, xllx-server_major_version, [Mimgr major version])
	AC_SUBST(MIMGR_MAJOR_VERSION, xllx-server_major_version)
	AC_DEFINE(MIMGR_MINOR_VERSION, xllx-server_minor_version, [Mimgr minor version])
	AC_SUBST(MIMGR_MINOR_VERSION, xllx-server_minor_version)
	AC_DEFINE(MIMGR_MICRO_VERSION, xllx-server_micro_version, [Mimgr micro version])
	AC_SUBST(MIMGR_MICRO_VERSION, xllx-server_micro_version)
AC_DEFINE(MIMGR_API_VERSION, xllx-server_interface_age, [Mimgr api version])
	AC_DEFINE(API_VERSION, ["xllx-server_interface_age"], [Mimgr api version])
	AC_SUBST(API_VERSION, ["xllx-server_interface_age"])

	AM_INIT_AUTOMAKE([1.11 tar-ustar dist-xz no-dist-gzip -Wno-portability])
AM_MAINTAINER_MODE([enable])

AM_SILENT_RULES([yes])

# libtool versioning
	LT_RELEASE=xllx-server_lt_release
	LT_CURRENT=xllx-server_lt_current
	LT_REVISION=xllx-server_lt_revision
	LT_AGE=xllx-server_lt_age
	LT_CURRENT_MINUS_AGE=xllx-server_lt_current_minus_age
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

# Checks for libraries.

# Checks for header files.
	AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_FUNCS([strdup])

#MIMGR_PLUGINS_LIBS_DIR="$libdir/xllx-server/addons"
#AC_SUBST(MIMGR_PLUGINS_LIBS_DIR)

dnl *********************
dnl *** JSON checks ***
dnl *********************
JSON_REQUIRED_VERSION=0.9
PKG_CHECK_MODULES(JSON, json >= $JSON_REQUIRED_VERSION)
AC_SUBST(JSON_CFLAGS)
AC_SUBST(JSON_LIBS)

AC_CONFIG_FILES([
Makefile
src/Makefile
])

AC_OUTPUT
