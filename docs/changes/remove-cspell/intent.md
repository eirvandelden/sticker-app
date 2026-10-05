# Intent: Remove the cspell spell checker

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

cspell stops commits on correctly spelled technical words and has found no real typo.

## Proposed outcome

No cspell config or markers are left now that the dotfiles fallback hook stops running it.

## Affected users and systems

The sticker-app repository: `.cspell.json` and the marker comment in `LICENSE.md`.

## Constraints

Nothing else in the repository changes.

## Open questions

None.
