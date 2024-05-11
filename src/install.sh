#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/log/info.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/http/download.sh"
source "$(dirname "${BASH_SOURCE[0]}")/source.sh"
source "$(dirname "${BASH_SOURCE[0]}")/destination.sh"

# Install the package
function zpkg::install() {
    local src="$1"
    local dest
    dest="$(zpkg::destination)"

    if [[ -z "${src}" ]]; then
        echo "src is required"
        return 1
    fi

    if [[ -z "${dest}" ]]; then
        echo "dest is required"
        return 1
    fi

    local url
    url="$(zpkg::source "${src}")"
    if [[ -z "${url}" ]]; then
        echo "get source url failed"
        return 1
    fi

    local bin
    bin="${dest}/$(basename "${src}")"
    if [[ -f "${bin}" ]]; then
        echo "file ${bin} already exists"
        return 1
    fi

    http::download "${bin}" "${url}"
    chmod +x "${bin}"

    log::info "install ${src} to ${dest}"
    return 0
}
