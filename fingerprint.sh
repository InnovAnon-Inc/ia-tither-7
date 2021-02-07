#! /bin/bash
set -euvxo pipefail
(( ! $# ))

export CPPFLAGS="-DNDEBUG $CPPFLAGS"

FLAG=0
for k in $(seq 1009) ; do
  /usr/games/polygen -pedantic -o fingerprint.bc llvm.grm                        || continue
  #clang -c $CFLAGS             -o fingerprint.o  fingerprint.bc -static $LDFLAGS || continue
  clang -c                     -o fingerprint.o  fingerprint.bc -static          || continue
  ar vcrs                      libfingerprint.a  fingerprint.o                   || continue
  FLAG=1
  break
done
test "$FLAG" -ne 0
install -v -D {,"$PREFIX/lib/"}libfingerprint.a
test -d "$PREFIX"
rm -v llvm.grm* fingerprint.bc fingerprint.o libfingerprint.a "$0"

