# Review: inline-rbs

## Round 1 — 2026-10-16T17:58Z — 8c47f45 (codex)

No findings.

## Round 2 — 2026-10-16T18:00Z — 8c47f45 (claude)

Checked: steep check clean, unsigned-method script 0, YARD grep empty, no steep:ignore, rubocop and 274 tests green, include splits keep the ancestor order (verified by reading ancestors), Current#account has no callers.

- [ ] Nit: `ensure_child_profile` is typed `ChildProfile?` but never returns nil (it returns the existing profile or `create_child_profile!`); `ChildProfile` is the accurate type — `app/models/user.rb:38` → fixed (chore: type ensure_child_profile as non-nil)
- [ ] Nit: `Current.user` is stubbed as `untyped`, so nullability is not checked in `resolve_layout`, `ensure_*` and `Current#child_profile`; it hides the real `User?` — `sig/stubs/rails.rbs:20` → dismissed: `Current.user` is nil when logged out. Typing it `User?` flags about eight call sites that rely on Appkit's authentication, and fixing them changes behaviour, which the intent excludes. A non-nil type would be false.
- [ ] Nit: `@rbs @user: User` sits above `private` and attaches to no declaration, and the file is a model-side shadow of the controller concern typed with `module-self: ActionController::Base` — `app/models/concerns/authorization.rb:2` → fixed (chore: drop the inert @user annotation from Authorization)
- [ ] Nit: CI `gem install steep` PATH under `setup-rv` and the global Steep rbs version versus the 4.x lockfile cannot be verified locally; confirm on the first CI run — `.github/workflows/ci.yml:49` → dismissed: not checkable locally. The first CI run on the pull request verifies it, and a failure there gets fixed before the review closes.

## Round 3 — 2026-10-16T18:04Z — a383c6d (codex)

No findings.

## Round 4 — 2026-10-16T18:10Z — a383c6d (claude)

Checked: both fixes are correct. `child_profile || create_child_profile!` is equivalent to the old `present?` guard and never returns nil, so `ChildProfile` is the true type. Removing the `@rbs @user` line leaves `private` and the method sigs intact. Both dismissals hold: `Current.user` is nil when logged out, so a non-nil type would be false and `User?` would force behaviour changes outside scope; the CI steep job cannot be run locally. steep check clean, rubocop clean, 274 tests green.

No findings.

## Round 5 — 2026-10-17T05:57Z — 8b7bd9e (claude)

Checked: `steep check` clean; the type-error probe (run in a scratch copy) fails with exactly two `Ruby::ArgumentTypeMismatch` in `steep_probe.rb`; YARD grep empty; comment-block check `0 without summary`, `0 without description`; unsigned-method check `0 unsigned or invalid`; the `app/` diff since `50589d4` is comment lines only; rubocop clean, 274 tests green, brakeman and bundle-audit clean; no test or test file changed. Descriptions read against each method body; all match except the three below. Compliance: steep exits 0 → `steep check`; wrong argument type fails → probe; no YARD tag → grep; signature and description on every method → both checks; summary on every class and module → comment-block check; tests, rubocop, brakeman green → run here; Steep job passes on the PR → pending: PR #180's head is still `57b7ba7`, and `origin/inline-rbs` holds that commit (`Remove change artifacts for inline-rbs`), which this branch lacks, so a plain push is refused as non-fast-forward.

- [ ] Nit: `ChildProfile#zakgeld` is described as "the weekly pocket money allowance", but it selects by `kind` only and a parent can set a zakgeld allowance to `monthly`; drop "weekly" — `app/models/child_profile.rb:40` → fixed (docs: correct three model descriptions)
- [ ] Nit: the `AllowancePeriod` summary says "pocket-money payment", but periods belong to kleedgeld allowances too; `Allowance`'s own summary names both — `app/models/allowance_period.rb:1` → fixed (docs: correct three model descriptions)
- [ ] Nit: the `NibudAdvice` summary says it suggests "a pocket money amount", but it also suggests the monthly kleedgeld amount (`KLEEDGELD_MONTHLY`) — `app/models/nibud_advice.rb:1` → fixed (docs: correct three model descriptions)
- [ ] Nit: plan step 5 (refresh `rbs_collection.lock.yaml` with `bin/rbs collection install` and commit it alone) did not happen, and the plan records no decision to skip it; a refresh adds the `optparse` and `rbs` entries. `--frozen` still passes and Steep stays clean either way — `rbs_collection.lock.yaml:1` → dismissed: `bin/rbs collection install` rewrites the YAML indentation and the yamllint pre-commit hook refuses the result. The old lock passes `--frozen` and `steep check`, which is what CI runs. The refresh adds nothing CI needs.

## Round 6 — 2026-10-17T05:59Z — 9525a9c (claude)

Checked: the three corrected comments read true against the code. `ChildProfile#zakgeld` selects by `kind == "zakgeld"` only, with no frequency filter. `AllowancePeriod` belongs to an `Allowance`, whose `kind` enum has zakgeld and kleedgeld. `NibudAdvice` has both `ZAKGELD_WEEKLY` and `KLEEDGELD_MONTHLY` tables. The dismissal holds: CI runs `--frozen` and `steep check`, and the old lock satisfies both per round 5; a lock refresh adds nothing CI needs. The commit since round 5 changes three comment lines only; rubocop on `app/models` is clean. `bundle exec steep` fails here with a bundler environment error, so Steep was not re-run; the diff has no code change.

No findings.
