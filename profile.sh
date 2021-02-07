#! /bin/bash
set -euvxo pipefail
(( ! $# ))
$PREFIX/bin/xmrig &
cpid=$!
for k in $(seq 11) ; do
  sleep 666
  kill -0 $cpid
done
kill $cpid
wait $cpid || :
rm -v "$0"

