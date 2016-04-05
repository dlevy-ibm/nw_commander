#!/bin/bash
PREFIX=unicorn

PROJECT_LIST=$(openstack network list | cut -d'|' -f3 | grep unicorn)
echo Do stuff
for i in $PROJECT_LIST
do
    ROUTER_ID=$(neutron router-list | grep $i)
    IP_SERVER=$(nova list | grep $i"_1_vm1")
    IP_CLIENT=$(nova list | grep $i"_2_vm1")

    ip netns exec $ROUTER_ID ssh IP_SERVER 
done