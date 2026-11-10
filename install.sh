#!/bin/bash

# Determine the absolute path to the claude.sh script
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$INSTALL_DIR/claude.sh"
BASHRC="$HOME/.bashrc"

echo "Installing Claude Code CLI wrapper..."

# Ensure ~/.claude exists and copy CLAUDE.md there
mkdir -p "$HOME/.claude"
cp "$INSTALL_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
echo "✅ Copied CLAUDE.md to $HOME/.claude/CLAUDE.md"

# Check if the script is already sourced in .bashrc
if grep -q "source \"$SCRIPT_PATH\"" "$BASHRC"; then
    echo "✅ claude.sh is already sourced in $BASHRC"
else
    # Backup .bashrc
    cp "$BASHRC" "$BASHRC.bak"
    
    # Append the source command
    echo "" >> "$BASHRC"
    echo "# Claude Code CLI Wrapper" >> "$BASHRC"
    echo "source \"$SCRIPT_PATH\"" >> "$BASHRC"
    echo "✅ Added source command to $BASHRC"
fi

echo ""
echo "Installation complete!"
echo "Please run 'source $BASHRC' or restart your terminal to start using 'claude'."