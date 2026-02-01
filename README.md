# Worktree Workflow

A toolkit for parallel development with git worktrees, designed for Claude Code.

## Features

- **`claude-wt`** - Bash script to create worktrees and launch Claude Code
- **Worktree Skill** - Claude Code skill for managing worktrees and branch naming
- **Workflow Commands** - `/pr`, `/done` commands for development workflow

## Installation

```bash
# Clone the repository
git clone https://github.com/anthropics/worktree-workflow.git
cd worktree-workflow

# Run the install script
./install.sh
```

The install script will:
1. Symlink `claude-wt` to `~/.local/bin/`
2. Copy skills to `~/.claude/skills/`
3. Copy commands to `~/.claude/commands/`

If files already exist, they will be backed up with a timestamp suffix.

### Shell Configuration

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Alias (required for cd to work)
alias claude-wt='source ~/.local/bin/claude-wt'
```

Then reload: `source ~/.zshrc`

## Usage

### claude-wt Command

```bash
# Create worktree with temporary branch (dangerous mode, default)
claude-wt

# Create worktree with specific branch name
claude-wt feature-auth

# Create worktree with initial prompt
claude-wt feature-auth "Implement user authentication"

# Use safe mode (with permission prompts)
claude-wt --safe feature-auth

# Explicitly use dangerous mode
claude-wt --dangerous feature-auth
```

**Options:**
| Option | Description |
|--------|-------------|
| `--safe` | Run Claude Code with permission prompts |
| `--dangerous` | Skip permission prompts (default) |

### Within Claude Code

```bash
# Create a worktree for a new feature
/worktree feature/new-api main

# Create a pull request
/pr

# Complete work on current issue
/done
```

## Worktree Directory Convention

All worktrees are created in `../worktrees/<repo-name>-<branch-name>` relative to the main repository.

For example, if your repo is at `/home/user/projects/my-app` and you create a branch `feature-auth`:
- Worktree path: `/home/user/projects/worktrees/my-app-feature-auth`

This convention:
- Keeps worktrees separate from the main repo
- Includes repo name to avoid conflicts across projects
- Makes it easy to identify which worktree belongs to which project/branch

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_WT_WORKTREES_DIR` | `../worktrees` (relative to repo) | Custom directory for worktrees |

### Example: Custom Worktrees Directory

```bash
# Use a project-local worktrees directory
export CLAUDE_WT_WORKTREES_DIR="./.worktrees"
claude-wt feature-auth
```

## Project Structure

```
worktree-workflow/
├── bin/
│   └── claude-wt           # Main CLI script
├── skills/
│   └── worktree/
│       └── SKILL.md        # Claude Code skill
├── commands/
│   ├── pr.md               # Create pull request
│   └── done.md             # Complete issue workflow
└── install.sh              # Installation script
```

## Dependencies

- **Required**: `git`, `claude` (Claude Code CLI)
- **Optional**: `gh` (GitHub CLI for `/pr`)

## License

MIT
