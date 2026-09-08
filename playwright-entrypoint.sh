#!/bin/bash
set -e

exec npx @playwright/mcp --host 0.0.0.0 --port 3000 --headless --no-sandbox --allowed-hosts '*' "$@"