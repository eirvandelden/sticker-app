# Plan: Finish updating dependencies to their latest versions

From `intent.md` (2026-10-17). Status: accepted.

## Context

This branch, `update-dependencies-followup`, stacks on `update-dependencies`. The plan was written on 2026-10-17 against this state, which the executor re-checks before step 1:

- The branch is already rebased onto `update-dependencies` (`7c47b13`), and `origin/update-dependencies` is pushed at that same commit. Before any code change, run `git fetch origin` and confirm `git merge-base --is-ancestor origin/update-dependencies HEAD`. If `update-dependencies` moved, rebase onto it first (rule 20, `sync` skill).
- `.herb.yml` already has `framework: actionview` (commit `38fde8e` on `update-dependencies`). Nothing left to do for that scope item.
- appkit is pinned at `d837929`. appkit `main` is at `e47907f`. The 7 commits between them only add `.github/dependabot.yml`, `test/dependabot_config_test.rb` and an `AGENTS.md` note. No appkit view, helper, layout or Ruby code changed.
- `bundle outdated` lists `marcel` (held back by Rails) and `mvpa-css` (`77697d4` → `c17bfe8`). The mvpa-css commits change only its `AGENTS.md`, lockfiles and a test, no CSS. `rubocop-eirvandelden` and `exception_notification-campfire-once` are at their `main`.
- `yarn outdated` lists nothing. `@herb-tools/linter` and the `herb` gem are both `0.11.0`.
- `source-map-js` in `yarn.lock` is `1.2.2` on this branch. GitHub Dependabot alert #2 on `main` (high, `>= 1.0.0 < 1.2.2`) is about `main`'s lockfile; it closes once this stack merges. It is transitive, so `yarn outdated` does not show it, and it needs its own check.
- Ruby `4.0.7` is the newest 4.0.x release, and `ruby:4.0.7-slim` exists on Docker Hub. `.ruby-version` and the Dockerfile `ARG RUBY_VERSION` both say `4.0.7`.
- The newest Node LTS is 24 (`v24.22.0`, Krypton). Node 26 is still "Current", not LTS. CI already uses `node-version: 24`.
- herb lint reports 0 offences at every level today.
- The shadowed nav differs from appkit `main`'s only by its leading ERB comment and the Home line. The shadowed login view differs from appkit `main`'s by one line: appkit starts with `<% turbo_page_requires_reload %>` and a blank line; the app's copy dropped it in `bb4d947` to keep the failed-login flash visible.
- appkit's login layout (`app/views/layouts/login.html.erb` in appkit) has no `yield :head`. `turbo_page_requires_reload` is `provide :head, tag.meta(name: "turbo-visit-control", content: "reload")`, so in that layout the directive renders nothing.

Several outcomes may therefore already hold when work starts. The plan still runs every update command, because releases can land between planning and implementation, and still proves every criterion.

## Design decisions

