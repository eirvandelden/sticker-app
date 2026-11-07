# Delivery: fix-rbs-inline-lint-and-steep-offenses

## Behaviour delivered

- `bin/rubocop` is clean on this app. `rubocop-eirvandelden` now accepts a valid `# @rbs module-self: X`, the form Steep's inline parser requires, and still flags every other invalid inline RBS annotation. The 6 files keep the colon form.
- The Solid Queue migration in `db/queue_migrate/` no longer needs a signature (already on the gem's `main` as `d91402e`, picked up by the same bump).
- appkit's shared `rails-ci.yml` runs `lint` and `scan_js` on `ubuntu-latest`, so they no longer stop at boot with the `OPENSSL_3.4.0` LoadError (issue #198). appkit's own `ci.yml` `lint` job moved too.
- `steep check` stays green, and Steep still reads the self types.

Three repositories, three pull requests:

- eirvandelden/appkit#28 (`ci-lint-on-ubuntu-latest`), merged as `839ca4a`.
- eirvandelden/rubocop-eirvandelden#14 (`module-self-colon-form`), merged as `f5cca63`.
- This app: `Gemfile.lock` moves `rubocop-eirvandelden` from `32d259f` to `f5cca63`, nothing else (`bundle update --conservative`).

## Evidence

- `bin/rubocop`: "142 files inspected, no offenses detected". Before: 15 offenses in 7 files.
- `grep -rn 'module-self' app lib`: 7 lines in 6 files, all colon form.
- `steep check` with a regenerated `sig/`: "No type error detected".
- Scratch copy with `# @rbs module-self: ActionController::Base` removed from both `Authorization` files: Steep reports 11 problems in 2 files, among them `Type (::Object & ::Authorization) does not have method redirect_to`.
- Applying the old cops' autocorrect (colon removed) in a scratch copy gave 28 Steep problems, including `Syntax error: expected a token pCOLON`. That is why the colon stays.
- appkit linted against the gem branch, with its own todo and settings: 110 files, no offenses.
- appkit#28 CI: `lint`, `scan_ruby`, `types` and `test` pass. `lint` failed on appkit `main` before (run 42294981268).
- rubocop-eirvandelden#14 CI: `lint` and `test` pass. Locally: 48 runs, 0 failures.

## Check results

- `bin/rails test`: 334 runs, 1184 assertions, 0 failures.
- `bin/brakeman`: 0 security warnings.
- `bin/bundler-audit check --update`: no vulnerabilities.
- `bin/rubocop`: no offenses.

## Review outcome

- appkit: round 1 had 2 Important findings: a missing CHANGELOG entry, and appkit's own `ci.yml` `lint` with the same LoadError. Both were fixed. Etienne widened that change to `ci.yml`. Round 2 was clean.
- rubocop-eirvandelden: round 1 had 1 Important finding and 2 Nits. The Important finding was that `module-self: T -- description`, valid in RBS 4.2, was flagged; a regression test came first, then the fix. One Nit was fixed. The other was dismissed: the Law of Demeter chain matches upstream `InvalidTypes`. Round 2 was clean.
- sticker-app: round 1 was clean.

## Follow-ups, not in this change

- The dotfiles copy `~/Developer/dotfiles/rubocop/.rubocop.yml` still has the upstream `InvalidTypes` and `KeywordSeparator`. It cannot load the gem's cops (Etienne's decision: leave it).
- The appkit reviewer's observation: `ci.yml` uses the same `vendor/bundle` cache key on `ubuntu-slim` and `ubuntu-latest`. A bundle built on `ubuntu-latest` can then restore on the slim jobs. This is the likely root cause of the LoadError, and `scan_ruby` and `types` can hit it once they load `openssl`.
- Bump `rubocop-eirvandelden` in appkit and other consumers.
- Earlier follow-ups stay open: appkit `sig/` adoption, `steep` as a dev gem, and dropping the `@type const …: untyped` and `@rbs skip` markers.
- appkit's `origin` uses HTTPS. Its pushes stop at a 1Password prompt, so this delivery pushed appkit over SSH.
