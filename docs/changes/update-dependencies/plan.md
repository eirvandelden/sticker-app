# Plan: Update dependencies to their latest versions

From `intent.md` (2026-10-06). Status: accepted.

## Design decisions

- No appkit change. Etienne decided this on 2026-10-06, after the intent was accepted. `intent.md` is amended in the same commit as this plan to match.
- The app shadows appkit's nav partial with its own `app/views/appkit/shared/_nav.html.erb`. Rails looks in the app's `app/views` before the engine's, so the layouts' existing `render layout: "appkit/shared/nav", locals: { home_path: ... }` calls pick up the app's copy unchanged. The app already shadows two appkit views this way: `app/views/appkit/preferences/edit.html.erb` and `app/views/appkit/sessions/new.html.erb`.
- The shadow copies appkit `main`'s markup and its `appkit.navigation.{home,preferences,logout}` keys. One line differs: Home links to the `home_path` local and is marked by `nav_section_tab` (`app/helpers/application_helper.rb:11`). Home is then current on its own path and on every path nested under it.
- One rule serves both layouts. A parent's Home is `/parent/children`, so a child's page, edit page and history mark it. `/parent/settings`, `/admin` and `/preferences` sit outside it and leave it unmarked. A child's Home is `/child`.
- The shadow carries one ERB comment: appkit's own partial hardcodes `root_path`, which is the login page here.
- Bundler moves from 2.7.1 to 4.0.22. Etienne approved one install on 2026-10-06: `gem install bundler -v 4.0.22` under Ruby 4.0.7.
- Ruby 4.0.7 and Bundler 4.0.22 go in one commit. Under Ruby 4.0.7, a lockfile that says 2.7.1 makes Bundler auto-install 2.7.1, an install nobody approved.
- The nav step comes first. It no longer waits on appkit, and it holds the only acceptance criteria a test can express, so its tests form the walking skeleton. The command-shaped criteria (`bundle outdated`, `yarn outdated`, `ruby -v`, the Docker build) are checked in the final step.
- Each update commit carries the app fixes that update forces, so every commit is green. The herb gem and `@herb-tools/linter` move in one commit, so they never sit on different minors.
- appkit keeps a `ref:` pin (full SHA) at the newest commit on appkit `main` when the step runs. On 2026-10-06 that is `fd86991b8b6ac88cb9d991a9cc838ee717a0e6da`.
- Conflict, flagged, not resolved here: the `dependencies` skill says personal gems carry no version restriction, but the intent keeps appkit's `ref:` pin. The intent wins for this change.

## Integration points

- appkit (`eirvandelden/appkit`): the pin moves from `e7abc8c`, which sits on side branch `ai/review-workspace-changes` and not on `main`, to `main`. What reaches the app:
  - The nav partial: Home links to `root_path`, keys move to `appkit.navigation.*`. The shadow replaces it.
  - E-ink device detection in `theme_controller.js`.
  - Small refactors in the preferences and push subscription controllers.
  - appkit's `sessions/new` and `preferences/edit` views do not change between the two refs, so the app's existing shadows need no update.
  - `redirect_signed_in_user_to_root` is unchanged; the app's override at `app/controllers/application_controller.rb:31` stays.
- i18n-tasks reads appkit's locale files as external data (`config/i18n-tasks.yml`), so `appkit.navigation.*` in the shadow counts as present.
- CI: `.github/workflows/ci.yml` calls `eirvandelden/appkit/.github/workflows/rails-ci.yml@main`. Only the `erb-lint` job's `node-version` changes here.
- Production image: the Dockerfile builds `ruby:4.0.7-slim`. No deploy.
- Dependabot PRs #172–#174 close themselves once this merges.

## Files that change

- `test/controllers/navigation_test.rb` — new acceptance tests for Home marking and Dutch wording. Existing Home tests read `appkit.navigation.home`.
- `app/views/appkit/shared/_nav.html.erb` — new; shadows appkit's nav partial.
- `app/views/layouts/parent.html.erb` — drop the comment that says marking Home needs an appkit change. It no longer holds.
- `Gemfile` — appkit `ref:` at the newest appkit `main` SHA.
- `Gemfile.lock` — appkit, then herb, then every other gem; `BUNDLED WITH 4.0.22`.
- `config/locales/en.yml`, `nl.yml`, `it.yml` — drop `navigation.home`, `navigation.preferences` and `common.logout`. Nothing else uses them.
- `config/i18n-tasks.yml` — drop those three `ignore_unused` entries and their comment.
- `.ruby-version` — `ruby-4.0.7`.
- `Dockerfile` — `ARG RUBY_VERSION=4.0.7`.
- `package.json`, `yarn.lock` — `@herb-tools/linter` at `^0.11.0`.
- `.github/workflows/ci.yml` — `node-version: 24`.
- `docs/changes/update-dependencies/intent.md` — amended with this plan's commit: no appkit change, the shadow partial instead.
- Any app file that a new lint rule, cop, Brakeman check or deprecation warning flags. Unknown until the updates run.

