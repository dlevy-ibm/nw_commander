#!/bin/bash

VXLAN_LIST=$(brctl show | grep vxlan | sed -e 's/^[ \t]*//')

for VXLAN in $VXLAN_LIST
do
    bridge fdb add 00:00:00:00:00:00 dev $VXLAN dst 10.130.101.139 self permanent
    bridge fdb append 00:00:00:00:00:00 dev $VXLAN dst 10.130.101.139 self permanent
    bridge fdb add 00:00:00:00:00:00 dev $VXLAN dst 10.130.101.138 self permanent
    bridge fdb append 00:00:00:00:00:00 dev $VXLAN dst 10.130.101.138 self permanent
done