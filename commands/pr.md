# Create Pull Request

Create a PR for the current branch with auto-generated title and description.

## Workflow

1. **Detect base branch**
   ```bash
   # Try remote HEAD first
   base=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   # Fallback to main/master
   if [ -z "$base" ]; then
       git show-ref --verify --quiet refs/remotes/origin/main && base="main"
       git show-ref --verify --quiet refs/remotes/origin/master && base="master"
   fi
   ```

2. **Gather context** (run in parallel):
   - `git status` - check for uncommitted changes
   - `git log $base..HEAD --oneline` - commits to include
   - `git diff $base...HEAD --stat` - files changed

3. **Handle uncommitted changes**: If working tree is dirty, ask user whether to commit first or proceed with existing commits only

4. **Push branch**: Run `git push -u origin HEAD` if branch is not already pushed to remote

5. **Create PR** using gh cli:
```bash
gh pr create --title "<type>: <summary>" --body "$(cat <<'EOF'
## Summary
<bullet points summarizing the commits>

## Test plan
<checklist based on changes made>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Title Convention

Use conventional commits format: `fix:`, `feat:`, `refactor:`, `docs:`, `chore:`

## Output

Return the PR URL when complete.
