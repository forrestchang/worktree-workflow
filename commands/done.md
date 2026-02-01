# /done - Complete work on an issue

Help the developer wrap up their work on the current issue.

## Usage

```
/done           # Complete the issue detected from branch name
/done ISSUE-12   # Complete a specific issue
```

## Dependencies

- **Optional**: `linear` CLI for Linear integration
- **Optional**: `gh` CLI for GitHub PR creation

## Steps

1. **Detect the issue** from the branch name or use the provided ID
2. **Detect base branch** for comparison:
   ```bash
   base=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   # Fallback to main/master
   ```
3. **Summarize the work** by checking:
   - `git log --oneline $base..HEAD` to see commits
   - `git diff --stat $base..HEAD` to see files changed
4. **Ask what they want to do:**
   - Create PR and close
   - Close issue (no PR)
   - Add notes and close
   - Just clean up (keep issue open)

## After Selection

### If they want to create a PR:
1. Run `gh pr create --title "ISSUE-12: Issue title" --body "..."` with a summary
2. Then proceed to closing if requested

### If they want to add notes (requires linear CLI):
1. Ask what notes to add
2. Run `linear issue update ISSUE-12 --append "..."` with the notes

### If they want to close (requires linear CLI):
1. Run `linear done ISSUE-12` to close the issue

### Worktree cleanup:
If in a worktree, offer commands to clean up:
```bash
# Get worktree info
repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
branch_name=$(git branch --show-current)
# Convert slashes in branch name to dashes for directory name
dir_safe_branch="${branch_name//\//-}"
worktrees_dir="$(dirname "$repo_root")/worktrees"
worktree_path="$worktrees_dir/${repo_name}-${dir_safe_branch}"

# From main repo, remove the worktree
cd <main-repo-path>
git worktree remove "$worktree_path"
git worktree prune
```

## Example Flow

```
User: /done

Claude: Let me check what you've been working on...

[Runs git log and git diff]

You've made 3 commits on ISSUE-12: Add caching layer
- src/cache.ts (new file, 45 lines)
- src/api.ts (modified, +12 -3)

[Presents options above]
```

## Notes

- Always show a summary of the work done before asking
- If there are no commits, skip the PR option
- Don't auto-close - always confirm with the user first
- Linear CLI is optional; provide guidance even without it