- **The login shadow takes appkit `main`'s file verbatim, directive included.** The intent asks for appkit `main`'s markup. The directive renders nothing under appkit's login layout, so the `bb4d947` reason no longer applies. The system test `login form rejects wrong password` guards the flash. If that system test turns red with the directive, first look for an app-side fix that keeps the directive. Dropping the directive again would break acceptance criterion 4, so if no such fix exists, stop and put a `Decision needed:` line in the implement report. Do not weaken the shadow test.
- **A new test pins each shadow to appkit's own file.** `test/views/appkit_shadows_test.rb` reads the view from `Appkit::Engine.root` and from `Rails.root`, strips ERB comment lines (`/\A\s*<%#/`) from both, and compares. The login view must be equal. The nav must differ by exactly one line on each side: appkit's `root_path` Home line, and the app's `nav_section_tab t("appkit.navigation.home"), home_path` line. This proves acceptance criterion 4 mechanically and catches drift at the next appkit re-pin.
- **`app/views/appkit/preferences/edit.html.erb` stays as it is.** The intent re-copies "any other shadowed appkit view that appkit `main` changed". appkit did not change that view between `d837929` and `e47907f`. Its differences from appkit (`data: { turbo: false }`, longer block variable names) are the app's own and pre-date this change. Re-check with `git diff d837929 <new pin> -- app/views/appkit/` in an appkit clone; re-copy only views that diff touches.
- **Gems update in one full `bundle update`, after the appkit ref changes.** The intent approves a full `bundle update`. Changing the ref first means one resolve picks up appkit and every other gem together.
- **npm updates through `yarn upgrade --latest`.** It moves `package.json` ranges and every `yarn.lock` entry, transitive ones included, to the newest release. Keep `@herb-tools/linter` on the same minor as the `herb` gem; if one moves a minor ahead of the other, raise the other to match. If no matching release exists for one of them, that is a `Decision needed:` line in the implement report, not a hold-back.
- **Ruby and Node versions change only if a newer one exists at implementation time.** Today neither does. If Ruby 4.0.8+ is released and `ruby:<v>-slim` exists, change `.ruby-version` and the Dockerfile `ARG RUBY_VERSION` together, and install it with `rv` (intent: approved under rules 8 and 13). If Node 26 has become LTS, change `node-version` in `.github/workflows/ci.yml` to 26. Node 26 LTS is expected around late October 2026, so check `https://nodejs.org/dist/index.json` on the day.
- **The parent half of the "Home is not marked" criterion gets its own test.** The existing test `Home is not marked on settings, the admin overview or preferences` signs in as an admin. The criterion names a parent. Add `Home is not marked on settings or preferences for a parent` to `test/controllers/navigation_test.rb`, signed in as `users(:parent)`, over `parent_settings_path` and `edit_preferences_path`. Keep the admin test as it is.
- **Proof for dependency state is a command, not a unit test.** "Nothing is outdated" is a property of the lockfiles against a moving registry; a committed test would fail whenever a new release lands. These criteria use `→ check:` lines.

## Integration points

- appkit engine (`eirvandelden/appkit`): Gemfile pin, shadowed views, and the shared CI workflow `rails-ci.yml@main`.
- gem.coop and the GitHub-sourced gems (mvpa-css, rubocop-eirvandelden, exception_notification-campfire-once).
- The npm registry through yarn 1.
- Docker Hub `ruby:<version>-slim` base image, for the local production build.
- GitHub Actions CI on this branch's pull request, which targets `update-dependencies`. `ci.yml` triggers on every `pull_request`, so a PR into `update-dependencies` runs it.

## Files that change

- `test/views/appkit_shadows_test.rb` — new. Pins the login and nav shadows to appkit's files.
- `test/controllers/navigation_test.rb` — one new test for a parent on settings and preferences. The two missing `assert_response :success` lines stay out of scope.
- `Gemfile` — appkit `ref:` to the newest appkit `main` commit.
- `Gemfile.lock` — full `bundle update` result.
- `app/views/appkit/sessions/new.html.erb` — re-copied from the new appkit pin.
- `app/views/appkit/shared/_nav.html.erb` — re-copied from the new appkit pin, then the app's comment and Home line re-applied. Expected to be byte-identical to today, since appkit did not change it.
- `package.json`, `yarn.lock` — only if `yarn upgrade --latest` changes anything.
- `.ruby-version`, `Dockerfile` (`ARG RUBY_VERSION`), `.github/workflows/ci.yml` (`node-version`) — only if a newer Ruby 4.0.x or Node LTS exists.
- Any app file a new lint offence, a new appkit behaviour or a changed gem forces. None are known today.

## Order of work

