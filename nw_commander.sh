#!/bin/bash
WAIT_TIME=20
PREFIX=unicorn
#Kill the program if we dont have correct arguemnts
die () {
    echo >&2 "$@"
    exit 1
}

#tag everythng with unicorn
#verify that there are 0 projects/networks/vms before starting
openstack project list | grep $PREFIx


#number of computes, verify greater than 1
#choose location this runs on
source stackrc
NUM_COMPUTES=$(nova service-list | grep compute | wc -l)

#for each compute node, create 1 project
openstack project create c1

#For each project create 2 networks 
openstack network create c1_1 --project c1
neutron subnet-create c1_1 123.1.1.0/28 --name c1_1

openstack network create c1_2 --project c1
neutron subnet-create c1_2 123.1.2.0/28 --name c1_2

#Route between the networks
neutron router-create c1 --tenant-id c1 #can try ha mode here if needed
neutron router-interface-add c1 c1_1
neutron router-interface-add c1 c1_2





openstack network create c2_1 --project c2
neutron subnet-create c2_1 123.2.1.0/28 --name c2_1

openstack network create c2_2 --project c2
neutron subnet-create c2_2 123.2.2.0/28 --name c2_2






#DELETIONS
ROUTER_LIST=$(neutron router-list | cut -d'|' -f3 | grep unicorn)
NETWORK_LIST=$(openstack network list | cut -d'|' -f3 | grep unicorn)


for X in $ROUTER_LIST
    do
        #Get rid of the router interfaces
    done


for X in $ROUTER_LIST
    do

    done





