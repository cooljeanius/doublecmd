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
GNOME_MAINTAINER_MODE_DEFINES
AC_OBJEXT
AC_EXEEXT

# Checks for programs.
AC_USE_SYSTEM_EXTENSIONS
AM_PROG_AR
AC_LANG([C])
AC_PROG_CPP
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MKDIR_P
AC_PROG_RANLIB
AC_PROG_YACC
AX_CHECK_GNU_MAKE

# Checks for libraries.
AM_PATH_GLIB
AM_PATH_GLIB_2_0
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.18.2])
AM_GLIB_GNU_GETTEXT
gl_FCNTL_O_FLAGS
AC_SUBST([POMAKEFILEDEPS])

# Checks for header files.
AC_CHECK_HEADERS([fcntl.h float.h glib.h libintl.h langinfo.h malloc.h stdio.h stdio_ext.h wchar.h wfxplugin.h xsize.h])
AC_CHECK_HEADERS([gvfs-client/gvfs/gvfsurimapper.h gvfs/gvfsurimapper.h gvfsurimapper.h gvfs-client/gvfs/gvfsuriutils.h gvfs/gvfsuriutils.h gvfsuriutils.h libgnomevfs/gnome-vfs.h gnome-vfs.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_CHECK_HEADER_STDBOOL
AC_C_INLINE
AC_TYPE_SIZE_T
AC_TYPE_SSIZE_T
AC_TYPE_UINT8_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_CHECK_TYPES([ptrdiff_t])
AX_C___ATTRIBUTE__
GNOME_DEBUG_CHECK

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_MBRTOWC
AC_FUNC_MMAP
AC_FUNC_REALLOC
AC_CHECK_FUNCS([__argz_count __argz_next __argz_stringify getwd localeconv mblen mbrlen memchr memset munmap nl_langinfo strchr strcspn strrchr strdup strstr strtol])

AC_CONFIG_FILES([Makefile po/Makefile libraries/src/libmime/Makefile plugins/wfx/gvfs/src/Makefile])
AC_OUTPUT
