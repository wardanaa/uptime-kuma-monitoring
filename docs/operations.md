# Operations

## Start and Stop

Start the service:

```bash
docker compose --env-file .env up -d
```

Stop the service:

```bash
docker compose --env-file .env down
```

Stop only the container while preserving the Compose network:

```bash
docker compose --env-file .env stop uptime-kuma
```

Start it again:

```bash
docker compose --env-file .env start uptime-kuma
```

## Check Health and Logs

```bash
docker compose --env-file .env ps
docker compose --env-file .env logs --tail=100 uptime-kuma
```

Follow logs:

```bash
docker compose --env-file .env logs -f uptime-kuma
```

## Restart Safely

```bash
docker compose --env-file .env restart uptime-kuma
docker compose --env-file .env ps
```

After restart, verify the UI and at least one notification channel if the restart followed an upgrade or configuration change.

## Review Disk Usage

Check repository data size:

```bash
du -sh data backups 2>/dev/null || true
```

Check Docker usage:

```bash
docker system df
```

Investigate unexpected growth before deleting anything.

## Update Container Image

1. Back up data:

```bash
scripts/backup.sh
```

2. Edit `UPTIME_KUMA_IMAGE_TAG` in `.env`.
3. Pull and recreate:

```bash
docker compose --env-file .env pull uptime-kuma
docker compose --env-file .env up -d
docker compose --env-file .env ps
```

## Basic Maintenance

- Confirm backups are being created and retained.
- Periodically test restore in a non-production location.
- Review monitor intervals and notification routing to reduce alert fatigue.
- Keep the host operating system and Docker patched.
- Review Uptime Kuma releases and security notes before upgrades.
