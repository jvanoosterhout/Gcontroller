#!/usr/bin/env bash
# Renders a WireViz YAML file via a Kroki server and saves the result next to it.
set -euo pipefail

KROKI_URL="${KROKI_URL:-http://localhost:8000}"

usage() {
    echo "Usage: $0 <diagram.yml> [format ...]   (default formats: svg png)" >&2
    exit 1
}

[[ $# -ge 1 ]] || usage
src="$1"
shift
[[ -f "$src" ]] || { echo "No such file: $src" >&2; exit 1; }

formats=("$@")
[[ ${#formats[@]} -gt 0 ]] || formats=(svg)

source_dir="$(cd -- "$(dirname -- "$src")" && pwd)"
source_file="$(basename -- "$src")"
base="${source_file%.*}"
out_dir="${source_dir}/generated"
mkdir -p "$out_dir"
for fmt in "${formats[@]}"; do
    out="${out_dir}/${base}.${fmt}"
    curl -fsS -X POST "${KROKI_URL}/wireviz/${fmt}" \
        -H 'Content-Type: text/plain' \
        --data-binary "@${src}" \
        -o "$out"
    echo "wrote $out"
done
