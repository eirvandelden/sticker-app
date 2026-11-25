# Intent: Update appkit and mvpa.css to their latest versions

Author: Etienne van Delden. Status: accepted (2026-11-24). Type: feature. Delivery: autonomous.

## Problem

The branch pins appkit at `d82b9c7` and mvpa.css at `06778c8`. Both have moved on again: appkit `42e22b3` (2026-11) and mvpa.css `6e4fc63` (2026-11-11). appkit now changes the service worker, the manifest and the install flow. mvpa.css (2026-10-13) changes button looks, adds form action rows and adds dialog styles. The latest releases add a rail of hubs and a hub column in place of the flat nav, with landing tiles, back links and a sign-out submit page. appkit's nav partial no longer renders the app name, the home link or the Voorkeuren link. The app does not follow the new conventions yet.

## Proposed outcome

The app runs on the latest appkit and mvpa.css. Its buttons, form footers and delete confirmations follow the new mvpa.css conventions. The app shows a rail of hubs and a hub column, built from one `Appkit::Menu` map. The app keeps all current behaviour.

## Affected users and systems

Parents and children who use the app. The `Gemfile` and `Gemfile.lock` (appkit and mvpa-css only). The views under `app/views`, the application stylesheet, and the layouts.

## Constraints

- Approved permission: bump the appkit `ref` in `Gemfile` and refresh the lock for `appkit` and `mvpa-css` only. No gem is added or removed. Etienne approved (2026-10-20) the forced transitive bump of okcomputer 1.19.2 to 1.20.0, which appkit requires. No `bundle update` of all gems.
- appkit needs Rails 8.1. The app already runs Rails 8.1.4.
- Install gems with `bi`.
- `db/schema.rb` is never edited by hand. It holds only what `bin/rails db:schema:dump` generates.
- No edits to deploy files or `.github/workflows/`.

## In scope

- Move appkit and mvpa-css to their latest commits (appkit `42e22b3`, mvpa.css `6e4fc63`), with exact `ref`s in the `Gemfile`.
- Follow both changelogs from this branch's pins to those commits, including the rail, hub column and landing tiles "Upgrading" steps.
- Replace the shadowed `app/views/appkit/shared/_nav.html.erb` and the nav blocks of the parent and child layouts with `render layout: "appkit/shared/nav", locals: { menu: menu }`.
- Build an `Appkit::Menu` per request, exposed with `helper_method :menu`. Parent hubs: 👨‍👧 Kinderen, ⚙️ Instellingen, 🛠️ Beheer (admins only). Child hub: 🏠 Dashboard. Every role gets a 👤 Account hub with Voorkeuren, Profiel and a sign-out submit page.
- Add landing pages with tiles (`menu_entry_to menu.tile_path(page)`), `menu.carry`/`carry_list` links, and a title-bar back link (`menu.back`) where a hub has a list and a record.
- Load Turbo on every page that renders the nav, and render `csrf_meta_tags` in the layouts (the layouts already do).
- Delete app CSS that the gem now provides.
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
- A parent sees a rail with Kinderen, Instellingen and Account, and a hub column for the current hub. An admin also sees Beheer.
- A child sees a rail with Dashboard and Account.
- Choosing Uitloggen in the Account hub signs the user out, with no `InvalidAuthenticityToken` error.
- Opening a child from the Kinderen list, then choosing the back link, returns to the list.
- Voorkeuren and Profiel open from the Account hub, and the Account hub is the current hub while they show.
- On a phone the tab bar holds only the hubs.
- A parent who opens the app sees the push-enable button as a plain button and "Give sticker" and "Give penalty" as before.
- Deleting a user or turning off an allowance still works and keeps a red delete button.
- The manifest and service worker still load for a signed-in and a signed-out visitor.
- A child watching a card still sees a new sticker appear in real time.
- `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bin/importmap audit`, `bin/erb_lint --lint-all --allow-no-files` and the i18n check all pass.

## Decisions

- Extend the paused PR #187 branch with the nav work — Etienne chose one branch over a separate change.
- Hubs: Kinderen, Instellingen, Beheer (admin), Dashboard (child), and an Account hub for every role — Etienne picked "Role hubs plus account hub"; it matches appkit's own example.
- Pin mvpa.css at the latest commit with an exact `ref` — appkit's changelog says the new nav renders as plain lists without it.

## Open questions

None.