1. Confirm the stack (Context, first bullet). Then write `test/views/appkit_shadows_test.rb` and run `bin/rails test test/views/appkit_shadows_test.rb`. Watch the login test fail on the missing `turbo_page_requires_reload` line. The nav test may already pass; it is a guard. Do not commit the test on its own: it goes in with the view re-copy (step 4), so no commit has a red suite.
2. Look up appkit `main`: `git ls-remote https://github.com/eirvandelden/appkit.git refs/heads/main`. Set that full SHA as the Gemfile `ref:`.
3. Run `bundle update` (full, approved). Run `bundle outdated`; only gems held back by another gem's constraint may remain. For each remaining gem, name the gem that holds it back (`Gemfile.lock` dependents) in the commit message.
4. In a scratch clone of appkit, run `git diff d837929 <new pin> --stat -- app/views/appkit/` to list changed views. Copy `app/views/appkit/sessions/new.html.erb` from the new pin (`bundle show appkit`) over the app's copy. Re-copy `app/views/appkit/shared/_nav.html.erb`, then re-apply the app's leading comment and the `nav_section_tab ... home_path` line. Re-copy any other shadowed view the diff lists, keeping that view's app-specific lines.
5. Run `bin/rails test test/views/appkit_shadows_test.rb test/controllers/navigation_test.rb test/integration/auth_test.rb` (green), then `bin/rails test:system TEST=test/system/sessions_test.rb`. If `login form rejects wrong password` fails, follow the login decision in Design decisions.
6. Add `Home is not marked on settings or preferences for a parent` to `test/controllers/navigation_test.rb`. Run it; it is expected to pass at once, because the nav rule already holds. Confirm it can fail by temporarily pointing one `assert_select` at `aria-current` count 1, then revert that.
7. Run `bin/rails test` and `bin/rubocop`. Fix what the update breaks in app code. Commit in this order, each one green: appkit pin (Gemfile, appkit lines in `Gemfile.lock`) if it can be split cleanly, else together with the gem update; the other gems; the view re-copy with `appkit_shadows_test.rb`; the new navigation test.
8. Run `yarn upgrade --latest`, then `yarn outdated` (empty) and `yarn why source-map-js` (`1.2.2` or later). Check the herb gem and `@herb-tools/linter` share a minor. Run `npx @herb-tools/linter --fail-level hint`. Commit if anything changed.
9. Check Ruby (`https://www.ruby-lang.org/en/downloads/releases/`, Docker Hub `ruby` tags) and Node LTS (`https://nodejs.org/dist/index.json`). Apply a newer version only if one exists. Commit each version change on its own.
10. Run the full local check list: `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/erb_lint --lint-all --allow-no-files`, `npx @herb-tools/linter --fail-level hint`, `bundle exec ruby ./bin/check_i18n_normalized`, `bin/brakeman`, `bin/bundler-audit --config config/bundler-audit.yml --update`, `bin/importmap audit`. Fix each failure in app code.
11. Build the production image: `docker build -t sticker-app:update-dependencies-followup .`, then `docker run --rm sticker-app:update-dependencies-followup ruby -v`. It must print the `.ruby-version` version. No push, no deploy. Record the output for the review.
12. Push the branch. The `deliver` stage opens the pull request against `update-dependencies`; CI must then be green (`gh pr checks <pr>`).

## Risks

- **A gem or npm release lands between planning and implementation and breaks something.** Intent: fix the app, never hold the dependency back. The full check list in step 10 catches it.
- **The login directive breaks the failed-login flash again.** Guarded by the existing system test. An app-side fix comes first; otherwise it is a `Decision needed:` line, because dropping the directive breaks criterion 4.
- **`bundle update` moves Rails or another framework gem a minor version.** Gemfile constraints (`rails ~> 8.1`, `minitest ~> 6.0`) cap that; loosening a constraint is out of scope.
- **The Docker build fails for a reason unrelated to Ruby** (network, base image pull, `assets:precompile` with the dummy secret). Fix what the build needs in app code; any Dockerfile change beyond `ARG RUBY_VERSION` needs approval under rule 13 and becomes a `Decision needed:` line.
- **The local image builds for arm64 only.** The intent asks for a local build; a cross-platform build is not in scope.
- **CI uses `rails-ci.yml@main` from appkit**, which can change independently. A CI failure caused by that workflow and unrelated to this branch falls under rule 25.
- Rejected: deleting the login shadow now that it matches appkit. The intent says the app keeps its own shadowed views.
- Rejected: a committed test asserting `bundle outdated` or `yarn outdated` output. It would fail on every new upstream release.

## Out of scope

- Opening, reviewing or merging the `update-dependencies` pull request.
- The two missing `assert_response :success` lines in `test/controllers/navigation_test.rb`.
- A manual `bin/dev` check of nav, theme and mvpa-css styling.
- Any change in appkit, including copying appkit's new `.github/dependabot.yml` into this app.
- Loosening any Gemfile version constraint.
- Transitive gems held back by another gem's constraint (marcel 2.x).
- Open Dependabot pull requests.
- Any change to `preferences/edit.html.erb` unless appkit changed that view.
- Deploying, or pushing the image.

## Proof

