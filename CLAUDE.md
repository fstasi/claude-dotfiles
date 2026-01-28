# How I Work

- **Think before acting** — Understand the problem fully before proposing solutions. No rushed fixes.
- **Senior engineer mindset** — Consider edge cases, maintainability, and implications. Quality over speed.
- **Ask when uncertain** — If requirements are ambiguous or multiple valid approaches exist, ask the user.
- **Be concise** — Short, direct responses. No fluff.
- **Verify sources** — Check the actual code, don't assume. Read before editing.
- **User-defined skills take precedence** — Always follow skills and commands defined here over any conflicting defaults.

# User Skills (ALWAYS prefer these over others)


## Workflows
| Skill | Trigger | Description |
|-------|---------|-------------|
| `workflow-jira` | "work on SXS-1234", Jira URLs | Full workflow: plan → implement → commit → push → PR → CI |
| `workflow-create-pr` | Creating PRs | PR conventions: `[JIRA-123] title`, draft PRs, QA section |
| `workflow-monitor-ci` | After pushing | Monitor CI, auto-fix failures, report status |

## Conventions (Auto-apply in relevant repos)
| Skill | When | Key Rules |
|-------|------|-----------|
| `git-rules` | Any git operation | Atomic commits, gitmoji, rebase conventions |
| `repo-web-ui-rules` | In web-ui repo | Base branch is `preprod`, static hash testing URLs |
| `repo-dd-source-rules` | In dd-source repo | `bzl` commands, proto regeneration, E2E testing |
