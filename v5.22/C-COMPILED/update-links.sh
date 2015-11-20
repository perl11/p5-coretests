#!/bin/sh
# assume t/CORE/v5.22 is the only base.
# check for equality in v5.14/{t,lib}/ and v5.22{t,lib} and symlink it then

rp=`realpath $0`
dir=`dirname $rp`
# chdir to t/CORE/v5.22/C-COMPILED/../
pushd $dir/..

TESTDIRS="base cmd comp extra io mro op re uni"
NEWVERSION="CORE/v5.22"
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
                diff -bu $old $new
            fi
        done
    done
done

#exit

pushd t/
for d in $TESTDIRS; do
    pushd $d
    echo "* $d"
    # cleanup before link recreation
    rm -f *.t ||:
    test -d ../../t/$d 
    for t in ../../t/$d/*.t; do
        BN=$(basename $t)
        echo - updating: $BN
        ln -s ../template.pl $BN
    done
    # remove threaded tests
    # rm -f *_thr.t ||:
    popd
done
popd

popd
