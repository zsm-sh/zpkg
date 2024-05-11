#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/log/info.sh"
source "$(dirname "${BASH_SOURCE[0]}")/source.sh"
source "$(dirname "${BASH_SOURCE[0]}")/destination.sh"

# Uninstall the package
function zpkg::uninstall() {
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

    rm -f "${bin}"
    log::info "uninstall ${src} from ${dest}"
    return 0
}
