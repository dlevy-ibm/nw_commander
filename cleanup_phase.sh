#!/bin/bash
PREFIX=unicorn



source ~/stackrc




#DELETIONS
ROUTER_LIST=$(neutron router-list | cut -d'|' -f3 | grep unicorn)
NETWORK_LIST=$(openstack network list | cut -d'|' -f3 | grep unicorn)
PROJECT_LIST=$(openstack project list | cut -d'|' -f3 | grep unicorn)


echo Deleting routers and router interfaces
for i in $ROUTER_LIST
do
	#Get interfaces
	INTERFACE_LIST=$(neutron router-port-list $i | cut -d'|' -f5 | tail -n +4 | head -n -1 | cut -d',' -f1 | cut -d":" -f2 | cut -d'"' -f2)
	for j in $INTERFACE_LIST
	do
		neutron router-interface-delete $i $j
	done
	neutron router-delete $i
done


echo Deleting networks
for i in $NETWORK_LIST
do
    neutron net-delete $i
done

echo Deleting projects
for i in $PROJECT_LIST
do
    openstack project delete $i
done




