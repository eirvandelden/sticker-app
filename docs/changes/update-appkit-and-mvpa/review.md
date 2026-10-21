## Round 1 — 2026-10-20T21:00Z — 049bd6b

Checks run: bin/rails test (300 runs, green), bin/rails test:system (15 runs, green), bin/rubocop, erb_lint, i18n normalize (all clean).
Acceptance: gem pins match (Gemfile/lock move only appkit and mvpa-css; db/schema.rb unchanged vs origin/main); dialog delete proven by integration and system tests; action rows proven per page; PWA tests present; en/nl/it keys added in step.

- [x] Nit: The in-dialog confirm Delete (`button_to … method: :delete`) is red only through mvpa.css's DELETE-form rule, and no test asserts it. Assert `dialog footer form button.button-danger` or the red state — `app/views/admin/users/index.html.erb:37` → fixed in df507d9 (the confirming Delete carries `button-danger`; a test asserts it)
- [x] Nit: The opener has no `aria-haspopup="dialog"`. The dialog is labelled correctly with `aria-labelledby`, and Escape closes it natively — `app/views/admin/users/index.html.erb:32` → fixed in df507d9 (`aria-haspopup="dialog"` on the opener; a test asserts it)
- [x] Nit: The login layout override puts `data-controller` before `tag.attributes`, unlike appkit's layout, so the diff is wider than the flash move. Harmless; note it when removing the override — `app/views/layouts/login.html.erb:2` → dismissed: the Herb linter's `erb-no-output-in-attribute-name` rule fails when the ERB attribute comes first; the static attribute stays first (0fc559b, kept in 69f034c)
