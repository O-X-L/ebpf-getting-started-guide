#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

PATH_BASE="$(pwd)"
PATH_BUILD="${PATH_BASE}/build"
PATH_SRC="${PATH_BASE}/src/ebpf-go"

mkdir -p "$PATH_BUILD"

function compile() {
    os="$1"
    arch="$2"
    echo "### BUILDING ${os} ${arch} ###"
    CGO_ENABLED=0 GOOS="$os" GOARCH="$arch" go build -C "$PATH_SRC" -o "${PATH_BUILD}/ebpf_mod_go-${os}_${arch}" -buildvcs=false
}

compile "linux" "amd64"

# untested
compile "linux" "386"
compile "linux" "arm"
compile "linux" "arm64"

# compile "freebsd" "386"
# compile "freebsd" "amd64"
# compile "freebsd" "arm"

# compile "openbsd" "386"
# compile "openbsd" "amd64"
# compile "openbsd" "arm"

# compile "darwin" "amd64"
# compile "darwin" "arm64"

chmod 666 "${PATH_BUILD}/"*
