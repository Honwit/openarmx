#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="$ROOT_DIR/repos"
WORKSPACES_DIR="$ROOT_DIR/workspaces"
MANIFEST_FILE="$ROOT_DIR/openarmx.repos"
VALID_WORKSPACES=(hw_ws sim_ws dev_ws)

usage() {
  cat <<'EOF'
Usage:
  ./setup_workspace.sh init
  ./setup_workspace.sh import
  ./setup_workspace.sh link <workspace> <repo> [repo...]
  ./setup_workspace.sh link-all <workspace>

Examples:
  ./setup_workspace.sh init
  ./setup_workspace.sh import
  ./setup_workspace.sh link hw_ws openarmx_teleop_bridge openarmx_bringup
  ./setup_workspace.sh link-all dev_ws
EOF
}

is_valid_workspace() {
  local workspace="$1"
  local candidate
  for candidate in "${VALID_WORKSPACES[@]}"; do
    if [[ "$candidate" == "$workspace" ]]; then
      return 0
    fi
  done
  return 1
}

ensure_layout() {
  mkdir -p "$REPOS_DIR"
  mkdir -p "$WORKSPACES_DIR/hw_ws/src"
  mkdir -p "$WORKSPACES_DIR/sim_ws/src"
  mkdir -p "$WORKSPACES_DIR/dev_ws/src"
}

import_repos() {
  if ! command -v vcs >/dev/null 2>&1; then
    echo "[ERROR] 'vcs' is not installed. Install python3-vcstool first."
    exit 2
  fi

  if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "[ERROR] Manifest not found: $MANIFEST_FILE"
    exit 2
  fi

  ensure_layout
  cd "$ROOT_DIR"
  vcs import "$REPOS_DIR" < "$MANIFEST_FILE"
}

link_repo() {
  local workspace="$1"
  local repo_name="$2"
  local repo_path="$REPOS_DIR/$repo_name"
  local src_dir="$WORKSPACES_DIR/$workspace/src"
  local link_path="$src_dir/$repo_name"

  if [[ ! -d "$repo_path" ]]; then
    echo "[ERROR] Repository not found: $repo_path"
    exit 2
  fi

  mkdir -p "$src_dir"
  rm -rf "$link_path"
  ln -s "$repo_path" "$link_path"
  echo "[INFO] Linked $repo_name -> $workspace"
}

link_all_repos() {
  local workspace="$1"
  local repo_path

  shopt -s nullglob
  for repo_path in "$REPOS_DIR"/*; do
    if [[ -d "$repo_path" ]]; then
      link_repo "$workspace" "$(basename "$repo_path")"
    fi
  done
  shopt -u nullglob
}

main() {
  local command="${1:-}"

  case "$command" in
    init)
      ensure_layout
      ;;
    import)
      import_repos
      ;;
    link)
      shift || true
      local workspace="${1:-}"
      if [[ -z "$workspace" ]] || ! is_valid_workspace "$workspace"; then
        usage
        exit 2
      fi
      shift || true
      if [[ "$#" -eq 0 ]]; then
        usage
        exit 2
      fi
      ensure_layout
      while [[ "$#" -gt 0 ]]; do
        link_repo "$workspace" "$1"
        shift
      done
      ;;
    link-all)
      shift || true
      local workspace="${1:-}"
      if [[ -z "$workspace" ]] || ! is_valid_workspace "$workspace"; then
        usage
        exit 2
      fi
      ensure_layout
      link_all_repos "$workspace"
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
