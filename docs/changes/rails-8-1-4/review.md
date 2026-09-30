# Review

## Round 1 — 2026-09-29T09:39Z — b40b764

Verified locally: Gemfile.lock diff moves only rails-family gems 8.1.3.1 -> 8.1.4, with checksums; Gemfile `~> 8.1` unchanged; branch is up to date with origin/main; `bin/rails runner 'puts Rails.version'` prints 8.1.4; `bin/rails test -f` gives 274 runs, 0 failures, 0 errors, 0 skips; rubocop, brakeman and bundler-audit are clean. Installed activesupport 8.1.4 `ActiveSupport::JSON.decode` calls `::JSON.parse(json, **options)`, so the rails/rails#58685 fix is in the resolved bundle. json still resolves to 2.21.2.

Bugs: nothing found. Security: nothing found (no new gems, only a patch-level bump within the rails family).

Compliance:

- Acceptance "Gemfile.lock resolves rails to exactly 8.1.4": proven by `Gemfile.lock` (`rails (8.1.4)`) and the `bin/rails runner` boot check. No test is expected for a lockfile.
- Acceptance "test suite and linters are green": proven by the local run above and green CI.
- No existing test was weakened, skipped, or deleted (diff touches only `Gemfile.lock` and change docs).

- [x] Nit: Gemfile comment on the json pin says "until a Rails 8.1 release includes the backported fix"; this PR installs that release, so the comment no longer describes why the pin exists. Reword it, or remove the pin in a separate follow-up PR — `Gemfile:5` → fixed (Remove json pin and update json to 3.0.2)
- [x] Nit: intent outcome "the json pin is no longer load-bearing" has no matching acceptance criterion in spec.md, and nothing in this PR runs the app against json 3.x; the claim rests on the upstream changelog and the `**options` call in activesupport 8.1.4 — `docs/changes/rails-8-1-4/spec.md:1` → dismissed: lives only in docs/changes, which /finish deletes
- [x] Nit: plan.md has no `## Proof` section naming the checks; the proof steps are inline prose, so there is no named list to check against — `docs/changes/rails-8-1-4/plan.md:1` → dismissed: lives only in docs/changes, which /finish deletes
- [x] Nit: PR body says the PR "Prepares the app for Rails 8.1.4's backported fix"; the PR installs the fix, it does not prepare for it — PR #169 description → fixed (PR description updated to say it installs Rails 8.1.4 and moves json to 3.0.2)

## Round 2 — 2026-09-29T13:40Z — 7c22ca1

Scope: 1f9e21a "Plan json 3 update" and 7c22ca1 "Remove json pin and update json to 3.0.2". Branch is up to date with origin/main and origin/rails-8-1-4 is at 7c22ca1.

Verified locally: the Gemfile diff removes only the `json < 3` pin and its three-line comment. The Gemfile.lock diff moves only json 2.21.2 -> 3.0.2 (spec line and checksum) and drops `json (< 3)` from DEPENDENCIES; no other gem moved. Remaining json dependents are unbounded or lower-bound only (activesupport `json`, rubocop `json (>= 2.3)`). `bin/rails runner` prints Rails 8.1.4 and JSON::VERSION 3.0.2, and `ActiveSupport::JSON.decode` and `Hash#to_json` work under json 3.0.2. `bin/rails test -f` gives 274 runs, 803 assertions, 0 failures, 0 errors, 0 skips. rubocop (131 files), brakeman and `bundler-audit check --update` are clean.

JSON call audit: app, lib, config, db and test contain only `@completed_card_ids.to_json` (`app/views/child/dashboard/show.html.erb:4`), `[ ... ].to_json` in `test/integration/child_flow_test.rb`, and `JSON.parse(response.body)` in `test/integration/pwa_test.rb:8`. None passes positional options, so json 3 keyword-only options do not affect them. A heuristic scan of bundled gems' `lib/` for `JSON.parse/generate/load/dump` with a positional second argument found nothing.

Bugs: nothing found. Security: nothing found (json is a major bump of an existing dependency, no new gems, bundler-audit clean).

Compliance:

- Plan step "Remove the `json < 3` pin and its comment, run `bundle update json --conservative`, then run tests, rubocop and bundler-audit on json 3.x": done by 7c22ca1 and proven by the local run above.
- Acceptance "Gemfile.lock resolves rails to exactly 8.1.4": still holds (`rails (8.1.4)`, boot check).
- Acceptance "test suite and linters are green": holds on json 3.0.2.
- No existing test was weakened, skipped, or deleted (diff touches only `Gemfile`, `Gemfile.lock` and `plan.md`).

Round 1 dispositions, as decided by the user:

- Nit 1 (Gemfile json pin comment): closed by 7c22ca1; verified the pin and comment are gone from `Gemfile`.
- Nit 2 (spec.md lacks json 3 acceptance criterion): dismissed; lives only in docs/changes, which /finish deletes.
- Nit 3 (plan.md lacks `## Proof`): dismissed for the same reason.
- Nit 4 (PR body "Prepares the app for"): closed; the main session is updating the PR description. Not verified by this review.

No new findings.