## Order of work

1. Write the nav acceptance tests in `test/controllers/navigation_test.rb` (see Proof). Run `bin/rails test test/controllers/navigation_test.rb`. Watch them fail for the right reasons: Home is unmarked on a child's page, edit page and history, and the Dutch nav shows "Startpagina" and "Uitloggen 🐿️".
2. Pin appkit to `main` and add the shadow partial:
   - Read the newest SHA: `git ls-remote https://github.com/eirvandelden/appkit.git refs/heads/main`.
   - Set it as appkit's `ref:` in the `Gemfile`. Run `bundle update appkit`.
   - Add `app/views/appkit/shared/_nav.html.erb`. Point the existing Home tests at `appkit.navigation.home`. Drop the obsolete comment in `app/views/layouts/parent.html.erb`.
   - Run the nav tests, then `bin/rails test`. Commit.
3. Drop the app's own nav keys from the three locale files and their `ignore_unused` entries. Run `bundle exec i18n-tasks health`, `bundle exec ruby ./bin/check_i18n_normalized` and `bin/rails test`. Commit.
4. Ruby 4.0.7 and Bundler 4.0.22:
   - Set `.ruby-version` to `ruby-4.0.7` and the Dockerfile to `ARG RUBY_VERSION=4.0.7`. Confirm `ruby -v` reports 4.0.7.
   - Run `gem install bundler -v 4.0.22` once (approved).
   - Run `bundle _4.0.22_ update --bundler=4.0.22`. Only `BUNDLED WITH` moves. Then `bundle _4.0.22_ install`.
   - If Bundler tries to install 2.7.1 or any other version, stop and report (rule 8). If a native extension fails to compile, stop and report.
   - Run `bin/rails test` and `bin/rails test:system`. Commit.
5. herb 0.11.0, gem and npm together:
   - Run `bundle update herb --conservative` and `yarn upgrade @herb-tools/linter@^0.11.0`.
   - Run `npx @herb-tools/linter` and `bin/erb_lint --lint-all --allow-no-files`. Fix every new offence in the templates.
   - Run `bin/rails test`. Commit gem, package and fixes together.
6. Every other gem: run `bundle update` (full update, approved by the intent). This moves mvpa-css and exception_notification-campfire-once to their `main` HEAD, and every other gem to the newest version its constraints allow.
   - Run the full check set (Verification). Fix every failure and every deprecation warning the updates surface. No dependency is held back for a failure.
   - One culprit, or fixes that only make sense together: commit the lockfile with the fixes.
   - Several gems forcing unrelated fixes: reset `Gemfile.lock`. Commit each culprit as `bundle update --conservative <gem>` plus its fix. Then commit the remaining full `bundle update`.
7. Set `node-version: 24` in `.github/workflows/ci.yml` (approved by the intent). Commit.
8. Run the full Verification below.

## Verification

- `bin/rails test`, `bin/rails test:system`.
- `bin/rubocop`, `bin/erb_lint --lint-all --allow-no-files`, `npx @herb-tools/linter`, `bundle exec ruby ./bin/check_i18n_normalized`.
- `bin/brakeman`, `bin/bundler-audit --config config/bundler-audit.yml --update`, `bin/importmap audit`.
- `bundle outdated`: every remaining line traces to another gem's constraint (`bundle info <gem>`, dependents in `Gemfile.lock`). List them in the PR body.
- `yarn outdated`: empty.
- `ruby -v`: 4.0.7. `docker build -t sticker_app .` succeeds, and `docker run --rm --entrypoint ruby sticker_app -v` reports 4.0.7.
- `bin/dev`: sign in as a parent and as a child. Load the children list, a child's page, settings and preferences. Check the nav, the theme and the mvpa-css styling look right.
- CI on the PR: green, including the `erb-lint` job on Node 24.

