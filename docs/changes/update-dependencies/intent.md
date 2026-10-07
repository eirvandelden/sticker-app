# Intent: Update dependencies to their latest versions

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

Amended 2026-10-06 in the plan stage: no appkit change. The app shadows appkit's nav partial instead (see Flagged concerns).

## Problem

The app runs on outdated dependencies. Six gems named in the Gemfile are behind (brakeman, herb, mvpa-css, selenium-webdriver, solid_cable, thruster), and so are many transitive gems. The herb npm linter is at 0.10.3 while 0.11.0 exists. Ruby is at 4.0.6 while 4.0.7 exists. CI runs the linter on Node 22 while Node 24 is the newest LTS. appkit is pinned to a ref 36 commits behind its `main`, so the app misses appkit's nav, e-ink theme and login-redirect changes. Dependabot opens one PR per gem (#172, #173, #174 are open now), which leaves the app partly updated at any moment.

## Proposed outcome

Every dependency is at the newest version its constraints allow, in one branch, with all tests, system tests, linters and security scans green. The app uses appkit's current nav markup and wording through its own copy of appkit's nav partial. Home in that nav still leads each role to its own home page and shows where a parent is.

## Affected users and systems

- Parents and children: they see appkit's current nav wording, theming and login behaviour.
- Developers: local Ruby moves to 4.0.7 (already installed with rv).
- CI: the herb linter job runs on Node 24.
- Production image: the Dockerfile base image moves to Ruby 4.0.7.
- appkit: no change. The app shadows appkit's nav partial (see Flagged concerns).

## Constraints

- Rule 11: a full `bundle update` is explicitly approved for this change.
- Rule 13: the `Dockerfile` `ARG RUBY_VERSION` change and the `node-version` change in `.github/workflows/ci.yml` are explicitly approved for this change.
- `.ruby-version` and the Dockerfile `ARG RUBY_VERSION` stay in sync.
- The herb gem and the `@herb-tools/linter` npm package stay on the same minor version.
- When an update breaks the app or a lint, the app gets fixed in this branch. No dependency is held back for that reason.
- No change in appkit. The nav fix lives in this app.
- No deploy happens as part of this change.

## In scope

- All gems in `Gemfile.lock`, direct and transitive, at the newest version their constraints allow.
- mvpa-css, rubocop-eirvandelden and exception_notification-campfire-once at the newest commit on their `main`.
- `@herb-tools/linter` in `package.json` and `yarn.lock` at 0.11.0.
- Ruby 4.0.7 in `.ruby-version` and the Dockerfile.
- `node-version` in `.github/workflows/ci.yml` at 24.
- App changes that the updates force: new lint offences, new appkit behaviour, test fixes for changed behaviour.
- appkit's pin in the Gemfile at the newest commit on appkit `main`.
- Both layouts render the app's own copy of appkit's nav partial, with the app's own Home target and current-page rule.
- The nav shows appkit's own wording. The app's own nav translation keys go if nothing else uses them.

## Out of scope

- Any change in appkit.
- Loosening any Gemfile version constraint.
- Transitive gems held back by another gem's own constraint (for example marcel 2.x, held back by Rails).
- GitHub Actions version pins: they are already the newest.
- The open Dependabot PRs #172–174: Dependabot closes them itself once this merges.
- New features beyond what the updated dependencies require.
- Deploying.

## Acceptance criteria

- `bundle outdated` lists only gems held back by another gem's constraint.
- `yarn outdated` lists nothing.
- `ruby -v` in the worktree reports 4.0.7, and the Dockerfile builds `ruby:4.0.7-slim`.
- A parent clicks Home and lands on the children list.
- A parent on the children list sees Home marked as the current page.
- A parent on a child's page, edit page or history sees Home marked as the current page.
- A parent on settings, admin or preferences sees Home not marked.
- A child clicks Home and lands on their dashboard, with Home marked as the current page.
- The Dutch nav shows "Home", "Voorkeuren" and "Uitloggen", appkit's wording.
- A parent awards a sticker to a child, and the child sees it on their sticker card.
- Tests, system tests, rubocop, erb_lint, herb lint, the i18n normalization check, brakeman, bundler-audit and importmap audit are all green.

## Flagged concerns

- "Move appkit to latest `main`" conflicts with "keep today's Home link": appkit `main`'s nav hardcodes `root_path` as Home's target and `current_page?(root_path)` as its marker, with no override. Chosen side (amended 2026-10-06): no appkit change. The app shadows appkit's nav partial with its own `app/views/appkit/shared/_nav.html.erb`: appkit `main`'s markup and wording, with the app's Home target and current-page rule. Cost: later appkit nav changes no longer reach this app on their own. Rejected: accepting the regression, and changing appkit first.

## Open questions

None.
