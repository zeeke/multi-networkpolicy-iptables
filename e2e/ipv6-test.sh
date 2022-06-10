#!/bin/sh

kubectl -n test-ipv6-multi wait --for=condition=ready -l app=pod-a pod --timeout=300s

echo '(1 = NO connection, 0 = can connect)'

# MultiNetworkPolicy

podA_net1_ipaddr=$(kubectl exec -n test-ipv6-multi -c macvlan-worker1 pod-a -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="net1")|.addr_info[]|select(.family=="inet").local')
podB_net1_ipaddr=$(kubectl exec -n test-ipv6-multi -c macvlan-worker1 pod-b -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="net1")|.addr_info[]|select(.family=="inet").local')
podC_net1_ipaddr=$(kubectl exec -n test-ipv6-multi -c macvlan-worker1 pod-c -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="net1")|.addr_info[]|select(.family=="inet").local')



kubectl -n test-ipv6-multi exec pod-b -- sh -c "echo x | nc -w 1 ${podA_net1_ipaddr} 5555" 2> /dev/null ; echo "MULTI: pod-a <-- pod-b $?"
kubectl -n test-ipv6-multi exec pod-c -- sh -c "echo x | nc -w 1 ${podA_net1_ipaddr} 5555" 2> /dev/null ; echo "MULTI: pod-a <-- pod-c $?"


# Regular NetworkPolicy

podA_eth0_ipaddr=$(kubectl exec -n test-ipv6-regular -c macvlan-worker1 pod-a -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="eth0")|.addr_info[]|select(.family=="inet").local')
podB_eth0_ipaddr=$(kubectl exec -n test-ipv6-regular -c macvlan-worker1 pod-b -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="eth0")|.addr_info[]|select(.family=="inet").local')
podC_eth0_ipaddr=$(kubectl exec -n test-ipv6-regular -c macvlan-worker1 pod-c -- ip -j a show  | jq -r \
	'.[]|select(.ifname =="eth0")|.addr_info[]|select(.family=="inet").local')

kubectl -n test-ipv6-regular exec pod-b -- sh -c "echo x | nc -w 1 ${podA_eth0_ipaddr} 5555" 2> /dev/null ; echo "REGULAR: pod-a <-- pod-b $?"
kubectl -n test-ipv6-regular exec pod-c -- sh -c "echo x | nc -w 1 ${podA_eth0_ipaddr} 5555" 2> /dev/null ; echo "REGULAR: pod-a <-- pod-c $?"

# Debug
echo -e "\ntest-ipv6-multi/pod-a iptables\n"
kubectl -n test-ipv6-multi -c debug-ip-tables exec pod-a -- sh -c "iptables -L -v -n"
