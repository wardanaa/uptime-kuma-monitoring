# Uptime Kuma Monitoring Repository

This repository contains a maintainable Docker Compose scaffold for running and operating an Uptime Kuma monitoring service. It provides deployment configuration, safe environment examples, operational scripts, and documentation for installation, maintenance, backup, recovery, security, troubleshooting, and contribution workflows.

Uptime Kuma data may contain sensitive operational information such as monitor URLs, notification endpoints, incident history, status-page configuration, and internal service names. Do not commit `.env`, `data/`, backups, logs, or generated runtime files.

## Features and Scope

- Docker Compose deployment using the official `louislam/uptime-kuma` image.
- Pinned image tag through `.env` rather than `latest`.
- Persistent local data directory mounted into the container.
- Localhost binding by default for safer reverse-proxy deployments.
- Backup, restore, and validation scripts.
- Operator documentation for deployment, operations, security, and troubleshooting.

This repository does not manage DNS, TLS certificates, firewall rules, external reverse-proxy installation, or Uptime Kuma monitor definitions as code.

## Prerequisites

- Docker Engine with the Docker Compose plugin.
- Bash.
- `tar`, `find`, and common Unix utilities for scripts.
- Git for repository validation.

## Quick Start

```bash
cp .env.example .env
docker compose --env-file .env up -d
docker compose --env-file .env ps
```

Open `http://127.0.0.1:3001` and complete the initial Uptime Kuma setup.

## Environment Setup

Review `.env` before starting the service:

```bash
cp .env.example .env
${EDITOR:-vi} .env
```

Important values:

- `UPTIME_KUMA_IMAGE_TAG` pins the Uptime Kuma image version.
- `UPTIME_KUMA_HOST_BIND` controls which host interface receives traffic.
- `UPTIME_KUMA_HOST_PORT` controls the host port.
- `UPTIME_KUMA_DATA_DIR` controls where persistent data is stored.
- `BACKUP_DIR` and `BACKUP_RETENTION_DAYS` control backup behavior.

Use `127.0.0.1` for `UPTIME_KUMA_HOST_BIND` when Uptime Kuma sits behind a local reverse proxy. Use `0.0.0.0` only when network exposure is intentionally controlled elsewhere.

## Common Commands

Start Uptime Kuma:

```bash
docker compose --env-file .env up -d
```

Stop Uptime Kuma:

```bash
docker compose --env-file .env down
```

Restart Uptime Kuma:

```bash
docker compose --env-file .env restart uptime-kuma
```

Inspect status:

```bash
docker compose --env-file .env ps
docker compose --env-file .env logs --tail=100 uptime-kuma
```

Validate configuration:

```bash
scripts/validate.sh
```

Update Uptime Kuma after reviewing release notes:

```bash
docker compose --env-file .env pull uptime-kuma
docker compose --env-file .env up -d
docker compose --env-file .env ps
```

Rollback to the previously reviewed image tag by editing `UPTIME_KUMA_IMAGE_TAG` in `.env`, then run:

```bash
docker compose --env-file .env up -d
```

## Repository Structure

```text
.
├── .env.example
├── .gitignore
├── AGENTS.md
├── README.md
├── compose.yaml
├── config/
│   └── README.md
├── data/
│   └── .gitkeep
├── docs/
├── examples/
│   └── reverse-proxy/
└── scripts/
```

## Persistent Data

Uptime Kuma stores runtime state in `/app/data` inside the container. This repository maps that path to `./data` by default through `UPTIME_KUMA_DATA_DIR`.

The `data/` directory is ignored by Git except for `data/.gitkeep`. Treat its contents as sensitive and back them up before upgrades, migrations, or host maintenance.

## Backup and Restore

Create a backup:

```bash
scripts/backup.sh
```

For the most consistent backup, stop Uptime Kuma first:

```bash
docker compose --env-file .env stop uptime-kuma
scripts/backup.sh
docker compose --env-file .env start uptime-kuma
```

Restore requires an explicit archive and `--force`:

```bash
docker compose --env-file .env stop uptime-kuma
scripts/restore.sh backups/uptime-kuma-data-YYYYmmdd-HHMMSS.tar.gz --force
docker compose --env-file .env up -d
```

See [Backup and Restore](docs/backup-and-restore.md) for the full procedure.

## Security Considerations

- Keep `UPTIME_KUMA_HOST_BIND=127.0.0.1` unless direct network exposure is intended.
- Put production deployments behind an HTTPS reverse proxy.
- Use strong Uptime Kuma credentials and protect administrator access.
- Store `.env`, backups, and runtime data outside version control.
- Review image releases before changing `UPTIME_KUMA_IMAGE_TAG`.

See [Security](docs/security.md) for operational guidance.

## Documentation

- [Architecture](docs/architecture.md)
- [Deployment](docs/deployment.md)
- [Development](docs/development.md)
- [Operations](docs/operations.md)
- [Backup and Restore](docs/backup-and-restore.md)
- [Security](docs/security.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Monitoring Guidelines](docs/monitoring-guidelines.md)
- [Reverse Proxy Examples](examples/reverse-proxy/README.md)

## Contribution and Maintenance

- Keep changes small and operationally focused.
- Update docs with every behavior, command, path, or environment change.
- Run `scripts/validate.sh` before handing off changes.
- Follow [AGENTS.md](AGENTS.md) when using coding agents.
