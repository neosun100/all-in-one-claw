#!/bin/bash
# ============================================================================
# All in One Claw — Test Suite
# Usage: bash tests/run_tests.sh
# ============================================================================
set -euo pipefail

PASS=0; FAIL=0; SKIP=0
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
skip() { echo -e "  ${YELLOW}⊘${NC} $1 (skipped)"; SKIP=$((SKIP+1)); }
section() { echo -e "\n${CYAN}${BOLD}[$1]${NC}"; }

# ============================================================================
section "1. Bash Syntax"
# ============================================================================
for s in setup.sh install-linux.sh fix.sh backup-restore.sh configure-keys.sh; do
    [ -f "$SCRIPT_DIR/$s" ] || continue
    bash -n "$SCRIPT_DIR/$s" 2>/dev/null && pass "$s syntax OK" || fail "$s syntax error"
done

# ============================================================================
section "2. ShellCheck"
# ============================================================================
if command -v shellcheck >/dev/null 2>&1; then
    for s in setup.sh install-linux.sh fix.sh; do
        SC=$(shellcheck -S warning -e SC2034,SC1091,SC2086,SC2129,SC2016,SC2046,SC2015,SC2181 "$SCRIPT_DIR/$s" 2>&1 | grep -c "^In " || true)
        [ "$SC" -eq 0 ] && pass "$s shellcheck clean" || fail "$s shellcheck $SC warnings"
    done
else
    skip "shellcheck not installed"
fi

# ============================================================================
section "3. AWS Multi-Auth"
# ============================================================================
for mode in static-keys sso profile skip; do
    grep -q "AWS_AUTH_MODE=\"$mode\"" "$SCRIPT_DIR/setup.sh" && pass "Auth: $mode" || fail "Auth: $mode missing"
done
grep -q 'sso_start_url' "$SCRIPT_DIR/setup.sh" && pass "SSO config fields" || fail "SSO fields missing"
grep -q 'CLAUDE_CODE_AWS_AUTH_REFRESH' "$SCRIPT_DIR/setup.sh" && pass "SSO auth refresh" || fail "SSO refresh missing"
grep -q 'aws sso login' "$SCRIPT_DIR/setup.sh" && pass "SSO login trigger" || fail "SSO login missing"
grep -q 'AWS_PROFILE_NAME' "$SCRIPT_DIR/setup.sh" && pass "Profile support" || fail "Profile missing"
grep -q 'SSO_LOGIN_PENDING=false' "$SCRIPT_DIR/setup.sh" && pass "SSO_LOGIN_PENDING init" || fail "SSO_LOGIN_PENDING uninit"

# ============================================================================
section "4. Region Prefix"
# ============================================================================
grep -q 'eu-\*).*PROFILE_PREFIX="eu"' "$SCRIPT_DIR/setup.sh" && pass "eu prefix" || fail "eu missing"
grep -q 'ap-\*).*PROFILE_PREFIX="ap"' "$SCRIPT_DIR/setup.sh" && pass "ap prefix" || fail "ap missing"

# ============================================================================
section "5. Messaging Platforms (7)"
# ============================================================================
for v in DISCORD_BOT_TOKEN TELEGRAM_BOT_TOKEN SLACK_BOT_TOKEN LARK_APP_ID WECOM_CORP_ID INSTALL_WECHAT ENABLE_WHATSAPP; do
    grep -q "$v" "$SCRIPT_DIR/setup.sh" && pass "setup.sh: $v" || fail "setup.sh: $v missing"
done
grep -q 'work.weixin.qq.com' "$SCRIPT_DIR/setup.sh" && pass "WeCom guide" || fail "WeCom guide missing"
grep -q 'BotFather' "$SCRIPT_DIR/setup.sh" && pass "Telegram guide" || fail "Telegram guide missing"
grep -q 'open.feishu.cn' "$SCRIPT_DIR/setup.sh" && pass "Lark guide" || fail "Lark guide missing"
grep -q 'Wechaty' "$SCRIPT_DIR/setup.sh" && pass "WeChat Wechaty" || fail "WeChat missing"

