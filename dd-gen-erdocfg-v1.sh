#!/bin/bash

OUT_FILE="elrond.conf"

echo " # Alarms for Elrond node issues
 # /etc/netdata/health.d/elrond.conf:
" > $OUT_FILE


for iteration in $(seq 0 $(($1-1)))
do
	nodename="$(grep -oP '(?<=NodeDisplayName = )[^ ]*' ~/elrond-nodes/node-${iteration}/config/prefs.toml)"
	nodename=${nodename:1: -1}
	echo ' # Elrond node '${iteration}' is not maintaining sync' >> $OUT_FILE
	echo '   alarm: elrond_sync-node'${iteration}'' >> $OUT_FILE
	echo '      on: elrond.sync-node'${iteration}'' >> $OUT_FILE
    echo '    calc: $current - $synced
   every: 1m
  repeat: on warning 600 critical 60
    warn: $this > (($status >= $WARNING ) ? ( 2 ) : ( 20 ))
    crit: $this > (($status == $CRITICAL) ? ( 20 ) : ( 200 ))' >> $OUT_FILE
	echo '    info: Elrond node '$nodename' is out of syncronization' >> $OUT_FILE
	echo '      to: sysadmin
' >> $OUT_FILE
done

for iteration in $(seq 0 $(($1-1)))
do
	nodename="$(grep -oP '(?<=NodeDisplayName = )[^ ]*' ~/elrond-nodes/node-${iteration}/config/prefs.toml)"
	nodename=${nodename:1: -1}
	echo ' # Elrond node '${iteration}' peers dropping' >> $OUT_FILE
	echo '   alarm: elrond_peers-node'${iteration}'' >> $OUT_FILE
	echo '      on: elrond.peers-node'${iteration}'' >> $OUT_FILE
    echo '    calc: $peers
   every: 1m
    warn: $this < (($status >= $WARNING ) ? ( 45 ) : ( 40 ))
    crit: $this < (($status == $CRITICAL ) ? ( 40 ) : ( 30 ))' >> $OUT_FILE
	echo '    info: Elrond node '$nodename' peers are dropping' >> $OUT_FILE
	echo '      to: sysadmin
' >> $OUT_FILE
done

