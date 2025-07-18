#include <vmlinux.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#ifndef TC_ACT_OK
#define TC_ACT_OK           0
#endif

SEC("xdp")
int xdp_prog_func(struct xdp_md *ctx) {
    return TC_ACT_OK;
}

char _license[] SEC("license") = "MIT";
