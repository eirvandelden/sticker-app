# Delivery account: align-views-with-journal-patterns

## Behaviour delivered

Every app-owned page renders one `<h1>` in a `main > header` title bar, with its page links in that header's `<nav>`. The wrapper `<section>` and `<div>` elements are gone. The child edit page is one `<article>` with five `<section>`s, each starting with an `<h2>`: name, avatar, goals, Zakgeld, Kleedgeld.

Forms with errors show one counted alert `<aside>` from a shared partial. Every data form ends in an action row `<footer>` with Delete (only for a persisted allowance), Cancel and Save. Cancel is plain, Save is filled and "Turn off allowance" is red.

Allowances read as a `<dl>` from one shared partial on the parent card and the child dashboard. The admin users table is a labelled stacking table. Stickers are `<li>` items in a `<ul>`. The push button is a `<section>` with an `<h2>` at the end of `<main>`. `dashboard_row.css` keeps its compact layout; only one selector changed.

## Decisions for Etienne

- "Every form" means every data form: the five child edit forms, the inline goal form, the admin user form and the profile form. One-button `button_to` forms keep their single button. Etienne confirmed this reading.
- The implement stage dropped the wrapping `<section>` around the allowance summary on the child dashboard, to avoid an empty section. The profile edit form uses the default `common.save` label, so `users.profiles.edit.save` was removed.

## Evidence

- `bin/rails test`: 334 runs, 0 failures, including `i18n-tasks health`.
- `bin/rails test:system`: 23 runs, 0 failures on the final run, including the unchanged `parent_dashboard_fit_test`. A first run had one error in `page_structure_test.rb:18` while another pane ran tests at the same time. The file passed alone and the full suite passed on the next run.
- `bin/erb_lint --lint-all`: clean. `npx @herb-tools/linter`: all files clean. `check_i18n_normalized`: normalized. `bin/brakeman`: no warnings. `bin/bundler-audit`: no vulnerabilities. Rubocop on the changed Ruby files: clean.
- Not verified: nobody looked at the pages by eye at 375px and at desktop width. The system tests check the dashboard fit, the admin table stacking and horizontal overflow on that page.

## Check results

Pre-existing red on `main`, not caused by this change: Rubocop `Style/RbsInline/KeywordSeparator` in 6 app files, `Style/RbsInline/MissingTypeAnnotation` in one migration, and 1 Steep problem. A separate change, `fix-rbs-inline-lint-and-steep-offenses`, handles them in its own worktree (rule 25).

## Review outcome

Round 1 (Claude reviewer): 1 Important and 4 Nit findings, all in tests. All five fixed in commit "Pair each allowance term with its detail in the view tests". Round 2: no findings. The Codex review was off for this change.
