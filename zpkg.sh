#!/usr/bin/env bash
# {{{ source ../vendor/std/src/log/info.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/log/is_output.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/log/verbose.sh
#!/usr/bin/env bash
# get verbose level
function log::verbose() {
    echo "${LOG_VERBOSE:-0}"
}
# }}} source ../vendor/std/src/log/verbose.sh
# whether to output
function log::is_output() {
    local v="${1}"
    if [[ "${v}" -gt "$(log::verbose)" ]]; then
        return 1
    fi
}
# }}} source ../vendor/std/src/log/is_output.sh
# Print message to stderr with timestamp
function log::info() {
    local v="0"
    local key
    if [[ $# -gt 1 ]]; then
        key="${1}"
        case ${key} in
        -v | -v=*)
            [[ "${key#*=}" != "$key" ]] && v="${key#*=}" || { v="${2}" && shift; }
            if ! log::is_output "${v}" ; then
                return
            fi
            shift
            ;;
        *) ;;
        esac
    fi
    if [[ "${v}" -gt 0 ]]; then
        echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] INFO(${v}) ${*}" >&2
        return
    fi
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] INFO ${*}" >&2
}
# }}} source ../vendor/std/src/log/info.sh
# {{{ source install.sh
#!/usr/bin/env bash
# source ../vendor/std/src/log/info.sh # Embed file already embedded by zpkg.sh
# {{{ source ../vendor/std/src/http/download.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/runtime/command_exist.sh
#!/usr/bin/env bash
# Check a command exist
function runtime::command_exist() {
  local command="${1}"
  type "${command}" >/dev/null 2>&1
}
# }}} source ../vendor/std/src/runtime/command_exist.sh
# {{{ source ../vendor/std/src/log/error.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/runtime/stack_trace.sh
#!/usr/bin/env bash
function runtime::stack_trace() {
    local i=${1:-0}
    while caller $i; do
        ((i++))
    done | awk '{print  "[" NR "] " $3 ":" $1 " " $2}'
}
# }}} source ../vendor/std/src/runtime/stack_trace.sh
# Print error message and stack trace to stderr with timestamp
function log::error() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] ERROR ${*}" >&2
    runtime::stack_trace 1 >&2
}
# }}} source ../vendor/std/src/log/error.sh
# source ../vendor/std/src/log/info.sh # Embed file already embedded by zpkg.sh install.sh
# source ../vendor/std/src/log/is_output.sh # Embed file already embedded by ../vendor/std/src/log/info.sh
# Download a file from a URL
# curl or wget are used depending on the availability of curl or wget
function http::download() {
    local file="${1}"
    local url="${2}"
    local dir
    dir="$(dirname "${file}")"
    if [[ "${dir}" != "." ]] && [[ ! -d "${dir}" ]]; then
        log::info -v=1 "Creating directory ${dir}"
        mkdir -p "${dir}"
    fi
    if [[ -s "${file}" ]]; then
        log::info -v=1 "File ${file} already exists"
        return
    fi
    log::info -v=1 "Downloading ${url} to ${file}"
    if runtime::command_exist wget; then
        if log::is_output 4 ; then
            wget -O "${file}.tmp" "${url}"
        else
            wget -q -O "${file}.tmp" "${url}"
        fi
    elif runtime::command_exist curl; then
        if log::is_output 4 ; then
            curl -L -o "${file}.tmp" "${url}"
        else
            curl -sSL -o "${file}.tmp" "${url}"
        fi
    else
        log::error "Neither curl nor wget are available"
        exit 1
    fi
    mv "${file}.tmp" "${file}"
    log::info -v=1 "Downloaded ${url} to ${file}"
}
# }}} source ../vendor/std/src/http/download.sh
# {{{ source source.sh
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
# }}} source source.sh
# {{{ source destination.sh
#!/usr/bin/env bash
# Compute the destination for the given string
function zpkg::destination() {
    echo "/usr/local/zpkg/bin"
}
# }}} source destination.sh
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
# }}} source install.sh
# {{{ source uninstall.sh
#!/usr/bin/env bash
# source ../vendor/std/src/log/info.sh # Embed file already embedded by zpkg.sh install.sh ../vendor/std/src/http/download.sh
# source source.sh # Embed file already embedded by install.sh
# source destination.sh # Embed file already embedded by install.sh
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
# }}} source uninstall.sh
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    function usage() {
        echo "Usage: $0 [install|uninstall] [src]"
        echo
        echo "Options:"
        echo "  install   Install the package"
        echo "  uninstall Uninstall the package"
    }
    function main() {
    local cmd="$1"
    local src="$2"
    case "${cmd}" in
        install)
            zpkg::install "${src}"
            ;;
        uninstall)
            zpkg::uninstall "${src}"
            ;;
        *)
            echo "Usage: $0 [install|uninstall] [src]"
            ;;
    esac
}
    main "$@"
fi

#
# ../vendor/std/src/log/verbose.sh is quoted by ../vendor/std/src/log/is_output.sh
# source.sh is quoted by install.sh uninstall.sh
# ../vendor/std/src/http/download.sh is quoted by install.sh
# ../vendor/std/src/runtime/command_exist.sh is quoted by ../vendor/std/src/http/download.sh
# ../vendor/std/src/log/is_output.sh is quoted by ../vendor/std/src/log/info.sh ../vendor/std/src/http/download.sh
# ../vendor/std/src/runtime/stack_trace.sh is quoted by ../vendor/std/src/log/error.sh
# ../vendor/std/src/log/error.sh is quoted by ../vendor/std/src/http/download.sh
# uninstall.sh is quoted by zpkg.sh
# ../vendor/std/src/log/info.sh is quoted by zpkg.sh install.sh ../vendor/std/src/http/download.sh uninstall.sh
# install.sh is quoted by zpkg.sh
# destination.sh is quoted by install.sh uninstall.sh
