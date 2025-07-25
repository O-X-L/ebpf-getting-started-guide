#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p ./build/

echo '### PREPARING.. ###'
docker build -t ebpf-go-builder -f ./docker/Dockerfile_build_go .

# see also: "//go:generate" in main.go
docker run --rm -v "$(pwd)":/repo ebpf-go-builder /bin/bash -c "\
    bpftool btf dump file /sys/kernel/btf/vmlinux format c > /repo/build/vmlinux.h && \
    cd /repo/src/ebpf-go && \
    go mod tidy && \
    go generate && \
    bash /repo/scripts/build_go_archs.sh"

echo '### DONE ###'
ls -l ./build/
