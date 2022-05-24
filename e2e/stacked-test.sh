#!/bin/sh

# MultiNetworkPolicy

net1_ipaddr=$(kubectl exec -n test-stacked-multi pod-a -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="net1")|.addr_info[]|select(.family=="inet").local')


kubectl -n test-stacked-multi exec pod-b -- sh -c "echo x | nc -w 1 ${net1_ipaddr} 5555" 2> /dev/null || echo "MULTI: pod-a should be reachable by pod-b"
kubectl -n test-stacked-multi exec pod-c -- sh -c "echo x | nc -w 1 ${net1_ipaddr} 5555" 2> /dev/null || echo "MULTI: pod-a should be reachable by pod-c"
kubectl -n test-stacked-multi exec pod-d -- sh -c "echo x | nc -w 1 ${net1_ipaddr} 5555" 2> /dev/null && echo "MULTI: pod-a should NOT be reachable by pod-d"


# Regular NetworkPolicy

eth0_ipaddr=$(kubectl exec -n test-stacked-regular pod-a -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="eth0")|.addr_info[]|select(.family=="inet").local')

kubectl -n test-stacked-regular exec pod-b -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555" 2> /dev/null || echo "REGULAR: pod-a should be reachable by pod-b"
kubectl -n test-stacked-regular exec pod-c -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555" 2> /dev/null || echo "REGULAR: pod-a should be reachable by pod-c"
kubectl -n test-stacked-regular exec pod-d -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555" 2> /dev/null && echo "REGULAR: pod-a should NOT be reachable by pod-d"
