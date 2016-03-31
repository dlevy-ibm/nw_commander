#!/bin/bash
PREFIX=unicorn
source /root/stackrc
IMAGE_ID=$(nova image-list | grep "Ubuntu Server 14.04 LTS x86_64" | cut -d"|" -f2 | tr -d '[[:space:]]')
NUM_COMPUTES=$(nova service-list | grep compute | wc -l)


#for i in `seq 1 $NUM_COMPUTES`;
# loop thrpough the compute nodes
for i in `seq 1 1`;
do
   export OS_TENANT_NAME=$PREFIX"_c"$i  
   SECURITY_GROUP_ID=$(nova secgroup-list | grep "unlocked" | cut -d"|" -f2 | tr -d '[[:space:]]')
   # loop through the 2 networks
   for k in `seq 1 2`;
   do
       echo create 5 vms on network $k on compute $i
       PREFIX_NETWORK=$PREFIX"_c"$i"_"$k
       NETWORK=$(openstack network list | grep $PREFIX_NETWORK |cut -d'|' -f2 | tr -d '[[:space:]]')
       # create 5 vms on one network on a particular compute
       for j in `seq 1 5`;
       do
           nova boot $i"_"$k"_vm"$j --flavor m1.small --image $IMAGE_ID\
           --nic net-id=$NETWORK  --security-groups $SECURITY_GROUP_ID \
           --availability-zone nova:100-node-compute$i
       done
   done
done
