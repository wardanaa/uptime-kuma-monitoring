# Reverse Proxy Examples

These examples are templates. Review and adapt them before production use. Do not copy them blindly into a public deployment.

## Deployment Model

Keep Uptime Kuma bound to localhost:

```env
UPTIME_KUMA_HOST_BIND=127.0.0.1
UPTIME_KUMA_HOST_PORT=3001
```

The reverse proxy terminates HTTPS and forwards traffic to `http://127.0.0.1:3001`.

## HTTPS Termination

Use a reverse proxy or managed load balancer to handle certificates and HTTPS. Certificate issuance and renewal are outside this repository.

Use placeholder hostnames in templates and replace them during deployment:

```text
status.example.invalid
```

## WebSocket Support

Uptime Kuma uses WebSockets for live UI updates. The proxy must support connection upgrades.

Nginx-style header requirements:

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

Caddy generally handles WebSockets automatically when using `reverse_proxy`:

```caddyfile
status.example.invalid {
    reverse_proxy 127.0.0.1:3001
}
```

## Forwarded Headers

Forward at least:

- `Host`
- `X-Forwarded-For`
- `X-Forwarded-Proto`

These headers help the application and logs understand the original request context.

## Restrict Direct Access

Do not expose the Compose port directly to the internet unless that is an intentional, reviewed deployment choice. Prefer:

- `UPTIME_KUMA_HOST_BIND=127.0.0.1`
- Host firewall rules that block direct remote access.
- Security group rules that only allow proxy-to-app traffic when using separate hosts.

## Trusted Proxy Considerations

Only trust forwarded headers from known proxies. If traffic can reach Uptime Kuma directly, clients may spoof forwarded headers. Keep the application listener private to the proxy path whenever possible.
