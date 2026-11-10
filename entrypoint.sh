#!/bin/bash
set -e

# --------------------------------------------------------
# 1. SETUP USER & GROUPS (Run as Root)
# --------------------------------------------------------
USER_ID=${HOST_UID:-1000}
GROUP_ID=${HOST_GID:-1000}

echo "Initializing container for UID: $USER_ID, GID: $GROUP_ID"

# Create Group if missing
if ! getent group "$GROUP_ID" >/dev/null; then
    groupadd -g "$GROUP_ID" claudegroup
fi

# Create User if missing
if ! id -u "$USER_ID" >/dev/null 2>&1; then
    useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash claudeuser
fi
USERNAME=$(getent passwd "$USER_ID" | cut -d: -f1)

# --------------------------------------------------------
# 2. SETUP DOCKER ACCESS
# --------------------------------------------------------
if [ -S /var/run/docker.sock ]; then
    SOCKET_GID=$(stat -c '%g' /var/run/docker.sock)
    if ! getent group "$SOCKET_GID" >/dev/null; then
        groupadd -g "$SOCKET_GID" docker-host
    fi
    SOCKET_GROUP=$(getent group "$SOCKET_GID" | cut -d: -f1)
    usermod -aG "$SOCKET_GROUP" "$USERNAME"
fi

# --------------------------------------------------------
# 3. PREPARE ENVIRONMENT
# --------------------------------------------------------
export HOME="/home/$USERNAME"
export SHELL=/bin/bash
chown -R "$USERNAME:$GROUP_ID" "$HOME" || true

# --------------------------------------------------------
# 4. EXECUTE AS USER
# --------------------------------------------------------
# We pass execution to the user.
# The inner script runs claude, captures the exit code,
# and drops into a shell if claude crashes.

exec gosu "$USERNAME" /bin/bash -c '
    # Auto-detect Docker API version to prevent client/server mismatch errors
    if [ -S /var/run/docker.sock ]; then
        API_VERSION=$(curl -s --unix-socket /var/run/docker.sock http://localhost/version 2>/dev/null | grep -o "\"ApiVersion\":\"[^\"]*\"" | cut -d\" -f4 | head -n 1)
        if [ -n "$API_VERSION" ]; then
            export DOCKER_API_VERSION="$API_VERSION"
        fi
    fi

    echo "Running command: claude $@"
    
    # Run the Claude Code tool
    claude "$@"
    EXIT_CODE=$?

    # Error Handling
    if [ $EXIT_CODE -ne 0 ]; then
        echo ""
        echo "❌ Claude Code exited with error code $EXIT_CODE"
        echo "   Spawning a rescue shell so you can check logs/files..."
        exec /bin/bash
    fi
' -- "$@"