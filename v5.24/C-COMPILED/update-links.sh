#!/bin/sh
# assume t/CORE/v5.24 is the only base.
# check for equality in v5.14/{t,lib}/ and v5.24{t,lib} and symlink it then

rp=`realpath $0`
dir=`dirname $rp`
# chdir to t/CORE/v5.xx
pushd $dir/..

TESTDIRS="base cmd comp extra io mro op opbasic re uni"
NEWVERSION="CORE/v5.24"
OLDVERSIONS="CORE/v5.14"

for v in $OLDVERSIONS; do
    for d in $TESTDIRS; do
        for new in t/$d/*.t; do
            old=../$v/t/$d/`basename $new`
            if [ -f $old -a -f $new -a ! "`cmp $old $new 2>/dev/null`" ]; then
                echo same $old ../$NEWVERSION/$new `cmp -b $old $new`
                rm $old
                ln -s ../$NEWVERSION/$new $old
            else
                if [ -e $old -a -e $new ]; then
                    diff -bu $old $new
                fi
            fi
        done
    done
done

pushd C-COMPILED 2>/dev/null
for d in $TESTDIRS; do
    test -d $d || mkdir $d
    pushd $d 2>/dev/null
    echo "* $d"
    # cleanup before link recreation
    rm -f *.t ||:
    # from t/CORE/v5.22/C-COMPILED/$d to t/CORE/v5.22/t/$d
    test -d ../../t/$d
    for t in ../../t/$d/*.t; do
        BN=$(basename $t)
        echo - updating: $BN
        ln -s ../template.pl $BN
    done
    # remove threaded tests
    # rm -f *_thr.t ||:
    popd 2>/dev/null
done
for d in lib; do
    test -d $d || mkdir $d
    pushd $d 2>/dev/null
    echo "* $d"
    rm -f *.t ||:
    # from t/CORE/v5.22/C-COMPILED/lib to t/CORE/v5.22/lib
    test -d ../../$d
    for t in ../../$d/*.t; do
        BN=$(basename $t)
        echo - updating: $BN
        ln -s ../template.pl $BN
    done
    popd 2>/dev/null
done
popd 2>/dev/null

popd
