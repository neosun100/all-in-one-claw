# Security & Privacy

## Credential Handling

All credentials stay **local on your machine**. Nothing is uploaded, transmitted, or logged.

| Credential | Storage Location | Protection |
|------------|-----------------|------------|
| AWS Access Key / Secret | `~/.aws/credentials` | chmod 600, never logged |
| AWS SSO tokens | `~/.aws/sso/cache/` | Managed by AWS CLI |
| Gateway Token | `~/.openclaw/openclaw.json` | Auto-generated, localhost-only |
| Discord/Telegram/Slack tokens | LaunchAgent env vars | Process-level, not on disk |
| Lark/WeCom credentials | LaunchAgent env vars | Process-level, not on disk |
| MCP API keys (GitHub/Brave/Tavily) | `~/.mcp.json` | chmod 600 recommended |

## What This Project Does NOT Do

- ❌ Does not upload any credentials to any server
- ❌ Does not include any hardcoded API keys or secrets
- ❌ Does not log secret values (all secret inputs use `read -s`)
- ❌ Does not expose services to the public internet (all ports bind 127.0.0.1)
- ❌ Does not store credentials in git-tracked files

## Network Security

- All services bind to `127.0.0.1` (loopback only)
- Gateway authentication via auto-generated token
- No inbound ports exposed to the internet
- TLS used for all external API calls (AWS, OpenClaw, ClawHub)

## Backup Security

`backup-restore.sh` offers GPG encryption (AES-256) for backups that contain `~/.aws/` credentials. Always encrypt backups before transferring them.

## Recommendations

1. **Use AWS SSO** instead of static keys when possible (credentials auto-expire)
2. **Run `chmod 600`** on `~/.aws/credentials`, `~/.mcp.json`, `~/.openclaw/openclaw.json`
3. **Encrypt backups** with GPG before storing or transferring
4. **Rotate tokens** periodically (Discord, Telegram, Slack, etc.)
5. **Use the skill-vetting scanner** before installing third-party ClawHub skills
6. **Never commit** `.aws/`, `.env`, or `*.pem` files to git

## Reporting Security Issues

If you find a security vulnerability, please open a private issue or contact the maintainer directly. Do not post credentials or exploit details publicly.
