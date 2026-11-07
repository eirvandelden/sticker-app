# Intent: Turn the lint job green and keep Steep green

Author: Etienne van Delden de la Haije. Status: accepted (2026-11-06). Type: chore. Delivery: autonomous. Codex review: no.

## Problem

Nobody gets a clean lint run on `main`, locally or in CI, so every branch carries pre-existing red. The `align-views-with-journal-patterns` implement report raised it as a "Decision needed".

Three causes:

- `bin/rubocop` reports 14 offenses on `# @rbs module-self: X` in 6 files: `app/controllers/concerns/{authorization,user_scoped,version_headers}.rb`, `app/helpers/application_helper.rb`, `app/models/concerns/authorization.rb` and `app/models/user/role.rb`. `rubocop-rbs_inline` 2.0.0 (`KeywordSeparator`, `InvalidTypes`) follows the `rbs-inline` gem's syntax and wants `module-self X`. Steep 2.1 checks with `inline: true`, which uses RBS 4's own inline parser, and that parser requires the colon. Applying the cop's autocorrect makes `steep check` report 28 problems in 6 files, among them `Syntax error: expected a token pCOLON`. The code follows Steep; the cop is wrong for this setup.
- `bin/rubocop` reports 1 `MissingTypeAnnotation` offense on `db/queue_migrate/20260825150149_add_batches_to_solid_queue.rb`. `rubocop-eirvandelden` excludes only `**/db/migrate/**/*` from that cop ("migrations never get called from code"), and the Solid Queue migrations live in `db/queue_migrate/`.
- In CI, `ci / lint` and `ci / scan_js` fail on `main` before their tools run (run 42282988312): `openssl-4.0.2` in the installed bundle needs `OPENSSL_3.4.0`, which the `libcrypto.so.3` of the `ubuntu-slim` runner lacks. The jobs on `ubuntu-latest` pass. These jobs come from appkit's shared `.github/workflows/rails-ci.yml`.

`steep check` itself is green today: with a freshly generated `sig/` it reports "No type error detected", locally and in the CI `steep` job. The "1 steep problem" in the implement report came from a stale `sig/`.

## Proposed outcome

`ci / lint` and `ci / scan_js` pass on this app's pull request. `bin/rubocop` reports no offenses. `steep check` stays green, and the `module-self` self types keep their effect in Steep.

## Affected users and systems

- Developers and agents who lint this repository.
- `rubocop-eirvandelden`: its shared config changes, so every personal repository that inherits it gets the fix.
- appkit's shared `rails-ci.yml`: every app that uses it gets the openssl fix.
- This app's `Gemfile.lock` (the `rubocop-eirvandelden` ref).

## Constraints

- Steep is the authority on inline RBS syntax: the colon form `module-self: X` stays.
- No linter disable comments, and no lint config edit in this app to get green (playbook rule 2, §7a). The cop fix lives in `rubocop-eirvandelden`.
- Approved permissions: edit appkit's `.github/workflows/rails-ci.yml` (rule 13); bump `rubocop-eirvandelden` in this app with `bundle update rubocop-eirvandelden` (rule 11, a version bump only); push branches and open draft pull requests in `rubocop-eirvandelden` and appkit.
- Agents never merge. Etienne merges the `rubocop-eirvandelden` and appkit pull requests before this app's pull request can turn green.

## In scope

- `rubocop-eirvandelden` accepts `# @rbs module-self: X`, still flags invalid inline RBS elsewhere, and excludes `db/queue_migrate/` (and the other Solid `db/*_migrate/` folders) from `MissingTypeAnnotation`.
- appkit's `rails-ci.yml` no longer fails with the openssl LoadError on the `lint` and `scan_js` jobs.
- This app picks up the new `rubocop-eirvandelden` ref.

## Out of scope

- Bumping appkit itself to a version with `sig/`, adding `steep` as a dev gem, and dropping the `@type const …: untyped` and `@rbs skip` markers.
- Upstream changes to `rubocop-rbs_inline`.
- Any other red check that is not `lint` or `scan_js`.

## Acceptance criteria

- On this branch, `bin/rubocop` prints "no offenses detected" and the 6 files still read `# @rbs module-self: X`.
- On this branch, with a regenerated `sig/`, `steep check` prints "No type error detected".
- Removing `ActionController::Base` from the `module-self` of `app/controllers/concerns/authorization.rb` makes `steep check` fail on `redirect_to`, which proves Steep still reads the self type.
- In `rubocop-eirvandelden`, a file with `# @rbs module-self: Foo` gets no offense, and a file with a broken type such as `#: (Integer -> void` still gets `InvalidTypes`.
- In `rubocop-eirvandelden`, a method without a signature in `db/queue_migrate/` gets no offense, and the same method in `app/models/` still gets `MissingTypeAnnotation`.
- On this app's pull request, `ci / lint` and `ci / scan_js` pass.

## Decisions

- Fix the cop-versus-Steep conflict and the `db/queue_migrate` exclusion in `rubocop-eirvandelden`, then bump the gem here — the conflict is not specific to this app, so every personal repository with Steep inline mode gets the fix.
- Bundle the openssl CI failure into this change — one change turns lint green; neither fix alone does.
- Deliver autonomously, with the Claude reviewer only — a lint and CI chore with a clear cause.

## Open questions

None.
