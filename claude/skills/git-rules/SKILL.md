---
name: git-rules
description: Git conventions for commits, rebasing, and branch management
---

## Commit Conventions

Follow these rules when creating git commits:

1. **ATOMIC COMMITS ARE MANDATORY** - Each commit must be a single, logical change:
   - One commit = one purpose (e.g., one bug fix, one feature, one refactor)
   - Commits should be independently reviewable and revertable
   - Never mix unrelated changes in a single commit
   - When planning changes, ALWAYS break them into atomic commits
   - Use `/dd:git:commit:atomic` to automatically group related changes into separate commits

2. **Keep messages short and concise** - Focus on the "what" and "why"

3. **Use gitmoji** - Start commit messages with relevant emoji(s):
   - ✨ New feature
   - 🐛 Bug fix
   - ♻️ Refactor
   - 🔧 Configuration
   - 📝 Documentation
   - 🎨 Style/format
   - ⚡ Performance
   - 🧪 Tests
   - 🔒 Security

4. **Format**: `<gitmoji(s)> <short description>`
5. **Example**: `✨ add shadow traffic support`

## Rebasing

When asked to rebase:
- **On preprod**: `git pull --rebase origin preprod`
- **On main**: `git pull --rebase origin main`

Always resolve conflicts interactively and verify the rebase succeeded before continuing.
