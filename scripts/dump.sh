#!/usr/bin/env bash
#
# Dump the generated files produced by lib.build.
#
# This script performs three actions.
#   1. List the attribute names for agents, commands, and skills.
#   2. Print the resolved store paths for each entry.
#   3. Materialize the rendered tree into a local output directory.
#
# This script prefers a local Nix installation. When the nix command is not
# present, it falls back to the official nixos/nix image through Docker.

set -o errexit
set -o nounset
set -o pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NIX_IMAGE="nixos/nix:latest"
OUTPUT_DIRECTORY="${REPOSITORY_ROOT}/generated"
# The body runs inside either the host shell or the container. It expects NIX,
# FLAKE_REFERENCE, and TARGET_DIRECTORY to be set.
run_dump() {
    SETTINGS_EXPRESSION="
        let
          flake = builtins.getFlake \"${FLAKE_REFERENCE}\";
          pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
        in
          flake.lib.build { inherit pkgs; }
    "

    echo "===== attribute names ====="
    for CATEGORY in agents commands coreSkills superpowersSkills; do
        echo "--- ${CATEGORY} ---"
        ${NIX} eval --impure --raw --expr "
            builtins.concatStringsSep \"\n\" (builtins.attrNames (${SETTINGS_EXPRESSION}).${CATEGORY})
        "
        echo
    done

    echo "===== resolved store paths ====="
    for CATEGORY in agents commands coreSkills superpowersSkills; do
        echo "--- ${CATEGORY} ---"
        ${NIX} eval --impure --raw --expr "
            let category = (${SETTINGS_EXPRESSION}).${CATEGORY};
            in builtins.concatStringsSep \"\n\" (
              builtins.map (name: name + \" -> \" + builtins.toString category.\${name})
                (builtins.attrNames category)
            )
        "
        echo
    done

    echo "===== materialize rendered tree ====="
    RENDERED_PATH=$(${NIX} build --impure --no-link --print-out-paths --expr "
        let
          flake = builtins.getFlake \"${FLAKE_REFERENCE}\";
          pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
          settings = flake.lib.build { inherit pkgs; };
        in
          import ${FLAKE_SOURCE}/dump.nix { inherit pkgs settings; }
    ")

    rm --recursive --force "${TARGET_DIRECTORY}"
    mkdir --parents "${TARGET_DIRECTORY}"
    cp --recursive "${RENDERED_PATH}"/. "${TARGET_DIRECTORY}/"
    chmod --recursive u+w "${TARGET_DIRECTORY}"

    echo "wrote rendered tree to ${TARGET_DIRECTORY}"
}

if command -v nix > /dev/null 2>&1; then
    NIX="nix --extra-experimental-features nix-command --extra-experimental-features flakes"
    FLAKE_REFERENCE="git+file://${REPOSITORY_ROOT}"
    FLAKE_SOURCE="${REPOSITORY_ROOT}"
    TARGET_DIRECTORY="${OUTPUT_DIRECTORY}"
    run_dump
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
    sh -c "
        set -eu

        git config --global --add safe.directory /work

        NIX=\"nix --extra-experimental-features nix-command --extra-experimental-features flakes\"
        FLAKE_REFERENCE=\"git+file:///work\"
        FLAKE_SOURCE=/work
        TARGET_DIRECTORY=/work/generated

        $(declare -f run_dump)

        run_dump
    "
