#!/usr/bin/env bash
#
# Package each theme folder in this directory into a signed-ready XPI.
# For a folder named "ash", produces "nova-ash@mozilla.org.xpi" with
# the folder's contents (manifest.json, etc.) at the root of the archive.
#
# Usage:
#   ./build-xpi.sh            # package every theme folder
#   ./build-xpi.sh ash pine   # package only the named folders

set -euo pipefail

# Directory this script lives in.
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$root_dir"

# Determine which folders to package.
if [[ $# -gt 0 ]]; then
  targets=("$@")
else
  targets=()
  for dir in */; do
    [[ -f "${dir}manifest.json" ]] && targets+=("${dir%/}")
  done
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  echo "No theme folders found (looking for */manifest.json)." >&2
  exit 1
fi

for name in "${targets[@]}"; do
  name="${name%/}"

  if [[ ! -d "$name" ]]; then
    echo "Skipping '$name': not a directory." >&2
    continue
  fi
  if [[ ! -f "$name/manifest.json" ]]; then
    echo "Skipping '$name': no manifest.json." >&2
    continue
  fi

  xpi="$root_dir/nova-${name}@mozilla.org.xpi"
  rm -f "$xpi"

  # Zip from inside the folder so manifest.json sits at the archive root.
  ( cd "$name" && zip -r -X "$xpi" . -x '.*' )

  echo "Created nova-${name}@mozilla.org.xpi"
done
