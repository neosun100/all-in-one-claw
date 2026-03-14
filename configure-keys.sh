#!/bin/bash
# ============================================================================
# All in One Claw — API Key Configuration Wizard
# ============================================================================
# Run after installation to configure API keys for MCP servers and services.
# Usage: bash configure-keys.sh
#
# This wizard lets you add/update API keys without re-running the full installer.
# Keys are written to ~/.mcp.json and environment configs.
# ============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

MCP_JSON="$HOME/.mcp.json"

echo -e "\n${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     All in One Claw — API Key Configuration      ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

if [ ! -f "$MCP_JSON" ]; then
    warn "~/.mcp.json not found. Please run the installer first."
    exit 1
fi

# Helper: update a key in .mcp.json env block
set_mcp_env() {
    local server="$1" key="$2" value="$3"
    python3 -c "
import json
with open('$MCP_JSON', 'r') as f:
    cfg = json.load(f)
servers = cfg.get('mcpServers', {})
if '$server' in servers:
    if 'env' not in servers['$server']:
        servers['$server']['env'] = {}
    servers['$server']['env']['$key'] = '$value'
    with open('$MCP_JSON', 'w') as f:
        json.dump(cfg, f, indent=2)
    print('OK')
else:
    print('SERVER_NOT_FOUND')
" 2>/dev/null
}

# Helper: read current value
get_mcp_env() {
    local server="$1" key="$2"
    python3 -c "
import json
with open('$MCP_JSON', 'r') as f:
    cfg = json.load(f)
val = cfg.get('mcpServers', {}).get('$server', {}).get('env', {}).get('$key', '')
print(val)
" 2>/dev/null
}

show_status() {
    local server="$1" key="$2" label="$3"
    local val
    val=$(get_mcp_env "$server" "$key")
    if [ -n "$val" ] && [ "$val" != "" ]; then
        echo -e "  ${GREEN}●${NC} $label: ${GREEN}configured${NC}"
    else
        echo -e "  ${YELLOW}○${NC} $label: ${YELLOW}not set${NC}"
    fi
}

configure_key() {
    local server="$1" key="$2" label="$3" url="$4"
    local current
    current=$(get_mcp_env "$server" "$key")
    if [ -n "$current" ] && [ "$current" != "" ]; then
        echo -e "  当前已配置: ${GREEN}${current:0:8}...${NC}"
        echo -en "  ${YELLOW}重新输入（按回车保留当前值）: ${NC}"
    else
        echo -e "  获取方式: ${CYAN}$url${NC}"
        echo -en "  ${YELLOW}请输入 $label: ${NC}"
    fi
    read -r value
    if [ -n "$value" ]; then
        set_mcp_env "$server" "$key" "$value"
        success "$label 已更新"
    else
        info "保留当前值"
    fi
}

echo -e "${BOLD}当前 API Key 状态：${NC}\n"
echo -e "  ${BOLD}— MCP 服务器 —${NC}"
show_status "github" "GITHUB_PERSONAL_ACCESS_TOKEN" "GitHub Token"
show_status "brave-search" "BRAVE_API_KEY" "Brave Search API Key"
show_status "tavily" "TAVILY_API_KEY" "Tavily API Key"

echo ""
echo -e "${BOLD}配置 API Keys（按回车跳过不需要的）：${NC}\n"

echo -e "${CYAN}${BOLD}— MCP 服务器 Keys —${NC}\n"

echo -e "${CYAN}1. GitHub Personal Access Token${NC}"
echo -e "   用途: GitHub MCP — 管理 PR、Issue、代码搜索"
configure_key "github" "GITHUB_PERSONAL_ACCESS_TOKEN" "GitHub Token" "https://github.com/settings/tokens → Generate new token (classic)"

echo ""
echo -e "${CYAN}2. Brave Search API Key${NC}"
echo -e "   用途: Brave Search MCP — 网页搜索"
configure_key "brave-search" "BRAVE_API_KEY" "Brave API Key" "https://brave.com/search/api/ → Get API Key"

echo ""
echo -e "${CYAN}3. Tavily API Key${NC}"
echo -e "   用途: Tavily MCP — AI 优化的网页搜索"
configure_key "tavily" "TAVILY_API_KEY" "Tavily API Key" "https://tavily.com → Sign up → API Key"

echo ""
echo -e "${CYAN}${BOLD}— 消息平台 Keys（写入 ~/.openclaw/openclaw.json 环境变量）—${NC}\n"
echo -e "  ${YELLOW}提示: 消息平台 token 在安装时已配置过的会自动跳过。${NC}"
echo -e "  ${YELLOW}如需修改，直接输入新值；按回车保留当前值。${NC}\n"

