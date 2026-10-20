# Intent: Update appkit and mvpa.css to their latest versions

Author: Etienne van Delden. Status: accepted (2026-10-20). Type: chore.
Delivery: autonomous

## Problem

The app pins appkit at `e7abc8c` and uses mvpa.css at `4c9c4ae`. Both have moved on. appkit now changes the service worker, the manifest and the install flow. mvpa.css (2026-10-13) changes button looks, adds form action rows and adds dialog styles. The app does not follow the new conventions yet.

## Proposed outcome

The app runs on the latest appkit and mvpa.css. Its buttons, form footers and delete confirmations follow the new mvpa.css conventions. The app keeps all current behaviour.

## Affected users and systems

Parents and children who use the app. The `Gemfile` and `Gemfile.lock` (appkit and mvpa-css only). The views under `app/views`, the application stylesheet, and the layouts.

## Constraints

- Approved permission: bump the appkit `ref` in `Gemfile` and refresh the lock for `appkit` and `mvpa-css` only. No gem is added or removed. Etienne approved (2026-10-20) the forced transitive bump of okcomputer 1.19.2 to 1.20.0, which appkit requires. No `bundle update` of all gems.
- appkit needs Rails 8.1. The app already runs Rails 8.1.4.
- Install gems with `bi`.
- `db/schema.rb` is never edited by hand. It holds only what `bin/rails db:schema:dump` generates.
- No edits to deploy files or `.github/workflows/`.

## In scope

- Move appkit and mvpa-css to their latest commits.
- Apply every item in both "Upgrading" notes that touches this app: appkit manifest and service worker with the host `ApplicationController`; the mvpa.css button hierarchy, action rows, dialogs, `12_dialog.css`.
- Review each button and form footer in the views and make it match the new conventions (plain `type="button"`, `button-danger` where red is needed, action-row footers, `<dialog>` confirmations where the app has a confirm).
- Regenerate `db/schema.rb` with Rails, so the committed file is the generated output and no column-order noise remains.
- Update tests, i18n and lint so all checks pass.

## Out of scope

- New features, including the unfinished allowance and `Transfer` work.
- Other dependency upgrades.
- Schema changes: no migration is added.

## Acceptance criteria

- `db/schema.rb` equals the output of a fresh schema dump, and a second dump changes nothing.
- The Gemfile and lock name the latest appkit and mvpa-css commits, and only okcomputer moves besides them (forced by appkit).
- A parent who opens the app sees the push-enable button as a plain button and "Give sticker" and "Give penalty" as before.
- Deleting a user or turning off an allowance still works and keeps a red delete button.
- The manifest and service worker still load for a signed-in and a signed-out visitor.
- A child watching a card still sees a new sticker appear in real time.
- `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bin/importmap audit`, `bin/erb_lint --lint-all --allow-no-files` and the i18n check all pass.

## Open questions

None.
