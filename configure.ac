dnl#                                               -*- Autoconf -*-
dnl# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([doublecmd],[0.5.6],[doublecmd-devel@lists.sourceforge.net])
AC_CONFIG_SRCDIR([libraries/src/libmime/glib-mem.h])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AC_CANONICAL_TARGET
AM_INIT_AUTOMAKE([foreign -Wall])
dnl# This next one also calls the normal maintainer mode macro:
GNOME_MAINTAINER_MODE_DEFINES
AC_OBJEXT
AC_EXEEXT

# Checks for programs.
AC_USE_SYSTEM_EXTENSIONS
AM_PROG_AR
AC_LANG([C])dnl# "Pascal" is not accepted as an argument to this...
AC_PROG_CPP
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MKDIR_P
AC_PROG_RANLIB
AC_PROG_YACC
AX_CHECK_GNU_MAKE
AC_PATH_PROG([FPC],[fpc],[fpc])
AC_PATH_PROG([LAZBUILD],[lazbuild],[lazbuild])dnl

# Checks for libraries.
AM_PATH_GLIB
AM_PATH_GLIB_2_0([2.16.0],[],[],[gio])dnl# gio is for the gvfs plugin
gl_FCNTL_O_FLAGS

dnl# gettext gets its own special section:
export GETTEXT_PACKAGE=doublecmd
export copyright_holder="The doublecmd project"
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE],["${GETTEXT_PACKAGE}"],
                   [Define to the gettext package name])dnl
AC_SUBST([GETTEXT_PACKAGE])dnl
AC_SUBST([copyright_holder])dnl
dnl# (no actual translations yet)
export ALL_LINGUAS=""
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.21.1])
AM_GLIB_GNU_GETTEXT
AC_SUBST([POMAKEFILEDEPS])dnl

# Checks for header files.
AC_DEFUN([AC_REQUIRE_HEADER_STDC],[
  AC_REQUIRE([AC_HEADER_STDC])dnl
])dnl
AC_REQUIRE_HEADER_STDC
AC_HEADER_STDBOOL dnl# also "_CHECK"s it
AC_CHECK_HEADERS([fcntl.h float.h glib.h glib/glib.h langinfo.h \
                  malloc.h malloc/malloc.h stdio.h stdio_ext.h \
                  wchar.h wfxplugin.h xsize.h])dnl
dnl# keep autoscan happy:
if test "x${ac_cv_header_libintl_h}" = "x"; then
  test -z "${ac_cv_header_libintl_h}"
  AC_CHECK_HEADERS([libintl.h])
fi
if test "x${ac_cv_header_stdint_h}" = "x"; then
  test -z "${ac_cv_header_stdint_h}"
  AC_CHECK_HEADERS([stdint.h])
fi
if test "x${ac_cv_header_unistd_h}" = "x"; then
  test -z "${ac_cv_header_unistd_h}"
  AC_CHECK_HEADERS([unistd.h])
fi
dnl# gvfs-specific ones:
AC_CHECK_HEADERS([gvfs-client/gvfs/gvfsurimapper.h gvfs/gvfsurimapper.h \
                  gvfsurimapper.h gvfs-client/gvfs/gvfsuriutils.h \
                  gvfs/gvfsuriutils.h gvfsuriutils.h \
                  libgnomevfs/gnome-vfs.h gnome-vfs.h])dnl

# Checks for typedefs, structures, and compiler characteristics.
AC_C_BIGENDIAN
AC_C_CONST
AC_C_INLINE
AC_C_PROTOTYPES
AC_TYPE_SIZE_T
AC_TYPE_SSIZE_T
AC_TYPE_UINT8_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_CHECK_TYPES([ptrdiff_t])dnl
AX_C___ATTRIBUTE__
GNOME_DEBUG_CHECK

# Checks for library functions.
AC_FUNC_FNMATCH dnl# cannot replace though... requires unavailable sources.
AC_FUNC_MALLOC
AC_FUNC_MBRTOWC
AC_FUNC_MEMCMP
AC_FUNC_MMAP
AC_FUNC_REALLOC
AC_FUNC_STAT
AC_CHECK_FUNCS([__argz_count __argz_next __argz_stringify getwd \
                localeconv mblen mbrlen memchr memset munmap nl_langinfo \
                strchr strcspn strrchr strdup strstr strtol])dnl

dnl# Output.
AC_CONFIG_FILES([Makefile \
                 po/Makefile.in \
                 po/Makevars \
                 libraries/src/libmime/Makefile \
                 plugins/wfx/gvfs/src/Makefile])dnl
AC_OUTPUT
