#!/usr/bin/env bash
#
# Run the Metis flake checks.
#
# This script prefers a local Nix installation. When the nix command is not
# present, it falls back to the official nixos/nix image through Docker.

set -o errexit
set -o nounset
set -o pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NIX_IMAGE="nixos/nix:latest"

if command -v nix > /dev/null 2>&1; then
    nix --extra-experimental-features "nix-command flakes" \
        flake check "${REPOSITORY_ROOT}"
    echo "all checks passed"
    exit 0
fi

if ! command -v docker > /dev/null 2>&1; then
    echo "error: neither nix nor docker was found on the PATH" >&2
    exit 1
fi

docker run --rm \
    --volume "${REPOSITORY_ROOT}":/work \
    --workdir /work \
    "${NIX_IMAGE}" \
    sh -c '
        set -eu

        git config --global --add safe.directory /work

        NIX="nix --extra-experimental-features nix-command --extra-experimental-features flakes"

        echo "===== nix flake check ====="
        ${NIX} flake check

        echo "all checks passed"
    '
