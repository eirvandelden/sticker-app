# Intent: Inline RBS instead of YARD

Author: Etienne van Delden. Status: accepted. Type: chore. Delivery: autonomous

## Problem

The app has no machine-checked method signatures. Personal projects now document methods with inline RBS (`#:` or `# @rbs`, RBS 4 syntax) checked by Steep, not YARD. This repo has no `Steepfile`, no `rbs_collection.yaml`, and no signatures. `rubocop-yard` still arrives transitively through `rubocop-eirvandelden`.

## Proposed outcome

Every method in `app/` and `lib/` carries an inline RBS signature. `steep check` passes locally and in CI. No YARD tags remain in the repo.

## Affected users and systems

Developers of this app, and the CI workflow. No runtime behaviour changes.

## Constraints

- Inline RBS uses RBS 4 syntax (`#:` or `# @rbs`). No YARD tags.
- Steep comes from the global gem install, never the Gemfile. No Gemfile change. `rbs` is already in `Gemfile.lock`.
- Approved by Etienne: edit `.github/workflows/ci.yml` to add a Steep job (playbook rule 13).
- Approved by Etienne: no other permissions (no gem, no migration, no deploy file).
- Class summary comments stay: one line per class, plus a comment only for a non-obvious "why".
- Signatures must not change code behaviour. Existing tests stay green.

## In scope

- `Steepfile` with one target: `check "app", "lib", inline: true`.
- `rbs_collection.yaml` and `rbs_collection.lock.yaml`, committed. `.gem_rbs_collection/` in `.gitignore`.
- Inline RBS on all methods in `app/` (models, concerns, controllers, jobs, helpers, channels, mailers) and `lib/`.
- Fix or remove any existing YARD-style comments found.
- A Steep job in `.github/workflows/ci.yml`.
- A line in `CLAUDE.md` Commands: `steep check`.

## Out of scope

- `rubocop-yard` and `rubocop-eirvandelden` (left as they are).
- Gemfile changes.
- `test/`, `config/`, `db/`, and the `Appkit::Engine` gem.
- Behaviour changes or refactors beyond what Steep needs.
- Finishing the unfinished allowance code or the `Transfer` stub.

## Acceptance criteria

- Running `steep check` in the repo exits 0.
- A method called with the wrong argument type, such as `Sticker` given a non-card, makes `steep check` fail.
- No `@param`, `@return` or other YARD tag remains in `app/` or `lib/`.
- Every method in `app/` and `lib/` has an inline RBS signature.
- A pull request runs the Steep job in CI, and it passes.
- `bin/rails test`, `bin/rubocop`, and `bin/brakeman` stay green.

## Flagged concerns

- CI has no Steep in the Gemfile, so the Steep job installs it with `gem install steep`. Chosen: install it in the job, keeping Gemfile untouched.
- Rails dynamic methods (associations, enums, `Current`) lack RBS. Chosen: add minimal `sig/` stubs or `# @rbs` annotations only as far as `steep check` needs, and no more.

## Open questions

None.
