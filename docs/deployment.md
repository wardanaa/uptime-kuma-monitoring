# Deployment

## Initial Deployment

Create a local environment file:

```bash
cp .env.example .env
${EDITOR:-vi} .env
```

Review at least these values:

- `UPTIME_KUMA_IMAGE_TAG`
- `UPTIME_KUMA_HOST_BIND`
- `UPTIME_KUMA_HOST_PORT`
- `UPTIME_KUMA_DATA_DIR`
- `TZ`

Start the service:

```bash
docker compose --env-file .env up -d
docker compose --env-file .env ps
```

Open `http://127.0.0.1:3001` unless the host bind or port was changed.

## Environment Preparation

Ensure the deployment host has:

- Docker Engine and Docker Compose plugin installed.
- Enough disk space for `data/` and `backups/`.
- A protected location for `.env`.
- A backup destination with appropriate access controls.

The first startup creates runtime data under `UPTIME_KUMA_DATA_DIR`.

## Production Considerations

- Keep the Compose service bound to `127.0.0.1` when using a local reverse proxy.
- Terminate HTTPS at a reverse proxy such as Nginx, Caddy, Traefik, or a managed load balancer.
- Restrict direct access to the container port with firewall rules.
- Protect backups and `.env` with filesystem permissions.
- Review Uptime Kuma release notes before changing `UPTIME_KUMA_IMAGE_TAG`.

## Reverse Proxy and HTTPS

Production deployments should expose HTTPS through a reverse proxy. The proxy must preserve WebSocket upgrades and forward standard headers such as `Host`, `X-Forwarded-For`, and `X-Forwarded-Proto`.

See [Reverse Proxy Examples](../examples/reverse-proxy/README.md).

## Upgrade Procedure

1. Review Uptime Kuma release notes for the target image tag.
2. Back up persistent data:

```bash
scripts/backup.sh
```

3. Update `UPTIME_KUMA_IMAGE_TAG` in `.env`.
4. Pull and restart:

```bash
docker compose --env-file .env pull uptime-kuma
docker compose --env-file .env up -d
docker compose --env-file .env ps
```

5. Verify login, monitors, notifications, and status pages.

## Rollback Procedure

1. Stop the service:

```bash
docker compose --env-file .env stop uptime-kuma
```

2. Set `UPTIME_KUMA_IMAGE_TAG` in `.env` back to the previous reviewed tag.
3. Start the service:

```bash
docker compose --env-file .env up -d
```

If the upgrade changed the database in an incompatible way, restore the backup created before the upgrade. See [Backup and Restore](backup-and-restore.md).

## Post-Deployment Verification

Run:

```bash
docker compose --env-file .env ps
docker compose --env-file .env logs --tail=100 uptime-kuma
scripts/validate.sh
```

Then verify:

- The web UI loads.
- Admin login works.
- Existing monitors are present.
- Notifications can be tested.
- Reverse-proxy HTTPS and WebSocket behavior works in production.
