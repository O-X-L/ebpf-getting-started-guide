# eBPF Getting-Started Guide

**WARNING: This guide is still work-in-progress.**

We had some problems finding simple eBPF examples that worked out-of-the box and provided containerized build-environments.

This getting-started guide should help new eBPF-users to get started more quickly.

If you have ideas on how to extend or improve this guide => [open an issue](https://github.com/O-X-L/ebpf-getting-started-guide/issues) or [email us](mailto://contact+ebpf@oxl.at)

----

## Use Cases

BPF can be used for many use cases.

If you are new to it, you should look into the [program types](https://docs.ebpf.io/linux/program-type/) to get an idea of what you can use it for.

They differ in the way they are called (*some have hooks*), the return values that are expected and thus the functionality the modules of this type can provide.

Examples:
* [BPF_PROG_TYPE_XDP](https://docs.ebpf.io/linux/program-type/BPF_PROG_TYPE_XDP/) => can process network traffic very early on and thus can be used for defending against (D)DOS as described in [this Cloudflare blog](https://blog.cloudflare.com/cloudflare-architecture-and-how-bpf-eats-the-world/)
* [BPF_PROG_TYPE_SOCKET_FILTER](https://docs.ebpf.io/linux/program-type/BPF_PROG_TYPE_SOCKET_FILTER/) => can be used to extend IPTables/NFTables rulesets as described in [this Cloudflare blog](https://blog.cloudflare.com/programmable-packet-filtering-with-magic-firewall/)
* [BPF_PROG_TYPE_LWT_IN](https://docs.ebpf.io/linux/program-type/BPF_PROG_TYPE_LWT_IN/) => apply route-based filters
* [BPF_PROG_TYPE_LSM](https://docs.ebpf.io/linux/program-type/BPF_PROG_TYPE_LSM/) => can implement security-filters for specific system-events

----

## Concepts

See also: [eBPF Docs - Concepts](https://docs.ebpf.io/linux/concepts/)

### Pinning

As we've looked into the integration of eBPF modules for NFTables/IPTables - we've seen pinned-objects being mentioned.

BPF can have a filesystem (`/sys/fs/bpf`) that contains references to currently loaded BPF objects.

https://docs.ebpf.io/linux/concepts/pinning/

### Concurrency / Race Conditions

You have to be aware of [possible race conditions](https://docs.ebpf.io/linux/concepts/concurrency/) when writing data to shared objects like maps!

The docs mention some options to work around such issues.

----

## Building: Raw vs eBPF-go

We would recommend using a containerized build-environment. For the examples in this repository your will have to have [Docker installed](https://docs.docker.com/engine/install/).

Here we will cover two ways in which you can use eBPF:

----

### Raw

Compile the module directly.

To run: `make build_raw` or `bash scripts/build_raw.sh`

Look into the script and `docker/Dockerfile_build_raw` to get to know how it is done.

Usage examples:

* [Traffic control](https://man7.org/linux/man-pages/man8/tc-bpf.8.html):

    ```bash
    # Load the clsact qdisc on the interface (if not already loaded)
    tc qdisc add dev eth0 clsact

    # Add a BPF program as a classifier (filter) on ingress
    tc filter add dev eth0 ingress bpf da obj bpf_prog.o sec classifier
    
    # Add a BPF program as an action on egress
    tc filter add dev eth0 egress bpf da obj bpf_prog.o sec action
    ```

----

### eBPF-go

Load module in go user-space process and get push information from eBPF to go to process it.

For more examples see: [cilium/ebpf/blob/main/examples](https://github.com/cilium/ebpf/blob/main/examples)


To run: `make build_go` or `bash scripts/build_go_single.sh <relative-src-path>`

Look into the script and `docker/Dockerfile_build_go` to get to know how it is done.


----

## Debug Output (Print)

You can use `bpf_trace_printk(fmt, sizeof(fmt));` to temporarily enable debug-output. See: [eBPF Docs](https://docs.ebpf.io/linux/helper-function/bpf_trace_printk/)

You can read it via: `sudo cat /sys/kernel/tracing/trace | grep BPF` (if you add prefix like `[eBPF]` to the message)

NOTE: `bpf_trace_printk` can only take 3 format-parameters.

**Examples:**

* Format IPv4

  ```c
  const char log_ip4[] = "[eBPF] IP4: %pI4\n";
  bpf_trace_printk(log_ip4, sizeof(log_ip4), &ip4->saddr);
  // bpf_trace_printk: [eBPF] IP4: 127.0.0.1
  ```

* Format IPv6

  ```c
  const char log_ip6[] = "[eBPF] IP6: %pI6\n";
  bpf_trace_printk(log_ip6, sizeof(log_ip6), &ip6->saddr);
  // bpf_trace_printk: [eBPF] IP6: fe80:0000:0000:0000:c87f:acff:fe69:287a
  ```

* Write hex of bytes

  ```c
  const char log_ip6_p1[] = "[eBPF] IP6: Parts 1+2 (0x%x 0x%x)\n";
  bpf_trace_printk(log_ip6_p1, sizeof(log_ip6_p1), bpf_ntohl(ip6o.addr[0]), bpf_ntohl(ip6o.addr[1]));
  const char log_ip6_p2[] = "[eBPF] IP6: Parts 3+4 (0x%x 0x%x)\n";
  bpf_trace_printk(log_ip6_p2, sizeof(log_ip6_p2), bpf_ntohl(ip6o.addr[2]), bpf_ntohl(ip6o.addr[3]));
  // bpf_trace_printk: [eBPF] IP6: Parts 1+2 (0xfe800000 0x0)
  // bpf_trace_printk: [eBPF] IP6: Parts 3+4 (0xc87facff 0xfe69287a)
  ```
