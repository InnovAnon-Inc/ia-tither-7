. /etc/environment
export SOCKS_PROXY

/usr/local/bin/support-wrapper &
P="$!"
support_exit () {
        e="$?"
	set -eu
        [ $# -eq 1 ]
	kill -0 "$1"
        kill    "$1"
        wait    "$1" || :
        exit    "$e"
}
kill -0 "$P" || exit "$?"
# shellcheck disable=SC2064
trap "support_exit $P" 0
unset P

