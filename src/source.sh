#!/usr/bin/env bash

# Compute the source for the given string
function zpkg::source() {
    local src="$1"

    if [[ -z "${src}" ]]; then
        echo "src is required"
        return 1
    fi

    local count=$(grep -o "/" <<< "${src}" | wc -l)
    local url

    if [[ "${count}" -eq 0 ]]; then
        url="https://github.com/zsm-sh/${src}/raw/main/${src}.sh"
    elif [[ "${count}" -eq 1 ]]; then
        url="https://github.com/zsm-sh/${src%%/*}/raw/main/${src##*/}.sh"
    else
        url="https://github.com/zsm-sh/${src%%/*}/raw/main/${src#*/}.sh"
    fi

    echo "${url}"
    return 0
}