## Risks

- appkit nav drift: the shadow stops later appkit nav changes from reaching this app. Each one needs a manual copy here. Etienne accepted this on 2026-10-06 over an appkit change.
- appkit `main` and mvpa-css change styling and theming; no test covers that. The `bin/dev` check covers it once.
- New cops (rubocop-rails 2.38, rubocop-minitest 0.41), Brakeman 8.1 checks and herb 0.11 rules: fix size unknown. No disable comments, no todo entries.
- Native extensions recompile under Ruby 4.0.7 (sqlite3, bcrypt, puma, nio4r, bootsnap and others). A compile failure is a toolchain problem: report it, do not fix the system.
- `bundle outdated` may keep gems besides marcel, such as net-protocol 0.4.0. Each must trace to another gem's constraint, or it is a defect in this branch.
- Dependabot has no npm ecosystem in `.github/dependabot.yml`, so it bumps the herb gem without `@herb-tools/linter`. The `dependencies` skill asks for all ecosystems. Out of scope; propose it as a separate change.
- Node 24 is proven only by CI; local Node is 25.
- Rejected: appkit's partial unchanged. Home would reach each role's home through the app's redirect, but it would never be marked current, because `/` never renders for a signed-in user.
- Rejected: an appkit change that lets the nav accept a Home path and rule. Etienne chose to keep the change in this app.

## Out of scope

- Any change in appkit.
- Loosening any Gemfile version constraint.
- Transitive gems held back by another gem's constraint, such as marcel 2.x.
- GitHub Actions version pins.
- Importmap pins: `bin/importmap outdated` finds none.
- Dependabot PRs #172–#174 and the missing Dependabot npm ecosystem.
- New features; deploying.

## Proof

- `bundle outdated` lists only gems held back by another gem's constraint → `bundle outdated`, each line traced with `bundle info <gem>`.
- `yarn outdated` lists nothing → `yarn outdated`.
- `ruby -v` reports 4.0.7 and the Dockerfile builds `ruby:4.0.7-slim` → `ruby -v`; `docker build -t sticker_app .`; `docker run --rm --entrypoint ruby sticker_app -v`.
- A parent clicks Home and lands on the children list → `test/controllers/navigation_test.rb` `parent sees a Home link as the first nav item leading to the children list` (existing, key updated).
- A parent on the children list sees Home marked → `test/controllers/navigation_test.rb` `Home is marked as the current page on the children list`.
- A parent on a child's page, edit page or history sees Home marked → `test/controllers/navigation_test.rb` `Home stays marked on a child's page, edit page and history`.
- A parent on settings, admin or preferences sees Home not marked → `test/controllers/navigation_test.rb` `Home is not marked on settings, the admin overview or preferences`.
- A child clicks Home and lands on their dashboard, with Home marked → `test/controllers/navigation_test.rb` `child sees a Home link as the first nav item leading to the dashboard` (existing, key updated) and `child sees Home marked as the current page on the dashboard`.
- The Dutch nav shows "Home", "Voorkeuren" and "Uitloggen" → `test/controllers/navigation_test.rb` `the Dutch nav shows appkit's wording`.
- A parent awards a sticker and the child sees it → `test/system/realtime_sticker_test.rb` `child dashboard updates live when a parent gives a sticker` (existing).
- Tests, system tests, linters and scans green → the Verification commands above.

Per changed file, the unit tests expected:
- `app/views/appkit/shared/_nav.html.erb`: the navigation tests above.
- `app/helpers/application_helper.rb`: unchanged; the existing `nav_section_tab` tests in `test/helpers/application_helper_test.rb` cover the rule.
- `config/locales/*.yml`, `config/i18n-tasks.yml`: `test/i18n_test.rb` `test_i18n_tasks_health` (existing).
- Each forced fix: a test that fails without it, except pure lint fixes.

Test setup: fixtures `users(:parent)`, `users(:admin)` for the admin overview, `users(:dutch_admin)` (locale `nl`), `users(:user)` (a child) and `child_profiles(:one)` for the child's pages. Sign in with `sign_in_as` from `test/test_helper.rb`. Assert with `assert_select "nav ul li:first-child a[href=?][aria-current=?]", path, "page"`, and with `count: 0` on `nav ul li:first-child a[aria-current]` for unmarked pages.

---
Domain skills applied: dependencies.
