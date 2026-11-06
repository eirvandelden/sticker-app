# Review: Align views with journal_administration patterns

## Round 1 — 2026-11-06 20:46 UTC — 02eaa3a

- [ ] Important: Scenario 17 ("zakgeld and kleedgeld owed counts are shown distinctly, not merged") was weakened: it used to match `Pocket money.*1 payment still owed` in one element, and now asserts only that some `dd` reads "1 payment still owed" and some `dd` reads "Up to date". Swapped kinds would pass. Pair each term with its detail (for example `dt` text then the next `dd`). Scenarios 14 and 15 lost the kind the same way — `test/integration/child_flow_test.rb:161` → fixed (Pair each allowance term with its detail in the view tests)
- [ ] Nit: The allowance summary tests assert `dt` and `dd` text separately, so they do not prove which kind is owed or which `dd` holds Mark given — `test/integration/allowance_summary_test.rb:17` → fixed (Pair each allowance term with its detail in the view tests)
- [ ] Nit: "turn off allowance still deletes through the delete form" sends `DELETE` straight to the route and never uses the delete form or the `form=` button; the name claims more than the test proves — `test/integration/action_row_test.rb:76` → fixed (Pair each allowance term with its detail in the view tests)
- [ ] Nit: The kind-less allowance test matches the `h2` with `/error/`, not the counted `errors.template.header` text that the Proof line asks of every form-error test — `test/integration/form_errors_test.rb:66` → fixed (Pair each allowance term with its detail in the view tests)
- [ ] Nit: `params:` starts at column 0, out of line with the `patch` call it belongs to — `test/integration/form_errors_test.rb:22` → fixed (Pair each allowance term with its detail in the view tests)

Checks: `bin/rails test` 334 runs green, `bin/rails test:system` 23 runs green (fit test unchanged), erb_lint, herb linter, `check_i18n_normalized` and Brakeman clean. Rubocop on the changed Ruby files is clean; its 8 offenses sit in files this branch does not touch.

Compliance: every acceptance criterion in `intent.md` has a test in the diff, and every test named in `plan.md`'s `## Proof` exists. Apart from the Important finding above, no existing test was skipped, deleted or loosened.

## Round 2 — 2026-11-06 20:52 UTC — 74f4d0e

No findings.

Round 1 closure: `assert_allowance_detail` pairs each `dt` with its next `dd`, so scenarios 14, 15 and 17 and the allowance summary tests now fail if the kinds swap. The mark-given form is asserted in the owed kind's `dd` and absent from the other. The turn-off test reads the button's `form` attribute and deletes through that form's `action`. The kind-less alert test compares the `h2` with `errors.template.header` for the listed count. The `params:` indent is fixed.

Bugs and security: no new defects in the views. Titles go through `tag.h1` and `safe_join`, so user names and emails stay escaped. No `raw` or `html_safe`. Strong parameters and controllers are untouched.

Design: no Ruby in `app/` changes, so no signature is due. The new test helper follows the unsigned style of `AuthenticationTestHelper`. `shared/_allowances` keeps one `owed_periods.count` per allowance, as `plan.md`'s Complexity section states. No glossary exists.

Checks: `bin/rails test` 334 runs green, `bin/rails test:system` 23 runs green (fit test unchanged), Rubocop clean on the changed test files, erb_lint, herb linter, `check_i18n_normalized` and Brakeman clean.
