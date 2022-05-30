package server

import (
	"testing"

	multiv1beta1 "github.com/k8snetworkplumbingwg/multi-networkpolicy/pkg/apis/k8s.cni.cncf.io/v1beta1"
	netdefv1 "github.com/k8snetworkplumbingwg/network-attachment-definition-client/pkg/apis/k8s.cni.cncf.io/v1"
	v1 "k8s.io/api/core/v1"
	apimeta "k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
)

func Benchmark_namespacedName_reflect(b *testing.B) {
	p := v1.Pod{ObjectMeta: metav1.ObjectMeta{Name: "pod-1", Namespace: "namespace-1"}}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		namespacedName(&p)
	}
}

func Benchmark_namespacedName_accessor_noreflect(b *testing.B) {
	p := v1.Pod{ObjectMeta: metav1.ObjectMeta{Name: "pod-1", Namespace: "namespace-1"}}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		namespacedNameAccessorNoReflect(&p)
	}
}

func Benchmark_namespacedName_switch(b *testing.B) {
	p := v1.Pod{ObjectMeta: metav1.ObjectMeta{Name: "pod-1", Namespace: "namespace-1"}}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		namespacedNameSwitch(&p)
	}
}

func Benchmark_namespacedName_direct(b *testing.B) {
	p := v1.Pod{ObjectMeta: metav1.ObjectMeta{Name: "pod-2", Namespace: "namespace-2"}}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		podNamespacedName(&p)
	}
}

func podNamespacedName(pod *v1.Pod) string {
	if pod == nil {
		return "<nil>"
	}
	return pod.GetNamespace() + "/" + pod.GetName()
}

func namespacedNameSwitch(obj runtime.Object) string {
	if obj == nil {
		return "<nil>"
	}

	switch v := obj.(type) {
	case *v1.Pod:
		if v == nil {
			return "<nil>"
		}
		return v.GetNamespace() + "/" + v.GetName()
	case *v1.Namespace:
		if v == nil {
			return "<nil>"
		}
		return v.GetNamespace() + "/" + v.GetName()
	case *multiv1beta1.MultiNetworkPolicy:
		if v == nil {
			return "<nil>"
		}
		return v.GetNamespace() + "/" + v.GetName()
	case *netdefv1.NetworkAttachmentDefinition:
		if v == nil {
			return "<nil>"
		}
		return v.GetNamespace() + "/" + v.GetName()
	}

	return "<err>"

}

func namespacedNameAccessorNoReflect(obj interface{}) string {
	if obj == nil {
		return "<nil>"
	}

	// This function cannot be used because underlying obj reference
	// can be nil even if obj != nil

	a, err := apimeta.Accessor(obj)
	if err != nil {
		return "<err>"
	}

	return a.GetNamespace() + "/" + a.GetName()
}
