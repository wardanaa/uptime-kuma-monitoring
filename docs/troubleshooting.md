# Troubleshooting

## Container Startup Failures

Check configuration and logs:

```bash
docker compose --env-file .env config
docker compose --env-file .env logs --tail=200 uptime-kuma
```

Common causes include invalid environment values, unavailable ports, missing data directory permissions, or a bad image tag.

## Port Conflicts

If startup reports that the port is already allocated, check what is listening:

```bash
lsof -nP -iTCP:3001 -sTCP:LISTEN
```

Change `UPTIME_KUMA_HOST_PORT` in `.env`, then run:

```bash
docker compose --env-file .env up -d
```

## Permission Errors

Permission errors usually involve `UPTIME_KUMA_DATA_DIR` or `BACKUP_DIR`.

Check ownership and access:

```bash
ls -ld data backups 2>/dev/null || true
```

Avoid broad permission changes until you understand which user owns the files and which process needs access.

## Unhealthy or Restarting Containers

Inspect status:

```bash
docker compose --env-file .env ps
docker inspect uptime-kuma --format '{{json .State.Health}}'
docker compose --env-file .env logs --tail=200 uptime-kuma
```

Review recent image changes, disk usage, and database errors.

## Missing Persistent Data

Confirm the data path:

```bash
grep '^UPTIME_KUMA_DATA_DIR=' .env
docker compose --env-file .env config
ls -la data
```

If `UPTIME_KUMA_DATA_DIR` changed, Uptime Kuma may have started with a new empty directory. Stop the service before moving data.

## Reverse Proxy Failures

Check:

- The proxy target uses the configured host and port.
- WebSocket upgrade headers are enabled.
- `Host`, `X-Forwarded-For`, and `X-Forwarded-Proto` are forwarded.
- Direct container access is not accidentally exposed.
- TLS certificates are valid and not expired.

See [Reverse Proxy Examples](../examples/reverse-proxy/README.md).

## Database or Storage Corruption Symptoms

Symptoms may include repeated startup failures, SQLite errors in logs, missing monitors, or inconsistent history.

Actions:

1. Stop Uptime Kuma.
2. Preserve the current `data/` directory before making changes.
3. Restore the most recent known-good backup into a non-production location if possible.
4. Restore production only after selecting a verified backup.

## Failed Upgrades

If an upgrade fails:

1. Read logs.
2. Stop the service.
3. Revert `UPTIME_KUMA_IMAGE_TAG` in `.env`.
4. Start the service.
5. Restore the pre-upgrade backup if the data format changed or the old version cannot read the current data.

## Backup and Restore Errors

Run syntax validation:

```bash
bash -n scripts/*.sh
```

Check archive integrity:

```bash
tar -tzf backups/uptime-kuma-data-YYYYmmdd-HHMMSS.tar.gz >/dev/null
```

Confirm that Uptime Kuma is stopped before restore:

```bash
docker compose --env-file .env ps
```
