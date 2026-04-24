#!/usr/bin/env bash

set -uo pipefail;

declare script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
declare base_path="${script_path%%\/bin}";
find "${base_path}" -name 'variables.tf' -exec sh -c 'terraform-docs markdown table --output-file README.md $(dirname "$1")' sh {} \;

# vim:set et ts=2 sw=2:
