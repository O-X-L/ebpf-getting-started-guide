#include <vmlinux.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

SEC("socket")
int filter(struct __sk_buff *skb) {
  return BPF_OK;
}

char _license[] SEC("license") = "MIT";
