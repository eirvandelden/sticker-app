# Review

## Round 1 — 2026-09-29T09:39Z — b40b764

Verified locally: Gemfile.lock diff moves only rails-family gems 8.1.3.1 -> 8.1.4, with checksums; Gemfile `~> 8.1` unchanged; branch is up to date with origin/main; `bin/rails runner 'puts Rails.version'` prints 8.1.4; `bin/rails test -f` gives 274 runs, 0 failures, 0 errors, 0 skips; rubocop, brakeman and bundler-audit are clean. Installed activesupport 8.1.4 `ActiveSupport::JSON.decode` calls `::JSON.parse(json, **options)`, so the rails/rails#58685 fix is in the resolved bundle. json still resolves to 2.21.2.

Bugs: nothing found. Security: nothing found (no new gems, only a patch-level bump within the rails family).

Compliance:

- Acceptance "Gemfile.lock resolves rails to exactly 8.1.4": proven by `Gemfile.lock` (`rails (8.1.4)`) and the `bin/rails runner` boot check. No test is expected for a lockfile.
- Acceptance "test suite and linters are green": proven by the local run above and green CI.
- No existing test was weakened, skipped, or deleted (diff touches only `Gemfile.lock` and change docs).

- [ ] Nit: Gemfile comment on the json pin says "until a Rails 8.1 release includes the backported fix"; this PR installs that release, so the comment no longer describes why the pin exists. Reword it, or remove the pin in a separate follow-up PR — `Gemfile:5` →
- [ ] Nit: intent outcome "the json pin is no longer load-bearing" has no matching acceptance criterion in spec.md, and nothing in this PR runs the app against json 3.x; the claim rests on the upstream changelog and the `**options` call in activesupport 8.1.4 — `docs/changes/rails-8-1-4/spec.md:1` →
- [ ] Nit: plan.md has no `## Proof` section naming the checks; the proof steps are inline prose, so there is no named list to check against — `docs/changes/rails-8-1-4/plan.md:1` →
- [ ] Nit: PR body says the PR "Prepares the app for Rails 8.1.4's backported fix"; the PR installs the fix, it does not prepare for it — PR #169 description →
