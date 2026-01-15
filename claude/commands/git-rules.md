---
description: Git conventions for commits, rebasing, and branch management
---

## Commit Conventions

- Keep commit messages short and concise
- Use gitmoji when possible (e.g., ✨ for new features, 🐛 for bug fixes, ♻️ for refactor)
- Default format: `<gitmoji(s)> <short description>`
- Example: `✨ add shadow traffic support`

## Rebasing

- When asked to rebase on preprod run: `git pull --rebase origin preprod`
- When asked to rebase on main run: `git pull --rebase origin main`