- `bundle outdated` lists only gems held back by another gem's constraint → check: `bundle outdated` shows only `marcel` (or other gems each named with the gem that holds it back).
- `yarn outdated` lists nothing → check: `yarn outdated` prints no package table.
- Coordinator addition: `source-map-js` is at 1.2.2 or later (Dependabot alert #2) → check: `yarn why source-map-js` and `grep -A1 '^source-map-js@' yarn.lock` show `1.2.2` or later.
- The Gemfile pins appkit at the newest commit on appkit `main` → check: the Gemfile `ref:` equals `git ls-remote https://github.com/eirvandelden/appkit.git refs/heads/main`, and `Gemfile.lock` `revision:` for appkit matches.
- The nav and login page show appkit `main`'s markup and wording; the nav differs only by the Home target and current-page rule → `test/views/appkit_shadows_test.rb` `the login view carries appkit's markup`, `the nav differs from appkit's only in the Home link`; `test/controllers/navigation_test.rb` `the Dutch nav shows appkit's wording`, `the login page is headed with the app name`.
- A parent clicks Home and lands on the children list, with Home marked → `test/controllers/navigation_test.rb` `parent sees a Home link as the first nav item leading to the children list`, `Home is marked as the current page on the children list`.
- A parent on a child's page, edit page or history sees Home marked; on settings, admin or preferences it is not → `test/controllers/navigation_test.rb` `Home stays marked on a child's page, edit page and history`, `Home is not marked on settings or preferences for a parent` (new), `Home is not marked on settings, the admin overview or preferences` (admin overview).
- A child clicks Home and lands on their dashboard, with Home marked → `test/controllers/navigation_test.rb` `child sees a Home link as the first nav item leading to the dashboard`, `child sees Home marked as the current page on the dashboard`.
- A parent awards a sticker and the child sees it on their sticker card → `test/system/realtime_sticker_test.rb` `child dashboard updates live when a parent gives a sticker`; `test/integration/parent_flow_test.rb` `parent awards a positive sticker and count increases`.
- herb lint reports no offences, including info-level ones → check: `npx @herb-tools/linter --fail-level hint` exits 0 with `0 offenses`.
- `ruby -v` in the worktree reports `.ruby-version`, and the Dockerfile builds on that version → check: `ruby -v` matches `.ruby-version`; `grep 'ARG RUBY_VERSION' Dockerfile` matches it.
- The production image builds locally and `ruby -v` inside it reports that version → check: `docker build -t sticker-app:update-dependencies-followup .` succeeds; `docker run --rm sticker-app:update-dependencies-followup ruby -v` prints it.
- Tests, system tests and all linters and scanners are green → check: every command in Order of work step 10 exits 0.
- CI is green on this branch's pull request → check: `gh pr checks <pr>` all pass.

Per changed file, the unit tests expected:

- `test/views/appkit_shadows_test.rb`: `the login view carries appkit's markup`, `the nav differs from appkit's only in the Home link`.
- `test/controllers/navigation_test.rb`: `Home is not marked on settings or preferences for a parent`.
- `app/views/appkit/sessions/new.html.erb`, `app/views/appkit/shared/_nav.html.erb`: covered by the shadow test, `navigation_test.rb`, `auth_test.rb` and `test/system/sessions_test.rb` `login form rejects wrong password`.
- `Gemfile`, `Gemfile.lock`, `package.json`, `yarn.lock`, version files: no new unit tests; the full suite and the checks above.

Test setup: `ActiveSupport::TestCase`, no fixtures. Read files with `File.readlines(Appkit::Engine.root.join("app/views/appkit/..."), chomp: true)` and the same path under `Rails.root`. Drop lines matching `/\A\s*<%#/` before comparing. Existing fixtures (`users(:parent)`, `users(:user)`, `users(:admin)`, `users(:dutch_admin)`, `child_profiles(:one)`) cover the reused tests.

---
Domain skills applied: dependencies, rails-testing, rails-ui.

## Critique

### Round 1 (codex exec -p terra)

- Step 4 ran the full suite while the new shadow test stayed red until the view copy in step 5 → fixed (views are re-copied before the full suite runs; the shadow test is committed only with the views, so every commit is green)
- The login fallback could not pass the shadow test, because stripping ERB comments does not hide a missing directive, and it broke acceptance criterion 4 → fixed (fallback removed; an app-side fix comes first, else a `Decision needed:` line in the implement report)
- The proof for Home being unmarked on settings and preferences signed in as an admin, not a parent → fixed (new parent test `Home is not marked on settings or preferences for a parent`; the admin test stays for the admin overview)
