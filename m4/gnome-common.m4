# gnome-common.m4
#
# serial 3
# 

dnl# GNOME_COMMON_INIT

AU_DEFUN([GNOME_COMMON_INIT],
[
  dnl# this macro should come after AC_CONFIG_MACRO_DIR
  AC_BEFORE([AC_CONFIG_MACRO_DIR], [$0])

  dnl# ensure that when the Automake generated makefile calls aclocal,
  dnl# it honours the $ACLOCAL_FLAGS environment variable
  ACLOCAL_AMFLAGS="\${ACLOCAL_FLAGS}"
  if test -n "$ac_macro_dir"; then
    ACLOCAL_AMFLAGS="-I $ac_macro_dir $ACLOCAL_AMFLAGS"
  fi

  AC_SUBST([ACLOCAL_AMFLAGS])
],
[[$0: This macro is deprecated. You should set put "ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}"
in your top-level Makefile.am, instead, where "m4" is the macro directory set
with AC_CONFIG_MACRO_DIR() in your configure.ac]])

AC_DEFUN([GNOME_DEBUG_CHECK],
[
	AC_ARG_ENABLE([debug],
                      [AC_HELP_STRING([--enable-debug],
                                     [turn on debugging])],[],
                      [enable_debug=no])

	if test x$enable_debug = xyes ; then
	    AC_DEFINE([GNOME_ENABLE_DEBUG], [1],
		[Enable additional debugging at the expense of performance and size])
	fi
])

dnl# GNOME_MAINTAINER_MODE_DEFINES ()
dnl# define DISABLE_DEPRECATED
dnl#
AC_DEFUN([GNOME_MAINTAINER_MODE_DEFINES],
[
	AC_REQUIRE([AM_MAINTAINER_MODE])

	DISABLE_DEPRECATED=""
	if test $USE_MAINTAINER_MODE = yes; then
	        DOMAINS="GCONF BONOBO BONOBO_UI GNOME LIBGLADE GNOME_VFS WNCK LIBSOUP"
	        for DOMAIN in $DOMAINS; do
	               DISABLE_DEPRECATED="$DISABLE_DEPRECATED -D${DOMAIN}_DISABLE_DEPRECATED -D${DOMAIN}_DISABLE_SINGLE_INCLUDES"
	        done
	fi

	AC_SUBST([DISABLE_DEPRECATED])
])
