#!/bin/sh
#1
SUB_NET="172.18.0.0/16"
CLIENT_IP=172.18.0.23
declare -a SERVER_IPS=("172.18.0.101" "172.18.0.102" "172.18.0.103")
 
#2
timestamp=$(date +%Y%m%d_%H%M%S)
volume_path=$(pwd)
jmeter_path=/mnt/jmeter
TEST_NET=mydummynet
 
#3
echo "Create testing network"
docker network create --subnet=$SUB_NET $TEST_NET


#4
echo "Create servers"
for IP_ADD in "${SERVER_IPS[@]}"
do
	docker run \
	-dit \
	--net $TEST_NET --ip $IP_ADD \
	-v "${volume_path}":${jmeter_path} \
	--rm \
	jmeter \
	-n -s \
	-Jclient.rmi.localport=7000 -Jserver.rmi.localport=60000 \
	-j ${jmeter_path}/server/slave_${timestamp}_${IP_ADD:9:3}.log 
done


#5 
echo "Create client and execute test"
docker run \
  --net $TEST_NET --ip $CLIENT_IP \
  -v "${volume_path}":${jmeter_path} \
  --rm \
  jmeter \
  -n -X \
  -Jclient.rmi.localport=7000 \
  -R $(echo $(printf ",%s" "${SERVER_IPS[@]}") | cut -c 2-) \
  -t ${jmeter_path}/test.jmx \
  -l ${jmeter_path}/client/result_${timestamp}.jtl \
  -j ${jmeter_path}/client/jmeter_${timestamp}.log 
 
#6
docker network rm $TEST_NET
