#!/bin/bash
PREFIX=unicorn
source ~/stackrc
NETWORK_LIST=$(openstack network list | cut -d'|' -f3 | grep unicorn)

echo Boot VMs
for i in $NETWORK_LIST
do
	NET_ID=$(openstack network list | grep $i | cut -d"|" -f2)
	for k in `seq 1 2`;
	do
		for j in `seq 1 5`;
    	do
    	nova boot $i"_part"$k"_vm"$j --flavor m1.tiny --image UPDATE-ME\
    	 --nic net-id=$NET_ID  --security-groups  UPDATE-ME \
    	 --user-data data.txt 
    	done
    done
done