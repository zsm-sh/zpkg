#!/usr/bin/env bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

kit "${CURRENT_DIR}/../vendor.kit"

embed --once=y "${CURRENT_DIR}/zpkg.sh" > "${CURRENT_DIR}/../zpkg.sh"
chmod +x "${CURRENT_DIR}/../zpkg.sh"
