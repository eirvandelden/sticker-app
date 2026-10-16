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