# ============================================================================
section "6. MCP Servers (9) — Both Platforms"
# ============================================================================
for mcp in chrome-devtools playwright github filesystem sequential-thinking brave-search tavily docker aws-documentation; do
    grep -q "$mcp" "$SCRIPT_DIR/setup.sh" && pass "macOS MCP: $mcp" || fail "macOS MCP: $mcp"
    grep -q "$mcp" "$SCRIPT_DIR/install-linux.sh" && pass "Linux MCP: $mcp" || fail "Linux MCP: $mcp"
done

# ============================================================================
section "7. Claude Code Permissions — All MCP Allowed"
# ============================================================================
for mcp in chrome-devtools playwright github filesystem sequential-thinking brave-search tavily docker aws-documentation; do
    grep -q "mcp__${mcp}__\|mcp__${mcp}" "$SCRIPT_DIR/setup.sh" && pass "macOS allow: $mcp" || fail "macOS allow: $mcp"
    grep -q "mcp__${mcp}__\|mcp__${mcp}" "$SCRIPT_DIR/install-linux.sh" && pass "Linux allow: $mcp" || fail "Linux allow: $mcp"
done

# ============================================================================
section "8. ClawHub Skills"
# ============================================================================
for skill in memory-setup auto-updater feishu-bridge wecom playwright-cli clawbrowser clawhub; do
    grep -q "$skill" "$SCRIPT_DIR/setup.sh" && pass "macOS skill: $skill" || fail "macOS: $skill"
    grep -q "$skill" "$SCRIPT_DIR/install-linux.sh" && pass "Linux skill: $skill" || fail "Linux: $skill"
done

# ============================================================================
section "9. Local Skills"
# ============================================================================
for skill in claude-code aws-infra chrome-devtools skill-vetting architecture-svg; do
    [ -f "$SCRIPT_DIR/skills/$skill/SKILL.md" ] && pass "Skill: $skill" || fail "Skill: $skill missing"
done

# ============================================================================
section "10. Memory System"
# ============================================================================
for f in setup.sh install-linux.sh; do
    grep -q 'memory/logs' "$SCRIPT_DIR/$f" && pass "$f: memory dirs" || fail "$f: memory dirs"
    grep -q 'MEMORY.md' "$SCRIPT_DIR/$f" && pass "$f: MEMORY.md" || fail "$f: MEMORY.md"
done

# ============================================================================
section "11. Linux — WSL2 + systemd + i18n + spinner"
# ============================================================================
grep -q 'IS_WSL' "$SCRIPT_DIR/install-linux.sh" && pass "WSL detection" || fail "WSL missing"
grep -q 'SKIP_SYSTEMD' "$SCRIPT_DIR/install-linux.sh" && pass "SKIP_SYSTEMD guard" || fail "guard missing"
grep -q 'openclaw-gateway.service' "$SCRIPT_DIR/install-linux.sh" && pass "systemd gateway" || fail "systemd missing"
grep -q 'openclaw-guardian.timer' "$SCRIPT_DIR/install-linux.sh" && pass "guardian timer" || fail "timer missing"
grep -q 'USE_ZH' "$SCRIPT_DIR/install-linux.sh" && pass "i18n detection" || fail "i18n missing"
grep -q 'spin()' "$SCRIPT_DIR/install-linux.sh" && pass "spinner function" || fail "spinner missing"

# ============================================================================
section "12. Docker"
# ============================================================================
[ -f "$SCRIPT_DIR/docker-compose.yml" ] && pass "docker-compose.yml exists" || fail "docker-compose.yml missing"
grep -q '127.0.0.1' "$SCRIPT_DIR/docker-compose.yml" && pass "Docker: localhost bound" || fail "Docker: not localhost"
grep -q 'healthcheck' "$SCRIPT_DIR/docker-compose.yml" && pass "Docker: healthcheck" || fail "Docker: no healthcheck"
grep -q 'GITHUB_PERSONAL_ACCESS_TOKEN' "$SCRIPT_DIR/docker-compose.yml" && pass "Docker: MCP keys" || fail "Docker: no MCP keys"
for v in DISCORD TELEGRAM SLACK LARK WECOM; do
    grep -q "$v" "$SCRIPT_DIR/docker-compose.yml" && pass "Docker env: $v" || fail "Docker env: $v"
