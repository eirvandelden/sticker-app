# Evidence: update-appkit-and-mvpa

## Visual check of the rail and hub column (2026-11-25)

A temporary headless Chrome system test signed in as the parent, the admin and the child. It took screenshots at 1400, 900 and 375px of the Kinderen list, a child page, the admin pages and the Account hub. A person read the screenshots. The test file was deleted afterwards and is not in the branch.

- 1400px: the rail and the hub column share one card. The current hub is filled blue. A child page shows the back link "‹ Overview" and the hub column lists Overview as the current page.
- 900px: only the rail shows, with the Account hub filled when current. The Account hub lists Preferences, Profile and Logout as tiles.
- 375px: the tab bar holds only the hubs: Children, Settings and Account for a parent, Dashboard and Account for a child. The admin rail adds Admin. The give-sticker and give-penalty buttons of all three children fit.
- Unverified locally: signing out with forgery protection on. The system tests that prove it only run in CI.

## Checks (2026-11-25)

- `bin/rails test` without `test/bin`: 364 runs, 0 failures. `test/bin/rails_test.rb` fails locally and on `main`, because the local bundler prints StubSpecification lines.
- `bin/rubocop`, `bin/erb_lint`, the i18n check and `npx @herb-tools/linter`: clean.
- `bin/brakeman`, `bin/importmap audit` and `bundle-audit check --update`: no findings.
- Local system tests error at teardown with `* is not a valid URL`. `steep check` is not installed locally. CI runs both.
