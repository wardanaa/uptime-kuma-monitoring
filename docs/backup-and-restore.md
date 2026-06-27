# Backup and Restore

## What to Back Up

Back up the configured Uptime Kuma data directory, `./data` by default. It contains the application database and runtime state. The data may include sensitive monitor targets, notification endpoints, credentials, status-page settings, and incident history.

## Backup Prerequisites

- `tar` must be available.
- The data directory must exist.
- The backup destination must have enough free space.
- The operator must protect backup archives from unauthorized access.

For the most consistent backup, stop Uptime Kuma before archiving:

```bash
docker compose --env-file .env stop uptime-kuma
scripts/backup.sh
docker compose --env-file .env start uptime-kuma
```

## Backup Procedure

Run:

```bash
scripts/backup.sh
```

The script creates a timestamped archive in `BACKUP_DIR`, defaulting to `./backups`.

If `BACKUP_RETENTION_DAYS` is a positive integer, old `uptime-kuma-data-*.tar.gz` archives in the backup directory are removed after a successful backup.

## Restore Warnings

Do not restore over an active Uptime Kuma instance. The restore script refuses to continue if the Compose service appears to be running.

Restoring replaces the configured data directory. The script moves existing data aside into a timestamped pre-restore directory when possible, but operators should still keep an independent backup before restore.

## Restore Procedure

Stop Uptime Kuma:

```bash
docker compose --env-file .env stop uptime-kuma
```

Restore an archive:

```bash
scripts/restore.sh backups/uptime-kuma-data-YYYYmmdd-HHMMSS.tar.gz --force
```

Start Uptime Kuma:

```bash
docker compose --env-file .env up -d
```

## Verification After Restore

Run:

```bash
docker compose --env-file .env ps
docker compose --env-file .env logs --tail=100 uptime-kuma
```

Then verify:

- The web UI loads.
- Login works.
- Monitors, notification channels, and status pages are present.
- Recent monitor history looks plausible.
- Notifications can be tested safely.

## Retention Recommendations

- Keep several recent local backups for fast rollback.
- Store production backups off-host or in a protected backup system.
- Encrypt backups when they leave the deployment host.
- Test restore periodically in a non-production environment.
