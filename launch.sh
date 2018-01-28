#!/bin/bash

#
# This script expects the standdard JMeter command parameters.
#

set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

if [ "$1" =  "client" ]
then
	CMD="jmeter -s"
	ARGS=${@:2}
else
	CMD="jmeter"
	ARGS=$@
fi

echo "START Running $CMD on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "$CMD args=$ARGS"

# Keep entrypoint simple: we must pass the standard JMeter arguments
jmeter $ARGS
echo "END Running Jmeter on `date`"

