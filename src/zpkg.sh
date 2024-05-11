#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/log/info.sh"
source "$(dirname "${BASH_SOURCE[0]}")/install.sh"
source "$(dirname "${BASH_SOURCE[0]}")/uninstall.sh"

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
