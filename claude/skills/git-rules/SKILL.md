---
name: git-rules
description: Git conventions for commits, rebasing, and branch management
---

## Commit Conventions

Follow these rules when creating git commits:

1. **Keep messages short and concise** - Focus on the "what" and "why"
2. **Use gitmoji** - Start commit messages with relevant emoji(s):
   - ✨ New feature
   - 🐛 Bug fix
   - ♻️ Refactor
   - 🔧 Configuration
   - 📝 Documentation
   - 🎨 Style/format
   - ⚡ Performance
   - 🧪 Tests
   - 🔒 Security

3. **Format**: `<gitmoji(s)> <short description>`
4. **Example**: `✨ add shadow traffic support`

## Rebasing

When asked to rebase:
- **On preprod**: `git pull --rebase origin preprod`
- **On main**: `git pull --rebase origin main`

Always resolve conflicts interactively and verify the rebase succeeded before continuing.
