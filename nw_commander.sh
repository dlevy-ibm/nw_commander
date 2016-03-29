#!/bin/bash
WAIT_TIME=20
PREFIX=unicorn

#verify that there are 0 projects/networks/vms before starting

#duplicate projects, subnets are fine (openstack wont allow). 
#Duplicate networks, routers = not fine. Must ensure everything  is deleted beforehand


#number of computes, verify greater than 1
#choose location this runs on, local/deployer/controller?
#Currently set up for controller

source ~/stackrc
NUM_COMPUTES=$(nova service-list | grep compute | wc -l)

for i in `seq 1 $NUM_COMPUTES`;
do
   echo "Creating project $PREFIX_c$i"
   openstack project create $PREFIX_c$i

   #For each project create 2 networks 
   echo "Creating network and subnet"
   openstack network create $PREFIX"_c"$i"_1" --project c1
   neutron subnet-create $PREFIX"_c"$i"_1" 123.$i".1.0/28" --name $PREFIX"_c"$i"_1"

   openstack network create $PREFIX"_c"$i"_2" --project c1
   neutron subnet-create $PREFIX"_c"$i"_2" 123.$i".2.0/28" --name $PREFIX"_c"$i"_2"

   #Route between the networks
   neutron router-create $PREFIX"_c"$i --tenant-id $PREFIX"_c"$i
   neutron router-interface-add $PREFIX"_c"$i $PREFIX"_c"$i"_1"
   neutron router-interface-add $PREFIX"_c"$i $PREFIX"_c"$i"_2"
done




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



#Kill the program if we dont have correct arguemnts
die () {
    echo >&2 "$@"
    exit 1
}

