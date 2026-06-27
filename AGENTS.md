# Agent Instructions

## Repository Purpose

This repository deploys and operates an Uptime Kuma monitoring service using Docker Compose. Keep the repository focused on deployment configuration, operational documentation, backup and restore tooling, and safe examples. Do not add application source code, unrelated infrastructure stacks, or private environment values.

## Important Files and Directories

- `compose.yaml` defines the Uptime Kuma service, persistent storage, network, ports, and health check.
- `.env.example` documents safe example values for every environment variable used by Compose and scripts.
- `data/` is the local persistent Uptime Kuma data directory. It may contain SQLite data, monitor targets, notification settings, status pages, and other sensitive operational state.
- `backups/` is the default local destination for backup archives and must remain untracked.
- `scripts/` contains Bash utilities for backup, restore, and validation.
- `docs/` contains operator documentation.
- `examples/reverse-proxy/` contains templates and guidance only; review before production use.

## Editing Rules

- Keep `compose.yaml` compatible with `docker compose --env-file .env.example config`.
- Do not hard-code secrets, real domains, tokens, private IPs, customer names, or production credentials.
- Update `.env.example` whenever a new environment variable is referenced.
- Update `README.md` and the relevant document under `docs/` whenever commands, paths, ports, backup behavior, or deployment behavior changes.
- Keep examples generic and clearly labeled as templates.
- Do not modify, delete, reformat, or commit files under `data/` except for `data/.gitkeep`.
- Do not commit `.env`, backup archives, logs, or generated runtime files.

## Shell Script Conventions

- Use Bash with `#!/usr/bin/env bash`.
- Enable strict mode with `set -Eeuo pipefail`.
- Resolve paths relative to the repository root, not the caller's current directory.
- Quote variables and paths.
- Validate required commands and input arguments before doing work.
- Print clear status and error messages.
- Require explicit confirmation or a `--force` option before destructive replacement.
- Prefer simple POSIX-compatible utilities where practical; do not require optional linters.

## Validation Before Completion

Run these commands before finishing changes:

```bash
docker compose --env-file .env.example config
bash -n scripts/*.sh
scripts/validate.sh
git check-ignore .env data/uptime-kuma.db backups/example.tar.gz
```

If Docker is unavailable, report that Compose validation could not be run and still run the remaining checks.

## Security Rules

- Treat Uptime Kuma data and backups as sensitive because they can contain monitor URLs, notification endpoints, credentials, incident history, and internal topology.
- Keep direct service binding on `127.0.0.1` unless deployment documentation explicitly explains the exposure model.
- Use HTTPS at the reverse proxy in production.
- Protect backup archives with restrictive filesystem permissions and storage controls outside this repository.
- Review image upgrades before changing `UPTIME_KUMA_IMAGE_TAG`.

## Completion Checklist

- `compose.yaml` renders with `.env.example`.
- Shell scripts pass `bash -n`.
- Documentation links point to existing files.
- `.env`, runtime data, and backup archives are ignored by Git.
- No real secrets or private infrastructure values are present.
- Any operational behavior change is documented in both `README.md` and the relevant `docs/` page.
