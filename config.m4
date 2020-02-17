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
PHP_ARG_WITH(jq, whether to enable jq support,
[  --with-jq      Enable jq support], yes)

if test "$PHP_JQ" != "no"; then
    SEARCH_FOR="jq"
    if test x"$PHP_JQ" = x"bundle"; then
        dnl Source jq
        JQ_INC="jq/"
        JQ_SOURCE="jq/locfile.c jq/bytecode.c jq/compile.c jq/execute.c jq/builtin.c jq/jv.c jq/jv_parse.c jq/jv_print.c jq/jv_dtoa.c jq/jv_unicode.c jq/jv_aux.c jq/jv_file.c jq/jv_alloc.c jq/lexer.c jq/parser.c"
    elif test -r $PHP_JQ/$SEARCH_FOR; then
        JQ_INC=$PHP_JQ
    else
        SEARCH_PATH="/usr/local /usr"
        AC_MSG_CHECKING([for jq headers in default path])
        for prefix in $SEARCH_PATH; do
            if test -r $prefix/include/$SEARCH_FOR; then
                JQ_INC=$prefix/include
                AC_MSG_RESULT(found in $prefix/include)
            fi
        done
    fi

fi
if test -z "$JQ_INC"; then
    AC_MSG_RESULT([not found])
    AC_MSG_ERROR([Please reinstall the nacl distribution])
fi

PHP_ADD_INCLUDE($JQ_INC)

PHP_NEW_EXTENSION(jq, jq.c $JQ_SOURCE, $ext_shared)

dnl coverage
PHP_ARG_ENABLE(coverage, whether to enable coverage support,
[  --enable-coverage     Enable coverage support], no, no)

if test "$PHP_COVERAGE" != "no"; then
    EXTRA_CFLAGS="--coverage"
    PHP_SUBST(EXTRA_CFLAGS)
fi
