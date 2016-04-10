#!/bin/bash
source /root/stackrc
PREFIX=unicorn

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

    NETWORK_1_ID=$(openstack network list | grep $PREFIX_NETWORK_1 | awk '{ print $2 }')
    NETWORK_2_ID=$(openstack network list | grep $PREFIX_NETWORK_2 | awk '{ print $2 }')
    echo Network IDs: 
    echo "   $NETWORK_1_ID"
    echo "   $NETWORK_2_ID"

    export OS_TENANT_NAME=$tenant
    IP_SERVER=$(nova list | grep $i"_1_vm1" | awk -F'[=]' '{ print $2 }' | awk -F'[ ]' '{ print $1 }')
    IP_CLIENT=$(nova list | grep $i"_2_vm1" | awk -F'[=]' '{ print $2 }' | awk -F'[ ]' '{ print $1 }')

    echo ip_server $IP_SERVER
    echo ip_client $IP_CLIENT
    ssh-keygen -R $IP_SERVER
    ssh-keygen -R $IP_CLIENT






    # run netperf tests
    cat deploy_dan_run_netperf.sh | sed "s/REPLACE_SERVER/$IP_SERVER/g"| ip netns exec qdhcp-$NETWORK_2_ID sshpass -p 'Sm4rtcl0ud!' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3  ibmcloud@$IP_CLIENT

done