# All in One Claw — Test Documentation

- **Test runner**: `bash tests/run_tests.sh`
- **Total**: 19 categories, 156 test cases
- **Types**: Unit, Functional, E2E, Integration, Regression, Security

## How to Run

```bash
bash tests/run_tests.sh
```

## Latest Output

```

[1. Bash Syntax]
  ✓ setup.sh syntax OK
  ✓ install-linux.sh syntax OK
  ✓ fix.sh syntax OK
  ✓ backup-restore.sh syntax OK
  ✓ configure-keys.sh syntax OK

[2. ShellCheck]
  ✓ setup.sh shellcheck clean
  ✓ install-linux.sh shellcheck clean
  ✓ fix.sh shellcheck clean

[3. AWS Multi-Auth]
  ✓ Auth: static-keys
  ✓ Auth: sso
  ✓ Auth: profile
  ✓ Auth: skip
  ✓ SSO config fields
  ✓ SSO auth refresh
  ✓ SSO login trigger
  ✓ Profile support
  ✓ SSO_LOGIN_PENDING init

[4. Region Prefix]
  ✓ eu prefix
  ✓ ap prefix

[5. Messaging Platforms (7)]
  ✓ setup.sh: DISCORD_BOT_TOKEN
  ✓ setup.sh: TELEGRAM_BOT_TOKEN
  ✓ setup.sh: SLACK_BOT_TOKEN
  ✓ setup.sh: LARK_APP_ID
  ✓ setup.sh: WECOM_CORP_ID
  ✓ setup.sh: INSTALL_WECHAT
  ✓ setup.sh: ENABLE_WHATSAPP
  ✓ WeCom guide
  ✓ Telegram guide
  ✓ Lark guide
  ✓ WeChat Wechaty

[6. MCP Servers (9) — Both Platforms]
  ✓ macOS MCP: chrome-devtools
  ✓ Linux MCP: chrome-devtools
  ✓ macOS MCP: playwright
  ✓ Linux MCP: playwright
  ✓ macOS MCP: github
  ✓ Linux MCP: github
  ✓ macOS MCP: filesystem
  ✓ Linux MCP: filesystem
  ✓ macOS MCP: sequential-thinking
  ✓ Linux MCP: sequential-thinking
  ✓ macOS MCP: brave-search
  ✓ Linux MCP: brave-search
  ✓ macOS MCP: tavily
  ✓ Linux MCP: tavily
  ✓ macOS MCP: docker
  ✓ Linux MCP: docker
  ✓ macOS MCP: aws-documentation
  ✓ Linux MCP: aws-documentation

[7. Claude Code Permissions — All MCP Allowed]
  ✓ macOS allow: chrome-devtools
  ✓ Linux allow: chrome-devtools
  ✓ macOS allow: playwright
  ✓ Linux allow: playwright
  ✓ macOS allow: github
  ✓ Linux allow: github
  ✓ macOS allow: filesystem
  ✓ Linux allow: filesystem
  ✓ macOS allow: sequential-thinking
  ✓ Linux allow: sequential-thinking
  ✓ macOS allow: brave-search
  ✓ Linux allow: brave-search
  ✓ macOS allow: tavily
  ✓ Linux allow: tavily
  ✓ macOS allow: docker
  ✓ Linux allow: docker
  ✓ macOS allow: aws-documentation
  ✓ Linux allow: aws-documentation

[8. ClawHub Skills]
  ✓ macOS skill: memory-setup
  ✓ Linux skill: memory-setup
  ✓ macOS skill: auto-updater
  ✓ Linux skill: auto-updater
  ✓ macOS skill: feishu-bridge
  ✓ Linux skill: feishu-bridge
  ✓ macOS skill: wecom
  ✓ Linux skill: wecom
  ✓ macOS skill: playwright-cli
  ✓ Linux skill: playwright-cli
  ✓ macOS skill: clawbrowser
  ✓ Linux skill: clawbrowser
  ✓ macOS skill: clawhub
  ✓ Linux skill: clawhub

[9. Local Skills]
  ✓ Skill: claude-code
  ✓ Skill: aws-infra
  ✓ Skill: chrome-devtools
  ✓ Skill: skill-vetting
  ✓ Skill: architecture-svg

[10. Memory System]
  ✓ setup.sh: memory dirs
  ✓ setup.sh: MEMORY.md
  ✓ install-linux.sh: memory dirs
  ✓ install-linux.sh: MEMORY.md

[11. Linux — WSL2 + systemd + i18n + spinner]
  ✓ WSL detection
  ✓ SKIP_SYSTEMD guard
  ✓ systemd gateway
  ✓ guardian timer
  ✓ i18n detection
  ✓ spinner function

[12. Docker]
  ✓ docker-compose.yml exists
  ✓ Docker: localhost bound
  ✓ Docker: healthcheck
  ✓ Docker: MCP keys
  ✓ Docker env: DISCORD
  ✓ Docker env: TELEGRAM
  ✓ Docker env: SLACK
  ✓ Docker env: LARK
  ✓ Docker env: WECOM

[13. configure-keys.sh]
  ✓ syntax OK
  ✓ Key: GITHUB_PERSONAL_ACCESS_TOKEN
  ✓ Key: BRAVE_API_KEY
  ✓ Key: TAVILY_API_KEY
  ✓ Key: DISCORD_BOT_TOKEN
  ✓ Key: TELEGRAM_BOT_TOKEN
  ✓ Key: SLACK_BOT_TOKEN
  ✓ Key: LARK_APP_ID
  ✓ Key: WECOM_CORP_ID
  ✓ Secrets hidden

[14. fix.sh]
  ✓ SSO detection
  ✓ Plist fix logic
  ✓ JSON error handling

[15. backup-restore.sh]
  ✓ syntax OK
  ✓ backup fn
  ✓ restore fn
  ✓ GPG encryption
  ✓ AES-256 cipher
  ✓ E2E: backup created
  ✓ E2E: tar contents
  ✓ E2E: restore works

[16. Security]
  ✓ gitignore: .aws/
  ✓ gitignore: .env
  ✓ gitignore: credentials
  ✓ macOS: chmod 600
  ✓ Linux: chmod 600
  ✓ SECURITY.md exists
  ✓ Security: no-upload guarantee
  ✓ setup.sh: no secrets
  ✓ install-linux.sh: no secrets
  ✓ fix.sh: no secrets
  ✓ Gateway: loopback

[17. README Completeness]
  ✓ README.md: brand
  ✓ README.md: Linux link
  ✓ README.md: Docker
  ✓ README.md: SSO docs
  ✓ README.md: configure-keys
  ✓ README.md: uninstall
  ✓ README.md: license
  ✓ README.zh.md: brand
  ✓ README.zh.md: Linux link
  ✓ README.zh.md: Docker
  ✓ README.zh.md: SSO docs
  ✓ README.zh.md: configure-keys
  ✓ README.zh.md: uninstall
  ✓ README.zh.md: license

[18. Embedded Scripts Syntax]
  ✓ Embedded GUARDIAN_EOF: syntax OK
  ✓ Embedded REPAIR_EOF: syntax OK
  ✓ Embedded AIREPAIR_EOF: syntax OK
  ✓ Embedded ASKCLAUDE_EOF: syntax OK
  ✓ Embedded ROTATE_EOF: syntax OK

[19. Python Scanner]
  ✓ scan.py syntax OK

═══════════════════════════════════════
  Passed: 156  Failed: 0  Skipped: 0
═══════════════════════════════════════

ALL TESTS PASSED
```
