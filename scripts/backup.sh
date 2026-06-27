#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

log() {
  printf '[backup] %s\n' "$*"
}

fail() {
  printf '[backup] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

load_env() {
  local env_file="${REPO_ROOT}/.env"
  if [[ ! -f "${env_file}" ]]; then
    env_file="${REPO_ROOT}/.env.example"
  fi

  [[ -f "${env_file}" ]] || fail "No .env or .env.example file found"
  set -a
  # shellcheck disable=SC1090
  source "${env_file}"
  set +a
}

absolute_path() {
  local path="$1"
  if [[ "${path}" = /* ]]; then
    printf '%s\n' "${path}"
  else
    printf '%s\n' "${REPO_ROOT}/${path#./}"
  fi
}

require_command tar
require_command date
require_command find

load_env

DATA_DIR="$(absolute_path "${UPTIME_KUMA_DATA_DIR:-./data}")"
DEST_DIR="$(absolute_path "${BACKUP_DIR:-./backups}")"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE_NAME="uptime-kuma-data-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${ARCHIVE_NAME}"

[[ -d "${DATA_DIR}" ]] || fail "Data directory does not exist: ${DATA_DIR}"
mkdir -p "${DEST_DIR}"
[[ ! -e "${ARCHIVE_PATH}" ]] || fail "Backup archive already exists: ${ARCHIVE_PATH}"

log "For the most consistent backup, stop Uptime Kuma before running this script."
log "Archiving ${DATA_DIR} to ${ARCHIVE_PATH}"

tar -czf "${ARCHIVE_PATH}" -C "$(dirname "${DATA_DIR}")" "$(basename "${DATA_DIR}")"

log "Backup created: ${ARCHIVE_PATH}"

if [[ "${RETENTION_DAYS}" =~ ^[0-9]+$ ]] && (( RETENTION_DAYS > 0 )); then
  log "Applying retention: deleting backups older than ${RETENTION_DAYS} days from ${DEST_DIR}"
  find "${DEST_DIR}" -maxdepth 1 -type f -name 'uptime-kuma-data-*.tar.gz' -mtime "+${RETENTION_DAYS}" -print -delete
else
  log "Retention skipped because BACKUP_RETENTION_DAYS is not a positive integer"
fi
