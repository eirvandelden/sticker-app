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

## Flows in the browser (2026-11-25)

A second temporary headless Chrome test, deleted afterwards, walked the flows at 1400px and 375px with assertions on the back link and the URL. A person read the screenshots at both widths.

- Instellingen, child, save: the child edit page shows "‹ Child settings". After Save the URL is still `…/edit?from=settings.child_settings` and the back link still returns to `/parent/settings`.
- Account, Profile: the profile page opens with `from=account` and shows "‹ Account" and "Edit".
- Admin dashboard: the Users tile opens the user list. At 375px the list shows "‹ Admin"; opened from the hub column at 1400px it shows no back link.
- User list, Edit, Save: the user page shows "‹ Users", and that link returns to `/admin/users`. Every deletable row shows a red Delete.
- Not seen in this run: the delete dialog and the child card's live update. `confirm_dialog_test` and `realtime_sticker_test` prove them in CI.
- 375px admin dashboard: the Recent Signups table is cramped. It was before this change, and the plan defers stacking tables.
