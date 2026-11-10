function claude() {
  local USE_PLAYWRIGHT=false
  local WORKSPACE="$PWD"
  local PLAYWRIGHT_ARGS=()
  local CLAUDE_ARGS=()

  # 1. Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --playwright)
        USE_PLAYWRIGHT=true
        shift
        ;;
      *)
        CLAUDE_ARGS+=("$1")
        shift
        ;;
    esac
  done

  # 2. Logic: Is the first non-flag argument a directory?
  if [ ${#CLAUDE_ARGS[@]} -gt 0 ] && [ -d "${CLAUDE_ARGS[0]}" ]; then
    echo "📂 Switching workspace to: ${CLAUDE_ARGS[0]}"
    WORKSPACE="${CLAUDE_ARGS[0]}"
    CLAUDE_ARGS=("${CLAUDE_ARGS[@]:1}")
  fi

  # 3. Ensure the 'claude' docker network exists
  if ! docker network inspect claude >/dev/null 2>&1; then
    docker network create claude >/dev/null
  fi

  # 4. Start Playwright MCP container if requested
  if [ "$USE_PLAYWRIGHT" = true ]; then
    echo "🎭 Starting Playwright MCP container..."
    docker run -d --rm \
      --name claude-playwright \
      --network claude \
      ${PLAYWRIGHT_ARGS[@]} \
      claude-playwright-image
    trap 'echo "🛑 Stopping Playwright MCP container..."; docker stop claude-playwright 2>/dev/null' EXIT
    echo "   MCP endpoint: http://claude-playwright:3000/sse"
    CLAUDE_ARGS+=(--mcp-config '{"mcpServers":{"playwright":{"type":"sse","url":"http://claude-playwright:3000/sse"}}}')
  fi

  # Ensure the top-level config file exists as a regular file before bind-mounting it,
  # otherwise Docker will create it as a directory and auth state won't persist.
  touch "$HOME/.claude.json"

  # 5. Run Secure Container
  docker run -it --rm \
    --name "claude-safe-$(echo "$WORKSPACE" | tr '/' '-')" \
    --network claude \
    -e HOST_UID=$(id -u) \
    -e HOST_GID=$(id -g) \
    -e NPM_CONFIG_UPDATE_NOTIFIER=false \
    -e COLORTERM=truecolor \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$WORKSPACE":"$WORKSPACE" \
    -w "$WORKSPACE" \
    -v "$HOME/.claude":/home/claudeuser/.claude \
    -v "$HOME/.claude.json":/home/claudeuser/.claude.json \
    -v "$HOME/.config/claude":/home/claudeuser/.config/claude/ \
    -v "$HOME/.local/share/claude/":/home/claudeuser/.local/share/claude \
    -v "$HOME/.gitconfig":/home/claudeuser/.gitconfig \
    -v "$HOME/.ssh":/home/claudeuser/.ssh:ro \
    claude-image "${CLAUDE_ARGS[@]}"
}