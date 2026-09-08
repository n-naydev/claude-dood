function opencode() {
  local USE_PLAYWRIGHT=false
  local WORKSPACE="$PWD"
  local PLAYWRIGHT_ARGS=()
  local OPENCODE_ARGS=()

  # 1. Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --playwright)
        USE_PLAYWRIGHT=true
        shift
        ;;
      *)
        OPENCODE_ARGS+=("$1")
        shift
        ;;
    esac
  done

  # 2. Logic: Is the first non-flag argument a directory?
  if [ ${#OPENCODE_ARGS[@]} -gt 0 ] && [ -d "${OPENCODE_ARGS[0]}" ]; then
    echo "📂 Switching workspace to: ${OPENCODE_ARGS[0]}"
    WORKSPACE="${OPENCODE_ARGS[0]}"
    OPENCODE_ARGS=("${OPENCODE_ARGS[@]:1}")
  fi

  # 3. Ensure the 'opencode' docker network exists
  if ! docker network inspect opencode >/dev/null 2>&1; then
    docker network create opencode >/dev/null
  fi

  # 4. Start Playwright MCP container if requested
  if [ "$USE_PLAYWRIGHT" = true ]; then
    echo "🎭 Starting Playwright MCP container..."
    docker run -d --rm \
      --name opencode-playwright \
      --network opencode \
      ${PLAYWRIGHT_ARGS[@]} \
      opencode-playwright-image
    trap 'echo "🛑 Stopping Playwright MCP container..."; docker stop opencode-playwright 2>/dev/null' EXIT
    echo "   MCP endpoint: http://opencode-playwright:3000/sse"
  fi

  # 5. Run Secure Container
  docker run -it --rm \
    --name "opencode-safe-$(echo "$WORKSPACE" | tr '/' '-')" \
    --network opencode \
    -e HOST_UID=$(id -u) \
    -e HOST_GID=$(id -g) \
    -e NPM_CONFIG_UPDATE_NOTIFIER=false \
    -e COLORTERM=truecolor \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$WORKSPACE":"$WORKSPACE" \
    -w "$WORKSPACE" \
    -v "$HOME/.opencode":/home/opencodeuser/.opencode \
    -v "$HOME/.config/opencode":/home/opencodeuser/.config/opencode/ \
    -v "$HOME/.local/share/opencode/":/home/opencodeuser/.local/share/opencode \
    -v "$HOME/.gitconfig":/home/opencodeuser/.gitconfig \
    -v "$HOME/.ssh":/home/opencodeuser/.ssh:ro \
    opencode-image "${OPENCODE_ARGS[@]}"
}
