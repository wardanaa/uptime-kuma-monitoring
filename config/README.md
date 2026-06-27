# Configuration

This directory is reserved for reviewed configuration files that are safe to commit.

Do not store `.env`, credentials, notification tokens, TLS private keys, generated Uptime Kuma database files, or exported runtime state here. Most Uptime Kuma runtime configuration is managed inside the application and persisted under `data/`.

If future configuration files are added here, document:

- What service or process reads the file.
- Whether it is safe to commit.
- How to validate changes.
- Which operational document should be updated.
