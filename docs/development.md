# Development

Development in this repository means changing deployment files, scripts, examples, or documentation. It does not include modifying Uptime Kuma application code.

## Local Setup

```bash
cp .env.example .env
docker compose --env-file .env up -d
```

Open `http://127.0.0.1:3001` for local testing.

## Repository Conventions

- Keep environment-specific values in `.env`.
- Keep safe defaults and documented variables in `.env.example`.
- Keep persistent data in `data/`; do not commit it.
- Keep scripts portable Bash with strict mode.
- Keep docs aligned with actual commands and paths.

## Common Commands

Render Compose configuration:

```bash
docker compose --env-file .env.example config
```

Check scripts:

```bash
bash -n scripts/*.sh
```

Run repository validation:

```bash
scripts/validate.sh
```

Start or stop the local service:

```bash
docker compose --env-file .env up -d
docker compose --env-file .env down
```

## Testing Changes Safely

- Use `.env.example` when validating Compose syntax.
- Use `.env` only for local runtime tests.
- Do not run restore tests against important data.
- If restore behavior must be tested, point `UPTIME_KUMA_DATA_DIR` and `BACKUP_DIR` at temporary directories in a throwaway `.env`.
- Review Markdown links after moving or renaming docs.

## Documentation Updates

Update documentation in the same change when:

- A command changes.
- An environment variable changes.
- A script option changes.
- A path or directory purpose changes.
- Deployment or recovery behavior changes.
