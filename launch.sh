#!/bin/bash

#
# This script expects the standdard JMeter command parameters.
#

JMETER_DEBUG=${JMETER_DEBUG:-false}
JMETER_USER_CLASSPATH=${JMETER_USER_CLASSPATH:=/opt/userclasspath}

set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))

echo "#### Using Java Virtual Machine :"
echo $(java -version)

if [ "$JMETER_DEBUG" = true ] ; then
	echo "Enabled remote debugging for JMeter on TCP 8000"
	export JVM_ARGS="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000"
else
	export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"
fi

echo "START Running Apache JMeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "$CMD args=$@"

# Keep entrypoint simple: we must pass the standard JMeter arguments
jmeter -Juser.classpath="$JMETER_USER_CLASSPATH" $@
echo "END Running Jmeter on `date`"

