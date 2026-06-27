# Security

## Secret Management

Do not commit `.env`, Uptime Kuma runtime data, exported databases, backup archives, notification tokens, webhook URLs, certificates, or private keys.

Use `.env.example` only for safe defaults and variable documentation.

## HTTPS and Reverse Proxy

Use HTTPS for production access. Terminate TLS at a reverse proxy or load balancer and forward traffic to the local Uptime Kuma port.

The reverse proxy must support WebSocket upgrades and preserve forwarded headers. See [Reverse Proxy Examples](../examples/reverse-proxy/README.md).

## Network Exposure

The default host bind is `127.0.0.1`. This prevents direct remote access to the container port and is appropriate when a local reverse proxy handles public traffic.

Use `0.0.0.0` only when firewall rules, cloud security groups, or other network controls intentionally restrict access.

## Authentication

- Use strong administrator credentials.
- Limit the number of users with administrative access.
- Review notification integrations and status-page exposure.
- Treat public status pages as public information unless access is restricted elsewhere.

## File Permissions

Protect `.env`, `data/`, and `backups/` on the host. Only trusted operators and the Docker runtime should be able to read them.

## Backup Protection

Backups can contain the same sensitive information as live data. Store backups in restricted locations, encrypt them when moved off-host, and test restore with sanitized or protected environments.

## Container Image Updates

Pin `UPTIME_KUMA_IMAGE_TAG` and review release notes before upgrades. Do not use `latest` for production because it makes rollbacks and change review harder.

## Least Privilege

Keep this Compose stack limited to Uptime Kuma. Do not add broad host mounts, Docker socket access, or privileged container settings unless a reviewed operational requirement exists.

## Public Exposure Risks

Publicly exposing Uptime Kuma can reveal service names, outage history, topology, and notification behavior. Review status pages, monitor names, and incident messages before making them public.
