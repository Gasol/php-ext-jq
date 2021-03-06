dnl config.m4 for extension jq

dnl Check PHP version:
AC_MSG_CHECKING(PHP version)
if test ! -z "$phpincludedir"; then
    PHP_VERSION=`grep 'PHP_VERSION ' $phpincludedir/main/php_version.h | sed -e 's/.*"\([[0-9\.]]*\)".*/\1/g' 2>/dev/null`
elif test ! -z "$PHP_CONFIG"; then
    PHP_VERSION=`$PHP_CONFIG --version 2>/dev/null`
fi

if test x"$PHP_VERSION" = "x"; then
    AC_MSG_WARN([none])
else
    PHP_MAJOR_VERSION=`echo $PHP_VERSION | sed -e 's/\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\1/g' 2>/dev/null`
    PHP_MINOR_VERSION=`echo $PHP_VERSION | sed -e 's/\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\2/g' 2>/dev/null`
    PHP_RELEASE_VERSION=`echo $PHP_VERSION | sed -e 's/\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\3/g' 2>/dev/null`
    AC_MSG_RESULT([$PHP_VERSION])
fi

if test $PHP_MAJOR_VERSION -lt 5; then
    AC_MSG_ERROR([need at least PHP 5.3 or newer])
fi

if test $PHP_MAJOR_VERSION -eq 5 -a $PHP_MINOR_VERSION -lt 3; then
    AC_MSG_ERROR([need at least PHP 5.3 or newer])
fi

dnl jq Extension
PHP_ARG_ENABLE(jq, whether to enable jq support,
[  --enable-jq      Enable jq support])

if test "$PHP_JQ" != "no"; then

    dnl Source jq
    PHP_ADD_INCLUDE("jq/")
    JQ_SOURCE="jq/locfile.c jq/bytecode.c jq/compile.c jq/execute.c jq/builtin.c jq/jv.c jq/jv_parse.c jq/jv_print.c jq/jv_dtoa.c jq/jv_unicode.c jq/jv_aux.c jq/jv_file.c jq/jv_alloc.c jq/lexer.c jq/parser.c"

    dnl PHP Extension
    PHP_NEW_EXTENSION(jq, jq.c $JQ_SOURCE, $ext_shared)
fi

dnl coverage
PHP_ARG_ENABLE(coverage, whether to enable coverage support,
[  --enable-coverage     Enable coverage support], no, no)

if test "$PHP_COVERAGE" != "no"; then
    EXTRA_CFLAGS="--coverage"
    PHP_SUBST(EXTRA_CFLAGS)
fi
