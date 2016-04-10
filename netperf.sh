#!/bin/bash
source /root/stackrc
PREFIX=unicorn

nova list --all-tenants > nova-list.txt
openstack network list > network-list.txt
echo "" > server-list.txt

#Record the top process for controller1 and controller2
ssh 10.130.101.138  -n "top -d 4 -b -o USER | grep -ve root" > controller1.netperf.top &
TOPC1=$!
ssh 10.130.101.139  -n "top -d 4 -b -o USER | grep -ve root" > controller2.netperf.top &
TOPC2=$!

runtest() {

for i in `seq 1 100`;
do
    tenant=$PREFIX"_c"$i
    echo "************* Processing project $tenant ***************"
    i=$(echo $tenant | awk -F'[_c]' '{ print $4 }')

    echo Project number: $i
    PREFIX_NETWORK_1=$PREFIX"_c"$i"_1"
    PREFIX_NETWORK_2=$PREFIX"_c"$i"_2"
    echo Network 1: $PREFIX_NETWORK_1
    echo Network 2: $PREFIX_NETWORK_2

    NETWORK_1_ID=$(cat network-list.txt | grep $PREFIX_NETWORK_1 | awk '{ print $2 }')
    NETWORK_2_ID=$(cat network-list.txt | grep $PREFIX_NETWORK_2 | awk '{ print $2 }')    
    echo Network IDs: 
    echo "   $NETWORK_1_ID"
    echo "   $NETWORK_2_ID"
    
    # export OS_TENANT_NAME=$tenant
    IP_SERVER=$(cat nova-list.txt | grep " "$i"_1_vm1" | awk -F'[=]' '{ print $2 }' | awk -F'[ ]' '{ print $1 }')
    IP_CLIENT=$(cat nova-list.txt | grep " "$i"_2_vm1" | awk -F'[=]' '{ print $2 }' | awk -F'[ ]' '{ print $1 }')
    echo "cat nova-list.txt | grep " "$i"_1_vm1" | awk -F'[=]' '{ print $2 }' | awk -F'[ ]' '{ print $1 }'"
    echo ip_server $IP_SERVER
    echo ip_client $IP_CLIENT
    ssh-keygen -R $IP_SERVER
    ssh-keygen -R $IP_CLIENT
    FILENAME="$tenant"_"$1".txt
    echo "ip netns exec qdhcp-$NETWORK_2_ID sshpass -p 'Sm4rtcl0ud!' scp -o StrictHostKeyChecking=no -o ConnectTimeout=3 ibmcloud@$IP_CLIENT:/home/ibmcloud/$2 ./result/$FILENAME;" >> server-list.txt
    INPUT="$1 $2 $3"
    # run netperf tests
    echo "cat deploy_dan_run_netperf.sh | sed "s/REPLACE_SERVER/$IP_SERVER/g" | sed "s/REPLACE_INPUT/$INPUT/g" | ip netns exec qdhcp-$NETWORK_2_ID sshpass -p 'Sm4rtcl0ud!' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3  ibmcloud@$IP_CLIENT &"
    cat deploy_dan_run_netperf.sh | sed "s/REPLACE_SERVER/$IP_SERVER/g" | sed "s/REPLACE_INPUT/$INPUT/g" | ip netns exec qdhcp-$NETWORK_2_ID sshpass -p 'Sm4rtcl0ud!' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3  ibmcloud@$IP_CLIENT &
 
done
}


echo "Running TCP_STREAM test..."
runtest TCP_STREAM netperftcp.txt

NUM=$(ps aux | grep "sshpass" | wc -l)
while [ $NUM -gt 1 ]
do
    NUM=$(ps aux | grep "sshpass" | wc -l)
    echo "Process: $NUM"
    sleep 2
done

echo "Copy files for TCP_STREAM..."
CMD=$(cat server-list.txt)
echo "$CMD"
eval $CMD

echo "Running UDP_STREAM test..."
runtest UDP_STREAM netperfudp.txt "-R 1"

NUM=$(ps aux | grep "sshpass" | wc -l)
while [ $NUM -gt 1 ]
do
    NUM=$(ps aux | grep "sshpass" | wc -l)
    echo "Process: $NUM"
    sleep 2
done

echo "Copy files for UDP_STREAM..."
CMD=$(cat server-list.txt)
echo "$CMD"
eval $CMD

echo "Running TCP_RR test..."
runtest TCP_RR netperftcprr.txt

NUM=$(ps aux | grep "sshpass" | wc -l)
while [ $NUM -gt 1 ]
do
    NUM=$(ps aux | grep "sshpass" | wc -l)
    echo "Process: $NUM"
    sleep 2
done

echo "Copy files for TCP_RR..."
CMD=$(cat server-list.txt)
echo "$CMD"
eval $CMD

#Kill top process
kill -9 $TOPC1
kill -9 $TOPC2


#rm -f nova-list.txt
#rm -f network-list.txt
#rm -f server-list.txt
