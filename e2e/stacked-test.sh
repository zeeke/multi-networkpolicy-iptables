#!/bin/sh

kubectl -n test-stacked-multi wait --for=condition=ready -l app=pod-a pod --timeout=300s

echo '(1 = NO connection, 0 = can connect)'

# MultiNetworkPolicy

net1_ipaddr=$(kubectl exec -n test-stacked-multi -c macvlan-worker1 pod-a -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="net1")|.addr_info[]|select(.family=="inet").local')


kubectl -n test-stacked-multi exec pod-b -- sh -c "echo x | nc -w 1 ${net1_ipaddr} 5555" 2> /dev/null ; echo "MULTI: pod-a <-- pod-b $?"
kubectl -n test-stacked-multi exec pod-c -- sh -c "echo x | nc -w 1 ${net1_ipaddr} 5555" 2> /dev/null ; echo "MULTI: pod-a <-- pod-c $?"
kubectl -n test-stacked-multi exec pod-d -- sh -c "echo x | nc -w 1 ${net1_ipaddr} 5555" 2> /dev/null ; echo "MULTI: pod-a <-- pod-d $?"


# Regular NetworkPolicy

eth0_ipaddr=$(kubectl exec -n test-stacked-regular -c macvlan-worker1 pod-a -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="eth0")|.addr_info[]|select(.family=="inet").local')

kubectl -n test-stacked-regular exec pod-b -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555" 2> /dev/null ; echo "REGULAR: pod-a <-- pod-b $?"
kubectl -n test-stacked-regular exec pod-c -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555" 2> /dev/null ; echo "REGULAR: pod-a <-- pod-c $?"
kubectl -n test-stacked-regular exec pod-d -- sh -c "echo x | nc -w 1 ${eth0_ipaddr} 5555" 2> /dev/null ; echo "REGULAR: pod-a <-- pod-d $?"


# Debug
echo -e "\ntest-stacked-multi/pod-a iptables\n"
kubectl -n test-stacked-multi -c debug-ip-tables exec pod-a -- sh -c "iptables -L -v -n"
