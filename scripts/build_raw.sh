#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p ./build/

docker build -t ebpf-compiler -f ./docker/Dockerfile_build_raw .

docker run --rm -v "$(pwd)":/repo ebpf-compiler /bin/bash -c "\
    bpftool btf dump file /sys/kernel/btf/vmlinux format c > /repo/build/vmlinux.h && \
    clang -O2 -target bpf -c /repo/src/raw/xdp.c -o /repo/build/ebpf_mod_raw.o -I/repo/build -I/usr/include/bpf -I/usr/include/x86_64-linux-gnu -I/usr/include/linux -I/usr/include && \
    chmod 666 /repo/build/*"

echo 'DONE:'
ls -l "$(pwd)/build/ebpf_mod_raw"*
