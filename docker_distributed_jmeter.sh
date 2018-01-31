#!/bin/sh

SUB_NET=172.18.0.0
CLIENT_IP=172.18.0.23
declare -a SERVER_IPS=("172.18.0.101" "172.18.0.102" "172.18.0.103" "172.18.0.104" "172.18.0.105")

timestamp=$(date +%Y%m%d_%H%M%S)
volume_path=$(pwd)
jmeter_path=/mnt/jmeter

DOCKER_NETWORK=tmpmynet123

echo "Cleanup container history and unused network"
docker ps | grep -v CONTAINER | awk '{print $1}' | xargs --no-run-if-empty docker stop
docker ps --filter "status=exited" | grep -v CONTAINER |  awk '{print $1}' | xargs --no-run-if-empty docker rm
docker network prune -f

echo "Create testing network"
docker network create --subnet=$SUB_NET/16 $DOCKER_NETWORK

echo "Create servers"
# servers
for IP in "${SERVER_IPS[@]}"
do
	docker run \
	-dit \
	--net $DOCKER_NETWORK --ip $IP \
	-v "${volume_path}":${jmeter_path} \
	--rm \
	jmeter \
	-s -n \
	-Jclient.rmi.localport=7000 -Jserver.rmi.localport=60000 \
	-l ${jmeter_path}/tmp/result_${timestamp}_${IP:9:3}.jtl \
	-j ${jmeter_path}/tmp/slave_${timestamp}_${IP:9:3}.log 
done

echo "Create client and execute test"
# client
docker run \
  --net $DOCKER_NETWORK --ip $CLIENT_IP \
  -v "${volume_path}":${jmeter_path} \
  --rm \
  jmeter \
  -n -X \
  -Jreport_path=${jmeter_path}/tmp -Jsample_variables=extractredValue \
  -Jclient.rmi.localport=7000 \
  -R $(echo $(printf ",%s" "${SERVER_IPS[@]}") | cut -c 2-) \
  -t ${jmeter_path}/test.jmx \
  -l ${jmeter_path}/tmp/result_${timestamp}.jtl \
  -j ${jmeter_path}/tmp/jmeter_${timestamp}.log 

# fetch the results file from slaves
sleep 3

#docker network prune
docker network rm $DOCKER_NETWORK
