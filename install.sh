#!/bin/bash
# install.sh - Install worktree-workflow tools
#
# This script installs:
# - claude-wt script to ~/.local/bin/
# - Skills to ~/.claude/skills/
# - Commands to ~/.claude/commands/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to safely install a file
# Usage: safe_install <source> <dest> <type>
# type: "symlink" or "copy"
safe_install() {
    local source="$1"
    local dest="$2"
    local type="$3"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ]; then
            # It's a symlink, remove it
            rm "$dest"
        elif [ -f "$dest" ]; then
            # It's a regular file, backup and remove
            echo -e "${YELLOW}(backing up existing file)${NC} "
            mv "$dest" "${dest}.backup.$(date +%s)"
        elif [ -d "$dest" ]; then
            # It's a directory, backup and remove
            echo -e "${YELLOW}(backing up existing directory)${NC} "
            mv "$dest" "${dest}.backup.$(date +%s)"
        fi
    fi

    if [ "$type" = "symlink" ]; then
        ln -s "$source" "$dest"
    else
        cp -r "$source" "$dest"
    fi
}

echo "Installing worktree-workflow..."
echo

# Create directories if they don't exist
mkdir -p ~/.local/bin
mkdir -p ~/.claude/skills
mkdir -p ~/.claude/commands

# Install claude-wt script
echo -n "Installing claude-wt... "
safe_install "$SCRIPT_DIR/bin/claude-wt" ~/.local/bin/claude-wt "symlink"
chmod +x "$SCRIPT_DIR/bin/claude-wt"
echo -e "${GREEN}done${NC}"

# Install skills
echo -n "Installing skills... "
safe_install "$SCRIPT_DIR/skills/worktree" ~/.claude/skills/worktree "copy"
echo -e "${GREEN}done${NC}"

# Install commands
echo "Installing commands..."
for cmd in pr done; do
    echo -n "  - $cmd.md... "
    safe_install "$SCRIPT_DIR/commands/$cmd.md" ~/.claude/commands/$cmd.md "copy"
    echo -e "${GREEN}done${NC}"
done

echo
echo -e "${GREEN}Installation complete!${NC}"
echo
echo "Next steps:"
echo
echo "1. Ensure ~/.local/bin is in your PATH:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
echo
echo "2. Add this alias to your shell config (~/.zshrc or ~/.bashrc):"
echo "   alias claude-wt='source ~/.local/bin/claude-wt'"
echo
echo "3. Usage:"
echo "   claude-wt                    # Create worktree, Claude helps rename branch"
echo "   claude-wt feature-auth       # Create worktree with named branch"
echo
