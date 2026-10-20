# Review: update-dependencies-followup

## Round 1 — 2026-10-17T08:48Z — 3976200 (codex)

`codex review --base origin/update-dependencies` (stacked branch; base is `update-dependencies`, not `main`). No findings. Its run of `test/controllers/navigation_test.rb` hit a SQLite lock from a concurrent test run by the coordinator; `test/views/appkit_shadows_test.rb` passed.

## Round 2 — 2026-10-17T08:50Z — 3976200 (claude)

Diff: `git diff origin/update-dependencies...HEAD` (stacked branch). Verified: appkit `ref:` and `Gemfile.lock` revision equal appkit `main` (`e47907f`); mvpa-css revision equals its `main` (`c17bfe8`); appkit's `login` layout has no `yield :head`, so `turbo_page_requires_reload` renders nothing there. `test/views/appkit_shadows_test.rb` and `test/controllers/navigation_test.rb` pass (16 runs, 0 failures); rubocop is clean on both. No existing test was weakened, skipped or deleted.

Compliance:

- `bundle outdated` lists only held-back gems — check (coordinator: only marcel, held by Rails).
- `yarn outdated` lists nothing — check (coordinator: empty; `source-map-js` 1.2.2).
- Gemfile pins appkit at appkit `main` — check (`git ls-remote` matches `e47907f`).
- Nav and login carry appkit `main`'s markup — `test/views/appkit_shadows_test.rb` both tests; `navigation_test.rb` `the Dutch nav shows appkit's wording`, `the login page is headed with the app name`.
- Parent Home lands on children list, marked — `navigation_test.rb` `parent sees a Home link ...`, `Home is marked as the current page on the children list`.
- Parent Home marked on child pages, unmarked on settings/admin/preferences — `navigation_test.rb` `Home stays marked ...`, `Home is not marked on settings or preferences for a parent` (new), `Home is not marked on settings, the admin overview or preferences`.
- Child Home lands on dashboard, marked — `navigation_test.rb` `child sees a Home link ...`, `child sees Home marked ...`.
- Parent awards sticker, child sees it — `test/system/realtime_sticker_test.rb`, `test/integration/parent_flow_test.rb`.
- herb lint, Ruby version, Docker build, tests and linters green — check (coordinator evidence).
- CI green on the pull request — missing (the pull request does not exist yet; `deliver` opens it).

- [ ] Nit: The nav shadow test compares lines with array difference (`-`), which ignores line order and duplicate lines. A reordered nav, or a dropped repeated line such as `</li>`, passes the test. A positional diff (for example, replace the one Home line on each side, then `assert_equal` the full arrays) would catch drift fully. — `test/views/appkit_shadows_test.rb:9` → fixed (Compare the nav shadow with appkit's line by line)
- [ ] Nit: The new parent test asserts only `count: 0` on `li:first-child a[aria-current]`, so it also passes if the nav, or the Home link, does not render on that page. Asserting that the Home link is present and has no `aria-current` (for example `a[href=?]:not([aria-current])` with `parent_children_path`) would make it non-vacuous. The admin test above it has the same shape. — `test/controllers/navigation_test.rb:100` → fixed (Assert the unmarked Home link is present)

## Round 3 — 2026-10-17T08:59Z — 057a75f (codex)

`codex review --base origin/update-dependencies`. No findings. Its focused view, navigation and authentication tests passed (33 runs, 0 failures).

## Round 4 — 2026-10-17T09:01Z — 057a75f (claude)

Diff: `git diff origin/update-dependencies...HEAD` (stacked branch). Both Round 2 fixes hold: the nav shadow test now drops the one Home line by position and compares the full arrays with `assert_equal`, so order and duplicate lines count; both "not marked" tests now require `a[href=?]:not([aria-current])` with `parent_children_path`, so a missing nav or Home link fails them. The admin test change is a strengthening, not a weakening. No existing test was skipped or deleted. Ruby 4.0.7: `bin/rails test` 287 runs, 0 failures; focused view, navigation and auth tests 33 runs, 0 failures; `bin/rubocop` clean; erb_lint clean on the login view. appkit `main` is still `e47907f`; rubocop-eirvandelden (`5f82215`) and exception_notification-campfire-once (`2452ef9`) are still at their `main`. The login directive renders nothing: `Appkit::SessionsController` uses appkit's `login` layout, which has no `yield :head`. Bugs and security passes: nothing found.

Compliance: as Round 2, except the first criterion and the mvpa-css scope item now fail (finding below). CI green on the pull request stays missing until `deliver` opens it.

- [ ] Important: mvpa-css is no longer at the newest commit on its `main`. `Gemfile.lock` locks `c17bfe8`; `eirvandelden/mvpa.css` `main` moved to `b761e75` at 2026-10-17T08:50:54Z (PR #42 merge, 26 commits ahead). The intent puts mvpa-css at its newest `main` commit in scope, and acceptance criterion 1 allows only held-back gems in `bundle outdated`. The new commits touch no CSS (`.ruby-version`, `AGENTS.md`, `Gemfile.lock`, `lefthook.yml`, `test/git_hooks_test.rb`, `yarn.lock`), so the update is low-risk. — `Gemfile.lock:23` → fixed (Update mvpa-css to its newest main)

## Round 5 — 2026-10-17T09:27Z — 057a75f + staged Gemfile.lock (codex)

`codex review --base origin/update-dependencies`, with the mvpa-css `b761e75` lockfile change staged. No findings.

## Round 6 — 2026-10-20T08:19Z — cc3f7d5 (codex)

`codex review --base origin/update-dependencies`, after mvpa-css moved to `2be440b`, appkit to `9e7fa41`, and rubocop-eirvandelden and sqlite3 were updated. No findings. Its unit tests passed (287 runs); its browser tests could not start Chrome in its sandbox. The coordinator ran the system tests on this SHA: 13 runs, 0 failures.

## Round 7 — 2026-10-20T08:21Z — cc3f7d5 (claude)

Diff: `origin/update-dependencies` no longer exists (finding 1), so the diff ran against `7c47b13`, the local `update-dependencies` head this branch sits on: `git diff 7c47b13...HEAD`, plus `057a75f..HEAD` for the three new commits. Ruby 4.0.7: `bin/rails test` 287 runs, 0 failures; `bin/rubocop` 132 files, no offences; `bundle outdated` lists only marcel (held back by Rails). Pins via `git ls-remote`: mvpa-css `2be440b`, rubocop-eirvandelden `6d41c35` and exception_notification-campfire-once `2452ef9` are each repo's `main` HEAD; appkit is not (finding 2). The new transitive gems rubocop-rbs_inline 2.0.0 and rbs-inline 0.14.0 come only from rubocop-eirvandelden's own dependency; the full update is pre-approved, and rubocop stays clean with them.

mvpa-css `2be440b` judgement holds. Both layouts render `appkit/shared/flashes` (a `section[data-mvpa-flashes]`) as a direct child of `<body>`, before `<main>`, and no other view renders it. The app has no `overflow-x` wrapper and no `flex-direction`/`flex-wrap` rule on `main > header nav`; its only `flex-wrap` is the confetti card footer. The page title-bar navs (settings, stickers, admin users) now lay out as a wrapping row, which is mvpa's intended change and needs no app code. Stacking tables and pull-down menus are opt-in new features, out of scope. appkit's login layout is appkit's own and out of scope.

Bugs and security passes: nothing found in the three new commits. No existing test was weakened, skipped or deleted.

Compliance: as Round 4, with criterion 1 (`bundle outdated`) and the mvpa-css scope item now met. The appkit pin criterion fails (finding 2). The `yarn outdated` and `source-map-js` checks no longer apply as written once the branch is on `main` (finding 1). CI green on the pull request stays missing until `deliver` opens it.

- [ ] Important: The base branch is gone. PR #181 merged `update-dependencies` into `main` at 2026-10-20T08:17:57Z as rebased commits (`41645a9`, not this branch's `7c47b13`), and `origin/update-dependencies` was deleted. `main` also carries PR #182 (yarn replaced by npm: `yarn.lock` deleted, `package-lock.json` added). This branch must rebase onto `origin/main` (rule 20; the intent's stacking constraint ends once `update-dependencies` merges), and its pull request must target `main`. Commit `3976200` edits `yarn.lock`, which `main` deleted, so the rebase hits a modify/delete conflict. `main`'s `package-lock.json` already holds the versions `3976200` set (is-core-module 2.17.0, hasown 2.0.4, nanoid 3.3.20, picomatch 4.0.7, postcss-import 17.0.1, source-map-js 1.2.2), so `yarn.lock` stays deleted. The `yarn outdated` and `yarn why source-map-js` proofs then need their npm equivalents (`npm outdated`, `npm ls source-map-js`). — `docs/changes/update-dependencies-followup/intent.md:25` → fixed (docs: intent and plan for update-dependencies-followup)
- [ ] Important: appkit is no longer pinned at its newest `main` commit. `Gemfile` pins `9e7fa41`; appkit `main` moved to `d82b9c7` at 2026-10-20T08:09:45Z (PR #22 merge, 20 commits ahead, 0 behind). The intent requires the pin at the newest `main` commit. The range changes only appkit's `.github/workflows/ci.yml`, `AGENTS.md` and `lefthook-local.yml`, with no view, helper, layout or Ruby code, so the shadow views and `appkit_shadows_test.rb` stay valid. — `Gemfile:8` → fixed (Pin appkit at d82b9c7, its newest main)

## Round 8 — 2026-10-20T08:28Z — cc8c1dd (codex)

`codex review --base origin/main`, after the rebase onto `main` (PR #181 merged; yarn replaced by npm) and the appkit pin at `d82b9c7`. No findings. Its unit tests passed (292 runs); its browser tests could not start Chrome in its sandbox. The coordinator ran the system tests on the appkit pin commit: 13 runs, 0 failures.

## Round 9 — 2026-10-20T08:31Z — cc8c1dd (claude)

Diff: `git diff origin/main...HEAD` (merge base `31d91b1`, the PR #181 merge); no uncommitted changes besides this file. Rebase check: `git range-diff 7c47b13..cc3f7d5 origin/main..7784ff0` shows all 10 remaining commits identical (`=`); only `3976200` "Update npm packages to their latest versions" is gone, which is the expected skip (it touched only `yarn.lock`, which `main` deleted). The diff holds only this change's work: `Gemfile`, `Gemfile.lock`, `app/views/appkit/sessions/new.html.erb`, `test/controllers/navigation_test.rb`, `test/views/appkit_shadows_test.rb`, and the change folder. No `update-dependencies` commit is re-applied. `main` changed no `Dockerfile` or `.ruby-version` since `7c47b13`, so the earlier Docker build evidence still covers the image's Ruby.

Pins via `git ls-remote`: appkit `d82b9c7`, mvpa-css `2be440b`, rubocop-eirvandelden `6d41c35` and exception_notification-campfire-once `2452ef9` are each repo's `main` HEAD, and `Gemfile.lock` revisions match. Round 7's two Important findings hold as fixed.

Ruby 4.0.7 (matches `.ruby-version` and `ARG RUBY_VERSION`): `bin/rails test` 292 runs, 0 failures; `bin/rubocop` 133 files, no offences; erb_lint, herb linter (`--fail-level hint`), i18n normalization, brakeman, bundler-audit and importmap audit clean. `bundle outdated` lists only marcel (held back by Rails). `npm outdated` is empty; `npm ls source-map-js` gives 1.2.2. Ruby 4.0.7 is still the newest 4.0.x; Node 24 (`v24.22.0`) is still the newest LTS, Node 26 is not LTS yet.

Bugs and security passes: nothing found. No existing test was weakened, skipped or deleted.

Compliance: as Round 7, with the appkit pin criterion now met and the npm forms of the outdated and `source-map-js` checks met. CI green on the pull request stays missing until `deliver` opens it.

No findings.
