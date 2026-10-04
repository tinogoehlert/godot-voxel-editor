#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
out="$here/builds/editor"

set -a
# shellcheck source=engine.env
source "$here/engine.env"
set +a

EDITOR_IMAGE="${EDITOR_IMAGE:-godot-voxel-editor:$GODOT_TAG}"
JOBS="${JOBS:-}"
platform=linux/amd64

usage() {
    cat <<EOF
Targets: editor-image editor linux-templates windows-templates windows-editor
Groups:  templates (linux + windows templates), all
  editor-image  build the base image $EDITOR_IMAGE only
  editor        Linux editor and GodotSharp into builds/editor/
EOF
}

editor_image() {
    docker build --platform "$platform" -f "$here/Dockerfile.editor" --target editor \
        --build-arg GODOT_TAG --build-arg VOXEL_COMMIT --build-arg JOBS \
        -t "$EDITOR_IMAGE" "$here"
}

export_stage() {
    local dockerfile=$1 stage=$2
    mkdir -p "$out"
    docker build --platform "$platform" -f "$here/$dockerfile" --target "$stage" \
        --build-arg EDITOR_IMAGE="$EDITOR_IMAGE" --build-arg JOBS \
        --output "type=local,dest=$out" "$here"
}

targets=("$@")
if [ ${#targets[@]} -eq 0 ]; then
    targets=(templates)
fi

expanded=()
for t in "${targets[@]}"; do
    case "$t" in
        templates) expanded+=(linux-templates windows-templates) ;;
        all) expanded+=(editor linux-templates windows-templates windows-editor) ;;
        editor-image|editor|linux-templates|windows-templates|windows-editor) expanded+=("$t") ;;
        *) echo "Unknown target: $t" >&2; usage >&2; exit 1 ;;
    esac
done

editor_image

for t in "${expanded[@]}"; do
    case "$t" in
        editor-image) ;;
        editor) export_stage Dockerfile.editor artifacts ;;
        *) export_stage Dockerfile.platforms "$t" ;;
    esac
done

echo "Done, output in builds/editor/"
