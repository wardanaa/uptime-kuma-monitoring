#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

log() {
  printf '[validate] %s\n' "$*"
}

warn() {
  printf '[validate] WARN: %s\n' "$*" >&2
}

fail() {
  printf '[validate] ERROR: %s\n' "$*" >&2
  exit 1
}

require_path() {
  [[ -e "${REPO_ROOT}/$1" ]] || fail "Missing expected path: $1"
}

check_expected_paths() {
  log "Checking expected files and directories"
  local paths=(
    ".env.example"
    ".gitignore"
    "AGENTS.md"
    "README.md"
    "compose.yaml"
    "config/README.md"
    "data/.gitkeep"
    "docs/architecture.md"
    "docs/backup-and-restore.md"
    "docs/deployment.md"
    "docs/development.md"
    "docs/monitoring-guidelines.md"
    "docs/operations.md"
    "docs/security.md"
    "docs/troubleshooting.md"
    "examples/reverse-proxy/README.md"
    "scripts/backup.sh"
    "scripts/restore.sh"
    "scripts/validate.sh"
  )

  local path
  for path in "${paths[@]}"; do
    require_path "${path}"
  done
}

check_compose() {
  if command -v docker >/dev/null 2>&1; then
    log "Validating Docker Compose configuration"
    docker compose --env-file "${REPO_ROOT}/.env.example" -f "${REPO_ROOT}/compose.yaml" config >/dev/null
  else
    warn "Docker is not available; skipping Docker Compose validation"
  fi
}

check_shell_scripts() {
  log "Checking shell script syntax"
  bash -n "${REPO_ROOT}"/scripts/*.sh
}

check_markdown_links() {
  log "Checking local Markdown links"
  local file link target clean_target base_dir
  while IFS= read -r file; do
    base_dir="$(dirname "${file}")"
    while IFS= read -r link; do
      [[ "${link}" =~ ^https?:// ]] && continue
      [[ "${link}" =~ ^mailto: ]] && continue
      [[ "${link}" =~ ^# ]] && continue
      [[ "${link}" =~ ^[A-Za-z][A-Za-z0-9+.-]*: ]] && continue

      clean_target="${link%%#*}"
      [[ -n "${clean_target}" ]] || continue

      if [[ "${clean_target}" = /* ]]; then
        target="${clean_target}"
      else
        target="${base_dir}/${clean_target}"
      fi

      [[ -e "${target}" ]] || fail "Broken Markdown link in ${file#${REPO_ROOT}/}: ${link}"
    done < <(grep -Eo '\[[^]]+\]\(([^)]+)\)' "${file}" | sed -E 's/^.*\(([^)]+)\)$/\1/' || true)
  done < <(find "${REPO_ROOT}" -path "${REPO_ROOT}/.git" -prune -o -name '*.md' -type f -print)
}

check_gitignore() {
  if ! command -v git >/dev/null 2>&1; then
    warn "Git is not available; skipping ignore-rule validation"
    return
  fi

  if [[ ! -d "${REPO_ROOT}/.git" ]]; then
    warn "Repository is not initialized; skipping git check-ignore validation"
    return
  fi

  log "Checking Git ignore rules"
  git -C "${REPO_ROOT}" check-ignore .env >/dev/null || fail ".env is not ignored"
  git -C "${REPO_ROOT}" check-ignore data/uptime-kuma.db >/dev/null || fail "data runtime files are not ignored"
  git -C "${REPO_ROOT}" check-ignore backups/example.tar.gz >/dev/null || fail "backup archives are not ignored"
}

check_secret_patterns() {
  log "Scanning for obvious accidental secrets"
  local matches
  matches="$(grep -RInE '(password|passwd|secret|token|api[_-]?key|private[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]#]+' \
    "${REPO_ROOT}/.env.example" \
    "${REPO_ROOT}/compose.yaml" \
    "${REPO_ROOT}/README.md" \
    "${REPO_ROOT}/AGENTS.md" \
    "${REPO_ROOT}/docs" \
    "${REPO_ROOT}/examples" \
    "${REPO_ROOT}/scripts" 2>/dev/null || true)"

  if [[ -n "${matches}" ]]; then
    warn "Potential secret-like assignments found; review output below"
    printf '%s\n' "${matches}" >&2
  fi
}

main() {
  cd "${REPO_ROOT}"
  check_expected_paths
  check_compose
  check_shell_scripts
  check_markdown_links
  check_gitignore
  check_secret_patterns
  log "Validation completed"
}

main "$@"
