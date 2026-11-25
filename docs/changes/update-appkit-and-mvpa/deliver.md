# Delivery account: update-appkit-and-mvpa

## Behaviour delivered

The app runs on appkit `42e22b3` and mvpa-css `6e4fc63`. Parents, admins and children see a rail of hubs with a hub column for the current hub. A parent has Kinderen, Instellingen and Account, and an admin also has Beheer. A child has Dashboard and Account. The Account hub holds Voorkeuren, Profiel and Uitloggen, a submit page. Landing tiles and record back links follow the menu origin through saves. The earlier confirm dialog, action row and button work stays.

## Evidence

- Visual check at 1400, 900 and 375px as parent, admin and child: rail and hub column on wide screens, rail only at 900px, tab bar with only the hubs on a phone.
- Flows walked in headless Chrome at 1400 and 375px: Instellingen to child edit and back, Account to Profile, the admin Users tile to the user list, edit and save.

## Check results

- `bin/rails test` without `test/bin`: 364 runs, 0 failures.
- `bin/rubocop`, `bin/erb_lint`, the i18n check and the herb linter: clean.
- `bin/brakeman`, `bin/importmap audit` and `bundle-audit`: no findings.

## Review outcome

Ten rounds. Rounds 8 to 10 closed every finding as fixed. No finding is open.

## Limitations

- `test/bin/rails_test.rb` fails locally and on `main`, because the local bundler prints StubSpecification lines.
- Local system tests error at teardown (Selenium `* is not a valid URL`) and `steep check` is not installed locally. CI runs both. Sign-out with forgery protection, the delete dialog and the live card update rest on CI.