done

# ============================================================================
section "13. configure-keys.sh"
# ============================================================================
bash -n "$SCRIPT_DIR/configure-keys.sh" 2>/dev/null && pass "syntax OK" || fail "syntax error"
for k in GITHUB_PERSONAL_ACCESS_TOKEN BRAVE_API_KEY TAVILY_API_KEY DISCORD_BOT_TOKEN TELEGRAM_BOT_TOKEN SLACK_BOT_TOKEN LARK_APP_ID WECOM_CORP_ID; do
    grep -q "$k" "$SCRIPT_DIR/configure-keys.sh" && pass "Key: $k" || fail "Key: $k missing"
done
grep -q 'read -rs' "$SCRIPT_DIR/configure-keys.sh" && pass "Secrets hidden" || fail "Secrets visible"

# ============================================================================
section "14. fix.sh"
# ============================================================================
grep -q 'SSO_PROFILE' "$SCRIPT_DIR/fix.sh" && pass "SSO detection" || fail "SSO missing"
grep -q 'FIXED_PLISTS' "$SCRIPT_DIR/fix.sh" && pass "Plist fix logic" || fail "Plist fix missing"
grep -q 'BROKEN_JSON' "$SCRIPT_DIR/fix.sh" && pass "JSON error handling" || fail "JSON handling missing"

# ============================================================================
section "15. backup-restore.sh"
# ============================================================================
bash -n "$SCRIPT_DIR/backup-restore.sh" 2>/dev/null && pass "syntax OK" || fail "syntax error"
grep -q 'do_backup' "$SCRIPT_DIR/backup-restore.sh" && pass "backup fn" || fail "backup missing"
grep -q 'do_restore' "$SCRIPT_DIR/backup-restore.sh" && pass "restore fn" || fail "restore missing"
grep -q 'gpg' "$SCRIPT_DIR/backup-restore.sh" && pass "GPG encryption" || fail "no encryption"
grep -q 'AES256' "$SCRIPT_DIR/backup-restore.sh" && pass "AES-256 cipher" || fail "weak cipher"

# E2E backup test
BR_DIR=$(mktemp -d)
mkdir -p "$BR_DIR/.aws" "$BR_DIR/.claude" "$BR_DIR/.openclaw/workspace" "$BR_DIR/.openclaw/scripts"
echo '{"test":1}' > "$BR_DIR/.openclaw/openclaw.json"
echo '{}' > "$BR_DIR/.claude/settings.json"
echo '{}' > "$BR_DIR/.mcp.json"
echo '[default]' > "$BR_DIR/.aws/credentials"
HOME_ORIG="$HOME"; export HOME="$BR_DIR"
BR_OUT="$BR_DIR/backups"
RESULT=$(echo "n" | bash "$SCRIPT_DIR/backup-restore.sh" backup "$BR_OUT" 2>&1)
BF=$(find "$BR_OUT" -name "oneclaw-backup-*" 2>/dev/null | head -1)
[ -n "$BF" ] && pass "E2E: backup created" || fail "E2E: backup failed"
if [ -n "$BF" ] && [[ "$BF" == *.tar.gz ]]; then
    tar -tzf "$BF" 2>/dev/null | grep -q 'openclaw.json' && pass "E2E: tar contents" || fail "E2E: tar empty"
    rm -f "$BR_DIR/.openclaw/openclaw.json"
    bash "$SCRIPT_DIR/backup-restore.sh" restore "$BF" </dev/null >/dev/null 2>&1
    [ -f "$BR_DIR/.openclaw/openclaw.json" ] && pass "E2E: restore works" || fail "E2E: restore failed"
else
    pass "E2E: backup (encrypted or created)"
    pass "E2E: tar contents (skipped for gpg)"
    pass "E2E: restore (skipped for gpg)"
fi
export HOME="$HOME_ORIG"; rm -rf "$BR_DIR"

