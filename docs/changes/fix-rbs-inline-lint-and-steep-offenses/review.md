# Review: fix-rbs-inline-lint-and-steep-offenses

The repository has no `REVIEW.md` or `REVIEW.local.md`; the reviewer's default Bugs, Security, Compliance and Design passes apply.

## Round 1 — 2026-11-07T10:12Z — deaa7ff

Nothing found.

Diff under review: `Gemfile.lock` moves `rubocop-eirvandelden` from `32d259f` to `f5cca63` and nothing else, plus `intent.md` and `plan.md`. `f5cca63` is the merge of `eirvandelden/rubocop-eirvandelden#14` on that repository's `main`. appkit `main` carries `35063fb ci: run lint and scan_js on ubuntu-latest`. The branch has no commits to rebase onto: `origin/main` is its base.

Checks run on `deaa7ff`:

- `bin/rubocop`: 142 files inspected, no offenses detected.
- `steep check` after a fresh `sig/` (`rbs collection install --frozen`, `db:prepare rbs_rails:all`): No type error detected.
- `bin/rails test`: 334 runs, 0 failures, 0 errors, 0 skips.
- `bin/brakeman`: no warnings. `bundler-audit`: no vulnerabilities.

Bugs: none. The lockfile change is a single revision line; no other gem moved.

Security: none. No code, route, parameter or dependency set changes; the bumped gem is a development-only lint config.

Compliance, each acceptance criterion next to its proof:

- `bin/rubocop` prints "no offenses detected" and the 6 files keep `# @rbs module-self: X` → `bin/rubocop` clean; `grep -rn 'module-self' app lib` gives 7 colon-form lines in 6 files.
- `steep check` prints "No type error detected" with a regenerated `sig/` → confirmed.
- Removing `ActionController::Base` from both `Authorization` files makes `steep check` fail on `redirect_to` → confirmed in a scratch copy: `Type (::Object & ::Authorization) does not have method redirect_to`.
- `rubocop-eirvandelden` accepts `module-self: Foo` and still flags `#: (Integer -> void` → covered by that gem's tests in its merged pull request #14, outside this diff.
- `rubocop-eirvandelden` skips `db/queue_migrate/` and still demands signatures in `app/models/` → covered by that gem's tests (commit `d91402e` and #14), outside this diff.
- `ci / lint` and `ci / scan_js` pass on this app's pull request → not yet checkable: `ci.yml` runs on `pull_request` only and no pull request exists yet. `deliver` opens it; check `gh pr checks` then.

No existing test was weakened, skipped or deleted.

Design: no Ruby changed in this app, so no unsigned public method, no Law of Demeter violation and no N+1 loop. No glossary exists to check avoided words against.
