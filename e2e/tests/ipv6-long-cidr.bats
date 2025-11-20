#!/usr/bin/env bats


setup() {
	cd $BATS_TEST_DIRNAME
	load "common"
	server_net1=$(get_net1_ip6 "test-ipv6-long-cidr" "pod-server")
	client_a_net1=$(get_net1_ip6 "test-ipv6-long-cidr" "pod-client-a")
	client_b_net1=$(get_net1_ip6 "test-ipv6-long-cidr" "pod-client-b")
}

@test "setup ipv6-long-cidr test environments" {
	# create test manifests
	kubectl create -f ipv6-long-cidr.yml

	# verify all pods are available
	run kubectl -n test-ipv6-long-cidr wait --for=condition=ready -l app=test-ipv6-long-cidr pod --timeout=${kubewait_timeout}
	[ "$status" -eq  "0" ]

	sleep 5
}

@test "test-ipv6-long-cidr check client-a -> server" {
	# nc should succeed from client-a to server by policy
	run kubectl -n test-ipv6-long-cidr exec pod-client-a -- sh -c "echo x | nc -w 1 ${server_net1} 5555"
	[ "$status" -eq  "0" ]
}

@test "test-ipv6-long-cidr check client-b -> server" {
	# nc should NOT succeed from client-b to server by policy
	run kubectl -n test-ipv6-long-cidr exec pod-client-b -- sh -c "echo x | nc -w 1 ${server_net1} 5555"
	[ "$status" -eq  "1" ]
}

@test "test-ipv6-long-cidr check server -> client-a" {
	# nc should succeed from server to client-a by no policy definition for direction (egress for pod-server)
	run kubectl -n test-ipv6-long-cidr exec pod-server -- sh -c "echo x | nc -w 1 ${client_a_net1} 5555"
	[ "$status" -eq  "0" ]
}

@test "test-ipv6-long-cidr check server -> client-b" {
	# nc should succeed from server to client-b by no policy definition for direction (egress for pod-server)
	run kubectl -n test-ipv6-long-cidr exec pod-server -- sh -c "echo x | nc -w 1 ${client_b_net1} 5555"
	[ "$status" -eq  "0" ]
}

@test "cleanup environments" {
	# remove test manifests
	kubectl delete -f ipv6-long-cidr.yml
	run kubectl -n test-ipv6-long-cidr wait --for=delete -l app=test-ipv6-long-cidr pod --timeout=${kubewait_timeout}
	[ "$status" -eq  "0" ]
}
