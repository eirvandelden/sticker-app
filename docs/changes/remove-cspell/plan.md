# Plan: Remove the cspell spell checker

Status: accepted.

## Files that change

Delete `.cspell.json` and the `<!-- cSpell:ignore O'Saasy Etienne Delden Haije -->` comment on line 1 of `LICENSE.md` (and a blank line directly after it only if that would leave the file starting with a blank line). Change nothing else in LICENSE.md.

## Proof

- `git grep -n -i -E '(^|[^a-z])cspell' -- ':!docs/changes'` prints nothing.
- The repo's own lint/tests stay as green as on main.
