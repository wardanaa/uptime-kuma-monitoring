#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

log() {
  printf '[restore] %s\n' "$*"
}

fail() {
  printf '[restore] ERROR: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
Usage: scripts/restore.sh <backup-archive.tar.gz> --force

Restores Uptime Kuma data from a backup archive. The Uptime Kuma Compose service
must be stopped before restore. Existing data is moved aside before extraction.
USAGE
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

compose_service_running() {
  if ! command -v docker >/dev/null 2>&1; then
    return 1
  fi

  local container_id
  container_id="$(docker compose --env-file "${REPO_ROOT}/.env" ps -q uptime-kuma 2>/dev/null || true)"
  [[ -n "${container_id}" ]] || container_id="$(docker compose --env-file "${REPO_ROOT}/.env.example" ps -q uptime-kuma 2>/dev/null || true)"
  [[ -n "${container_id}" ]] || return 1

  local running_state
  running_state="$(docker inspect -f '{{.State.Running}}' "${container_id}" 2>/dev/null || true)"
  [[ "${running_state}" == "true" ]]
}

FORCE=false
ARCHIVE="${1:-}"

if [[ -z "${ARCHIVE}" ]]; then
  usage
  exit 2
fi

shift || true
for arg in "$@"; do
  case "${arg}" in
    --force)
      FORCE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: ${arg}"
      ;;
  esac
done

[[ "${FORCE}" == "true" ]] || fail "Restore is destructive. Re-run with --force after stopping Uptime Kuma."

require_command tar
require_command date

load_env

ARCHIVE_PATH="$(absolute_path "${ARCHIVE}")"
DATA_DIR="$(absolute_path "${UPTIME_KUMA_DATA_DIR:-./data}")"
PARENT_DIR="$(dirname "${DATA_DIR}")"
DATA_BASENAME="$(basename "${DATA_DIR}")"
PRE_RESTORE_DIR="${DATA_DIR}.pre-restore-$(date +%Y%m%d-%H%M%S)"

[[ -f "${ARCHIVE_PATH}" ]] || fail "Backup archive not found: ${ARCHIVE_PATH}"
[[ -r "${ARCHIVE_PATH}" ]] || fail "Backup archive is not readable: ${ARCHIVE_PATH}"

log "Validating archive: ${ARCHIVE_PATH}"
tar -tzf "${ARCHIVE_PATH}" >/dev/null || fail "Archive validation failed"

if compose_service_running; then
  fail "Uptime Kuma appears to be running. Stop it before restoring: docker compose --env-file .env stop uptime-kuma"
fi

mkdir -p "${PARENT_DIR}"

if [[ -e "${DATA_DIR}" ]]; then
  log "Moving existing data to ${PRE_RESTORE_DIR}"
  mv "${DATA_DIR}" "${PRE_RESTORE_DIR}"
fi

log "Extracting archive into ${PARENT_DIR}"
tar -xzf "${ARCHIVE_PATH}" -C "${PARENT_DIR}"

if [[ ! -d "${DATA_DIR}" ]]; then
  fail "Restore completed but expected data directory was not found: ${DATA_DIR}"
fi

log "Restore complete."
log "Start and verify with:"
log "  docker compose --env-file .env up -d"
log "  docker compose --env-file .env ps"
log "  docker compose --env-file .env logs --tail=100 uptime-kuma"
