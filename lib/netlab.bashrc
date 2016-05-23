PS1="[netlab] # "

NETLAB_BASE=`pwd`
NETLAB_BIRD="$NETLAB_BASE/.."

. lib/netlab_network
. lib/netlab_utils
. lib/netlab_commands

netlab_init_network
