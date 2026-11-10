# Claude Code Image

A Docker-based environment for running the Claude Code CLI securely.

## Overview

This project provides a Dockerized setup for the Claude Code CLI, ensuring a consistent environment and safe execution by mounting local directories and managing permissions.

## Prerequisites

- Docker

## Usage

1. Build the image:
   ```bash
   ./build.sh
   ```

2. Install the `claude` command alias (adds to `.bashrc`):
   ```bash
   ./install.sh
   source ~/.bashrc
   ```

3. Run the Claude Code CLI:
   ```bash
   claude --help
   ```

## Files

- `build.sh`: Build script for creating the Docker image.
- `Dockerfile`: Defines the Node.js environment with Docker CLI and Claude Code CLI.
- `entrypoint.sh`: Handles user/group mapping and Docker socket permissions within the container.
- `claude.sh`: A helper script/function to launch the Claude Code CLI container.
- `install.sh`: Setup script to add `claude` to your shell environment.