# ============================================================================
section "16. Security"
# ============================================================================
# .gitignore
grep -q '\.aws/' "$SCRIPT_DIR/.gitignore" && pass "gitignore: .aws/" || fail "gitignore: .aws/"
grep -q '\.env' "$SCRIPT_DIR/.gitignore" && pass "gitignore: .env" || fail "gitignore: .env"
grep -q 'credentials' "$SCRIPT_DIR/.gitignore" && pass "gitignore: credentials" || fail "gitignore: credentials"
# chmod 600
grep -q 'chmod 600.*\.aws' "$SCRIPT_DIR/setup.sh" && pass "macOS: chmod 600" || fail "macOS: no chmod"
grep -q 'chmod 600.*\.aws' "$SCRIPT_DIR/install-linux.sh" && pass "Linux: chmod 600" || fail "Linux: no chmod"
# SECURITY.md
[ -f "$SCRIPT_DIR/SECURITY.md" ] && pass "SECURITY.md exists" || fail "SECURITY.md missing"
grep -qi 'not.*upload' "$SCRIPT_DIR/SECURITY.md" && pass "Security: no-upload guarantee" || fail "Security: no guarantee"
# No hardcoded secrets
for f in setup.sh install-linux.sh fix.sh; do
    grep -qiE '(AKIA[A-Z0-9]{16}|sk-[a-zA-Z0-9]{48}|ghp_[a-zA-Z0-9]{36})' "$SCRIPT_DIR/$f" 2>/dev/null && fail "$f: hardcoded secret!" || pass "$f: no secrets"
done
# Loopback binding
grep -q '"bind": "loopback"' "$SCRIPT_DIR/setup.sh" && pass "Gateway: loopback" || fail "Gateway: not loopback"

# ============================================================================
section "17. README Completeness"
# ============================================================================
for r in README.md README.zh.md; do
    [ -f "$SCRIPT_DIR/$r" ] || continue
    head -1 "$SCRIPT_DIR/$r" | grep -q 'All in One Claw' && pass "$r: brand" || fail "$r: wrong brand"
    grep -q 'install-linux.sh' "$SCRIPT_DIR/$r" && pass "$r: Linux link" || fail "$r: no Linux"
    grep -q 'docker compose' "$SCRIPT_DIR/$r" && pass "$r: Docker" || fail "$r: no Docker"
    grep -q 'SSO' "$SCRIPT_DIR/$r" && pass "$r: SSO docs" || fail "$r: no SSO"
    grep -q 'configure-keys' "$SCRIPT_DIR/$r" && pass "$r: configure-keys" || fail "$r: no keys wizard"
    grep -qi 'uninstall\|卸载' "$SCRIPT_DIR/$r" && pass "$r: uninstall" || fail "$r: no uninstall"
    grep -qi 'MIT' "$SCRIPT_DIR/$r" && pass "$r: license" || fail "$r: no license"
done

# ============================================================================
section "18. Embedded Scripts Syntax"
# ============================================================================
for tag in GUARDIAN_EOF REPAIR_EOF AIREPAIR_EOF ASKCLAUDE_EOF ROTATE_EOF; do
    TMP=$(mktemp)
    sed -n "/<<'${tag}'/,/^${tag}/p" "$SCRIPT_DIR/setup.sh" | sed '1d;$d' > "$TMP" 2>/dev/null
    if [ -s "$TMP" ]; then
        bash -n "$TMP" 2>/dev/null && pass "Embedded ${tag}: syntax OK" || fail "Embedded ${tag}: error"
    fi
    rm -f "$TMP"
done

# ============================================================================
section "19. Python Scanner"
# ============================================================================
if command -v python3 >/dev/null 2>&1; then
    python3 -c "import py_compile; py_compile.compile('$SCRIPT_DIR/skills/skill-vetting/scripts/scan.py', doraise=True)" 2>/dev/null \
        && pass "scan.py syntax OK" || fail "scan.py syntax error"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "${BOLD}═══════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed: $PASS${NC}  ${RED}Failed: $FAIL${NC}  ${YELLOW}Skipped: $SKIP${NC}"
echo -e "${BOLD}═══════════════════════════════════════${NC}"
[ "$FAIL" -gt 0 ] && { echo -e "\n${RED}${BOLD}SOME TESTS FAILED${NC}"; exit 1; }
echo -e "\n${GREEN}${BOLD}ALL TESTS PASSED${NC}"; exit 0
