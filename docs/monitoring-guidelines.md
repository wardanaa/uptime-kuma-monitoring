# Monitoring Guidelines

## Naming Conventions

Use names that identify the service, environment, and check type. Examples:

- `prod-api HTTP`
- `prod-db TCP`
- `campus-dns DNS`
- `public-status TLS`

Avoid names that expose secrets, private incident details, or unclear abbreviations.

## Monitor Grouping

Group monitors by environment, ownership, or service area. Keep production, staging, and development checks separate so notification rules and maintenance windows stay understandable.

## HTTP Monitoring

- Prefer HTTPS URLs for public services.
- Check expected status codes.
- Use keyword checks only when the content is stable.
- Avoid sending sensitive headers unless required and documented.

## TCP, Ping, DNS, and Certificate Monitoring

- Use TCP checks for service reachability when HTTP is unavailable.
- Use ping checks for broad host reachability, not application health.
- Use DNS checks for critical records and resolvers.
- Use certificate checks for public TLS endpoints and set alert thresholds early enough for renewal.

## Intervals and Retries

Choose intervals based on service criticality. Short intervals create faster detection but increase noise. Use retries to avoid alerting on brief network blips.

Suggested starting points:

- Critical production HTTP: 60 seconds with 2 to 3 retries.
- Internal or lower-priority services: 3 to 5 minutes.
- Certificate checks: 12 to 24 hours.
- DNS checks: 5 to 15 minutes unless faster detection is required.

## Notification Channels

- Route production alerts to actively monitored channels.
- Keep test notifications separate from production channels.
- Document who owns each notification channel.
- Test notification changes during a maintenance window when possible.

## Avoiding Alert Fatigue

- Alert only on actionable failures.
- Tune retries and intervals before adding more notification channels.
- Use maintenance windows for planned work.
- Review noisy monitors after incidents.

## Maintenance Windows

Use maintenance windows for planned deployments, network changes, certificate renewal, and host maintenance. Communicate windows through the same operational channels used for incidents.

## Status Pages

Status pages should use names and descriptions appropriate for their audience. Do not publish internal topology, private hostnames, or sensitive incident detail unless the page is intentionally restricted.

## Monitor Ownership

Document ownership for each monitor or monitor group:

- Owning team or person.
- Escalation channel.
- Expected response time.
- Related runbook or service documentation.

Keep ownership current when teams or services change.
