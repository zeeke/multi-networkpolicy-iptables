#!/bin/sh

eth0_ipaddr=$(kubectl --context kind-regular exec -n test-stacked pod-a -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="eth0")|.addr_info[]|select(.family=="inet").local')


kubectl --context kind-regular  -n test-stacked exec pod-b -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555"
kubectl --context kind-regular -n test-stacked exec pod-c -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555"
kubectl --context kind-regular  -n test-stacked exec pod-d -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555"

