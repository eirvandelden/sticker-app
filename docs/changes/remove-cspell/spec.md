# Spec: Remove the cspell spell checker

Status: accepted.

## Requirements

The repo has no cspell config or marker comment; nothing else changes.

## Acceptance criteria

- `git grep -n -i -E '(^|[^a-z])cspell' -- ':!docs/changes'` prints nothing.
- The repo's own lint/tests stay as green as on main.
