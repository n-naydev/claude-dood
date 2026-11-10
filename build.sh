#!/bin/bash

BUILD_ARGS=""

for arg in "$@"; do
  if [[ "$arg" == "--rebuild" ]]; then
    BUILD_ARGS="--no-cache"
  fi
done

# Build the Claude Code CLI image
docker build $BUILD_ARGS -t claude-image .

# Build the Playwright MCP image
docker build $BUILD_ARGS -t claude-playwright-image -f Dockerfile.playwright .