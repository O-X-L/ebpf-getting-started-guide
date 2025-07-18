# eBPF Getting-Started Guide

WARNING: This guide is still work-in-progress.

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

To run: `make build_go` or `bash scripts/build_go.sh`

Look into the script and `docker/Dockerfile_build_go` to get to know how it is done.
