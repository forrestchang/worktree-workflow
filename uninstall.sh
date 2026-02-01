#!/bin/bash
# uninstall.sh - Uninstall worktree-workflow tools
#
# This script removes:
# - claude-wt script from ~/.local/bin/
# - Skills from ~/.claude/skills/
# - Commands from ~/.claude/commands/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Uninstalling worktree-workflow..."
echo

# Remove claude-wt script
echo -n "Removing claude-wt... "
if [ -e ~/.local/bin/claude-wt ] || [ -L ~/.local/bin/claude-wt ]; then
    rm -f ~/.local/bin/claude-wt
    echo -e "${GREEN}done${NC}"
else
    echo "not found"
fi

# Remove skills
echo -n "Removing skills... "
if [ -e ~/.claude/skills/worktree ]; then
    rm -rf ~/.claude/skills/worktree
    echo -e "${GREEN}done${NC}"
else
    echo "not found"
fi

# Remove commands
echo "Removing commands..."
for cmd in pr done; do
    echo -n "  - $cmd.md... "
    if [ -e ~/.claude/commands/$cmd.md ]; then
        rm -f ~/.claude/commands/$cmd.md
        echo -e "${GREEN}done${NC}"
    else
        echo "not found"
    fi
done

echo
echo -e "${GREEN}Uninstallation complete!${NC}"
echo
echo "Note: You may want to remove the alias from your shell config (~/.zshrc or ~/.bashrc):"
echo "   alias claude-wt='source ~/.local/bin/claude-wt'"
echo
