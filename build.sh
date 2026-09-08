#!/bin/bash

BUILD_ARGS=""

for arg in "$@"; do
  if [[ "$arg" == "--rebuild" ]]; then
    BUILD_ARGS="--no-cache"
  fi
done

# Build the OpenCode CLI image
docker build $BUILD_ARGS -t opencode-image .

# Build the Playwright MCP image
docker build $BUILD_ARGS -t opencode-playwright-image -f Dockerfile.playwright .
