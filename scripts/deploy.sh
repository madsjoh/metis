#!/usr/bin/env bash
#
# Deploy the generated files produced by lib.build into a tool's config
# directory.
#
# This script mirrors the per-tool mapping encoded in the home-manager module
# in flake.nix, so people who do not use home-manager can install the same
# rendered tree by hand.
#
# Usage:
#   ./scripts/deploy.sh <opencode|claude|codex>
#
# The script refreshes the generated tree through scripts/dump.sh, then copies
# the managed entries into the target directory. Unrelated files already present
# at the target, such as opencode.jsonc, are left untouched.

set -o errexit
set -o nounset
set -o pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENERATED_DIRECTORY="${REPOSITORY_ROOT}/generated"

usage() {
    echo "usage: ${0##*/} <opencode|claude|codex>" >&2
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

TOOL="$1"

case "${TOOL}" in
    opencode)
        TARGET_DIRECTORY="${HOME}/.config/opencode"
        CONTEXT_NAME="AGENTS.md"
        MANAGED_DIRECTORIES=(agents commands plugins skills)
        ;;
    claude)
        TARGET_DIRECTORY="${HOME}/.claude"
        CONTEXT_NAME="CLAUDE.md"
        MANAGED_DIRECTORIES=(agents commands skills)
        ;;
    codex)
        TARGET_DIRECTORY="${HOME}/.codex"
        CONTEXT_NAME="AGENTS.md"
        MANAGED_DIRECTORIES=(agents commands skills)
        ;;
    *)
        echo "error: unknown tool '${TOOL}'" >&2
        usage
        exit 1
        ;;
esac

# Refresh the rendered tree so the deployment reflects the current build.
"${REPOSITORY_ROOT}/scripts/dump.sh"

if [ ! -d "${GENERATED_DIRECTORY}" ]; then
    echo "error: generated tree not found at ${GENERATED_DIRECTORY}" >&2
    exit 1
fi

# This script runs on the darwin host, whose BSD coreutils reject the GNU long
# options such as --parents, --recursive, and --force. The short POSIX flags
# used below work under both BSD and GNU coreutils, matching scripts/dump.sh.
mkdir -p "${TARGET_DIRECTORY}"

# Copy the context file.
rm -f "${TARGET_DIRECTORY}/${CONTEXT_NAME}"
cp "${GENERATED_DIRECTORY}/context.md" "${TARGET_DIRECTORY}/${CONTEXT_NAME}"

# Replace each managed directory wholesale, leaving unrelated entries in place.
for DIRECTORY in "${MANAGED_DIRECTORIES[@]}"; do
    SOURCE="${GENERATED_DIRECTORY}/${DIRECTORY}"
    if [ ! -d "${SOURCE}" ]; then
        echo "error: expected source directory ${SOURCE}" >&2
        exit 1
    fi
    rm -rf "${TARGET_DIRECTORY}/${DIRECTORY}"
    cp -R "${SOURCE}" "${TARGET_DIRECTORY}/${DIRECTORY}"
    chmod -R u+w "${TARGET_DIRECTORY}/${DIRECTORY}"
done

echo "deployed ${TOOL} config to ${TARGET_DIRECTORY}"