OPENCLAW_JSON="$HOME/.openclaw/openclaw.json"

# Helper: read/write env vars in gateway plist or openclaw env
read_env_file() {
    local key="$1"
    # Try LaunchAgent plist first (macOS)
    local plist="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
    if [ -f "$plist" ]; then
        python3 -c "
import plistlib
with open('$plist','rb') as f:
    pl = plistlib.load(f)
print(pl.get('EnvironmentVariables',{}).get('$key',''))
" 2>/dev/null
        return
    fi
    # Try systemd env (Linux)
    local svc="$HOME/.config/systemd/user/openclaw-gateway.service"
    if [ -f "$svc" ]; then
        grep "Environment=$key=" "$svc" 2>/dev/null | sed "s/.*$key=//" || echo ""
        return
    fi
    echo ""
}

configure_channel() {
    local key="$1" label="$2" url="$3"
    local current
    current=$(read_env_file "$key")
    if [ -n "$current" ]; then
        echo -e "  当前: ${GREEN}${current:0:12}...${NC}"
        echo -en "  ${YELLOW}重新输入（按回车保留）: ${NC}"
    else
        echo -e "  获取: ${CYAN}$url${NC}"
        echo -en "  ${YELLOW}请输入 $label: ${NC}"
    fi
    local hide=""
    [[ "$key" == *SECRET* || "$key" == *TOKEN* ]] && hide=true
    if [ "$hide" = "true" ]; then
        read -rs value; echo ""
    else
        read -r value
    fi
    if [ -n "$value" ]; then
        # Write to LaunchAgent plist if macOS
        local plist="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
        if [ -f "$plist" ]; then
            python3 -c "
import plistlib
with open('$plist','rb') as f:
    pl = plistlib.load(f)
if 'EnvironmentVariables' not in pl:
    pl['EnvironmentVariables'] = {}
pl['EnvironmentVariables']['$key'] = '$value'
with open('$plist','wb') as f:
    plistlib.dump(pl, f)
" 2>/dev/null
        fi
        success "$label 已更新（重启服务后生效）"
    else
        info "保留当前值"
    fi
}

echo -e "${CYAN}4. Discord Bot Token${NC}"
configure_channel "DISCORD_BOT_TOKEN" "Discord Token" "https://discord.com/developers/applications → Bot → Reset Token"

echo ""
echo -e "${CYAN}5. Telegram Bot Token${NC}"
configure_channel "TELEGRAM_BOT_TOKEN" "Telegram Token" "Telegram @BotFather → /newbot"

echo ""
echo -e "${CYAN}6. Slack Bot Token${NC}"
configure_channel "SLACK_BOT_TOKEN" "Slack Token" "https://api.slack.com/apps → OAuth → Bot Token"

echo ""
echo -e "${CYAN}7. 飞书/Lark App ID${NC}"
configure_channel "LARK_APP_ID" "Lark App ID" "https://open.feishu.cn/app → 创建应用"

echo ""
echo -e "${CYAN}8. 飞书/Lark App Secret${NC}"
configure_channel "LARK_APP_SECRET" "Lark App Secret" "同上 → 凭证与基础信息"

echo ""
echo -e "${CYAN}9. 企业微信 Corp ID${NC}"
configure_channel "WECOM_CORP_ID" "WeCom Corp ID" "https://work.weixin.qq.com → 企业信息"

echo ""
echo -e "${CYAN}10. 企业微信 Webhook URL${NC}"
configure_channel "WECOM_WEBHOOK_URL" "WeCom Webhook" "群聊 → 添加群机器人 → Webhook URL"

echo ""
echo -e "${BOLD}最终 MCP 状态：${NC}\n"
show_status "github" "GITHUB_PERSONAL_ACCESS_TOKEN" "GitHub Token"
show_status "brave-search" "BRAVE_API_KEY" "Brave Search API Key"
show_status "tavily" "TAVILY_API_KEY" "Tavily API Key"

echo ""
echo -e "${GREEN}${BOLD}配置完成！${NC}"
echo -e "  MCP keys: 重启 Claude Code 后生效"
echo -e "  消息平台: 重启 OpenClaw 服务后生效"
echo -e "    macOS: ${CYAN}bash ~/Documents/All\\ in\\ One\\ Claw/repair.command${NC}"
echo -e "    Linux: ${CYAN}systemctl --user restart openclaw-gateway${NC}"
echo ""
