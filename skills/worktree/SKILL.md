---
name: worktree
description: Create and manage git worktrees for parallel development. Use when you need to work on multiple branches simultaneously without stashing or switching contexts.
argument-hint: "[branch-name] [base-branch]"
allowed-tools: Bash(git *), Bash(ls *), Bash(mkdir *), Bash(basename *)
---

# Git Worktree Workflow

Create a git worktree to enable parallel development on multiple branches.

## Arguments

- First argument: New branch name (required)
- Second argument: Base branch to create from (optional, auto-detects default branch)

## Worktree Directory Convention

Worktrees are created in `../worktrees/<repo-name>-<branch-name>` relative to the main repository.

This naming convention:
- Keeps all worktrees in a shared `worktrees` directory above the repo
- Includes repo name to avoid conflicts when working on multiple projects
- Includes branch name for easy identification

Example: If working in `/home/user/projects/my-app` on branch `feature-auth`, the worktree path would be `/home/user/projects/worktrees/my-app-feature-auth`

## Instructions

1. **Get repository info**
   ```bash
   # Get repo root and name
   repo_root=$(git rev-parse --show-toplevel)
   repo_name=$(basename "$repo_root")
   ```

2. **Check repository status**
   ```bash
   git status
   git worktree list
   ```

3. **Determine base branch**
   - Use the second argument if provided
   - Otherwise, detect default branch:
     ```bash
     # Try remote HEAD first
     git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
     # Fallback to checking main/master
     git show-ref --verify --quiet refs/remotes/origin/main && echo "main"
     git show-ref --verify --quiet refs/remotes/origin/master && echo "master"
     ```

4. **Create the worktree**
   ```bash
   # Define paths
   branch_name="<first-argument>"
   worktrees_dir="$(dirname "$repo_root")/worktrees"
   worktree_path="$worktrees_dir/${repo_name}-${branch_name}"

   # Create worktrees directory if needed
   mkdir -p "$worktrees_dir"

   # Fetch latest from base branch
   git fetch origin <base-branch>

   # Create worktree with new branch from base
   git worktree add "$worktree_path" -b "$branch_name" origin/<base-branch>
   ```

5. **Verify creation**
   ```bash
   git worktree list
   ```

6. **Report to user**
   - Confirm the new worktree path
   - Show which branch it's based on
   - Remind user how to navigate: `cd <worktree_path>`

## Temporary Branch Handling

When a branch has a temporary name (pattern: `wt-*` or similar timestamp-based names), you should:

1. **Detect temporary branch**
   ```bash
   branch=$(git branch --show-current)
   if [[ "$branch" == wt-* ]]; then
       # This is a temporary branch
   fi
   ```

2. **Ask about the task context**
   - What feature or fix is being worked on?
   - Is there an issue ID (e.g., ISSUE-123)?

3. **Suggest and rename the branch**
   ```bash
   # Rename to a meaningful name based on the task
   git branch -m <old-name> <new-name>
   ```

   **Naming conventions:**
   - `feature/<description>` - New features
   - `fix/<description>` - Bug fixes
   - `refactor/<description>` - Code refactoring
   - `docs/<description>` - Documentation changes
   - `ISSUE-123-<description>` - When linked to an issue tracker

4. **Example interaction:**
   ```
   User: Let's add user authentication

   Claude: I notice the current branch has a temporary name 'wt-1706789012'.
   Based on your task, I'll rename it to something more descriptive.

   [Runs: git branch -m wt-1706789012 feature/user-auth]

   Branch renamed to 'feature/user-auth'. Now let's implement the authentication...
   ```

## Cleanup Instructions

When the user wants to remove a worktree:

```bash
# Get current repo info
repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
worktrees_dir="$(dirname "$repo_root")/worktrees"

# Remove a specific worktree
git worktree remove "$worktrees_dir/${repo_name}-<branch-name>"

# Or manually delete and prune
rm -rf "$worktrees_dir/${repo_name}-<branch-name>"
git worktree prune

# List remaining worktrees
git worktree list
```

## Examples

```bash
# Create a feature branch worktree from auto-detected default branch
/worktree feature/user-auth

# Create a feature branch worktree from main
/worktree feature/user-auth main

# Create a hotfix worktree from production branch
/worktree hotfix/login-bug production
```

## Integration with claude-wt

This skill works with the `claude-wt` bash script:

1. `claude-wt` creates a worktree with a temporary branch name (e.g., `wt-1706789012`)
2. The worktree is created at `../worktrees/<repo-name>-<branch-name>`
3. Claude Code starts in the worktree directory
4. When the user describes their task, rename the branch appropriately
5. Continue with the implementation

## Red Flags

**Never:**
- Proceed with a temporary branch name (`wt-*`) without asking about renaming
- Create worktrees in directories that don't follow the convention

**Always:**
- Use the path convention: `../worktrees/<repo-name>-<branch-name>`
- Detect and offer to rename temporary branches
- Auto-detect the default branch if not specified
- Verify worktree creation with `git worktree list`
