# Review: update-dependencies

## Round 1 — 2026-10-13T13:51Z — 200cd83

No `REVIEW.md` or `REVIEW.local.md` exists at the repository root. This round uses the reviewer defaults: Bugs, Security, Compliance.

Checks run on 200cd83: `bin/rails test` (279 runs, 0 failures), `bin/rails test test/system/realtime_sticker_test.rb` (green), `bin/rubocop`, `bin/erb_lint --lint-all --allow-no-files`, `npx @herb-tools/linter`, `bin/check_i18n_normalized`, `bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit` — all green. `yarn outdated` is empty. `ruby -v` reports 4.0.7. `docker build` was not run: the Docker daemon is not running on this machine.

- [ ] Important: The `bundle outdated` acceptance criterion fails now. It lists json 3.0.2 → 3.1.0, net-imap 0.6.7 → 0.6.8, rubocop 1.91.0 → 1.92.0, selenium-webdriver 4.50.0 → 4.51.0 and mvpa-css 412cc74 → 77697d4. No other gem's constraint holds any of them back (json `>= 2.3`, every rubocop constraint allows `< 2.0`, selenium-webdriver and mvpa-css are unconstrained). These releases came after the full update on 2026-10-09. Only marcel is legitimately held back (by Rails). — `Gemfile.lock:222` → fixed (Update the gems released since the last full update)
- [ ] Important: The appkit pin `fd86991` is 38 commits behind appkit `main` (`4415186`, merged 2026-10-13). The intent puts "the newest commit on appkit `main`" in scope. appkit `main` changes `app/views/appkit/shared/_nav.html.erb` (`app_name.call` → `Appkit.config.app_display_name`) and `app/views/appkit/sessions/new.html.erb`. The app shadows both views with `Appkit.config.app_name.call`. A re-pin therefore means re-copying both shadows, or the "appkit `main`'s markup" promise in the intent no longer holds. — `Gemfile:8` → fixed (Pin appkit to d837929 and follow its app name lookup)
- [ ] Nit: herb 0.11.0 reports a new info-level offence: `.herb.yml` sets no `framework`, and herb suggests `framework: actionview` for this project. It is below the fail level, but plan step 5 says to fix every new offence herb 0.11 surfaces. — `.herb.yml:1` → fixed (Tell herb the templates are Action View)
- [ ] Nit: Two new single-page tests skip the `assert_response :success` that their sibling tests carry. A redirect then fails on a missing nav, with a less clear message. — `test/controllers/navigation_test.rb:61`, `test/controllers/navigation_test.rb:92` → fixed (Assert a successful response in the new nav tests)

### Bugs

Nothing beyond the findings above. The shadow partial matches appkit `fd86991`'s markup except for the Home line, as the plan says. `nav_section_tab` marks `/parent/children` and its nested paths, and does not match a sibling prefix such as `/children_x` or `/child_x`. No appkit view renders `appkit/shared/nav` itself, so the shadow's `home_path` local is always supplied. The removed `navigation.*` and `common.logout` keys have no remaining callers.

### Security

Nothing found. Brakeman, bundler-audit and importmap audit are clean. The logout `button_to` keeps `method: :delete` and the CSRF token. Dropping rexml from the lockfile follows from the selenium-webdriver bump; nothing in the app requires it.

### Compliance

| Acceptance criterion | Proof | Status |
| --- | --- | --- |
| `bundle outdated` lists only constraint-held gems | `bundle outdated` | fails now — see the first Important finding |
| `yarn outdated` lists nothing | `yarn outdated` | met |
| `ruby -v` reports 4.0.7, Dockerfile builds `ruby:4.0.7-slim` | `ruby -v`; `Dockerfile:11` | `ruby -v` met; `ARG RUBY_VERSION=4.0.7` set; Docker build not verified in this round |
| Parent clicks Home, lands on the children list | `navigation_test.rb` "parent sees a Home link as the first nav item leading to the children list" | met |
| Parent on the children list sees Home marked | "Home is marked as the current page on the children list" | met |
| Parent on a child's page, edit page or history sees Home marked | "Home stays marked on a child's page, edit page and history" | met |
| Parent on settings, admin or preferences sees Home not marked | "Home is not marked on settings, the admin overview or preferences" | met |
| Child clicks Home, lands on the dashboard, Home marked | "child sees a Home link as the first nav item leading to the dashboard", "child sees Home marked as the current page on the dashboard" | met |
| Dutch nav shows "Home", "Voorkeuren", "Uitloggen" | "the Dutch nav shows appkit's wording" | met |
| Parent awards a sticker, child sees it | `test/system/realtime_sticker_test.rb` "child dashboard updates live when a parent gives a sticker" | met |
| Tests, system tests, linters and scans green | Verification commands | met for every command run in this round |

Every test named in `plan.md`'s `## Proof` exists. No existing test was weakened, skipped or deleted: the three changed Home tests only swap `navigation.home` for `appkit.navigation.home`.

## Round 2 — 2026-10-16T18:12Z — 168aeda

No `REVIEW.md` or `REVIEW.local.md` exists at the repository root. This round uses the reviewer defaults: Bugs, Security, Compliance. It covers the full branch against `origin/main` (`30bfec0`), with weight on the six commits since round 1. The uncommitted `db/schema.rb` column reorder comes from local test runs and is not part of this branch; the coordinator keeps it out of every commit.

Checks run on 168aeda under Ruby 4.0.7: `bin/rails test` (284 runs, 0 failures), `bin/rubocop`, `bin/erb_lint --lint-all --allow-no-files`, `npx @herb-tools/linter`, `bin/check_i18n_normalized`, `bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit` — all green. `bundle outdated` lists only marcel 1.2.1 → 2.1.0, held back by Rails. `yarn outdated` is empty. `docker build` succeeds, and the image reports `ruby 4.0.7`. The coordinator reports `bin/rails test:system` (13 runs) green on 168aeda; this round did not re-run it.

No findings.

### Bugs

Nothing found. The appkit pin `d837929` is appkit `main` HEAD, and mvpa-css `77697d4` is mvpa.css `main` HEAD. The nav shadow matches appkit `d837929`'s partial except for the Home line, as the plan says. The `sessions/new` shadow follows appkit's `app_display_name` change. `app_display_name` resolves to the configured `I18n.t("app.title")`, because the app has no top-level `app_name` locale key; two new tests pin the nav and login headings to it. The collection render of `child/dashboard/sticker_notification` keeps the `sticker` local that `Sticker`'s broadcast also passes, and two new tests cover order and the empty first visit. `render "admin/users/form"` names the same partial as before.

Pre-existing, outside this branch: the app's `sessions/new` shadow lacks the `turbo_page_requires_reload` call that appkit's own view carries since before `fd86991`. Propose it as a separate change if wanted.

### Security

Nothing found. appkit `d837929`'s PWA controller now inherits the host `ApplicationController` (appkit CHANGELOG, Upgrading step 3). The app's `ApplicationController` includes `Appkit::Authentication` (step 4), and no `before_action` there redirects or blocks `GET /manifest` or `GET /service-worker`: `set_locale` only reads `Current.user`, and `allow_browser` blocks only the old browsers it blocks everywhere else. `test/integration/pwa_test.rb` now proves both endpoints serve without a session. Both endpoints send `Cache-Control: max-age=0, private, must-revalidate`. CI calls `rails-ci.yml` from `pull_request` and `push`, not `pull_request_target` (step 2). The app is on Rails 8.1 (step 1).

### Compliance

| Acceptance criterion | Proof | Status |
| --- | --- | --- |
| `bundle outdated` lists only constraint-held gems | `bundle outdated` | met — only marcel, held back by Rails |
| `yarn outdated` lists nothing | `yarn outdated` | met |
| `ruby -v` reports 4.0.7, Dockerfile builds `ruby:4.0.7-slim` | `ruby -v`; `docker build`; `docker run --rm --entrypoint ruby … -v` | met |
| Parent clicks Home, lands on the children list | `navigation_test.rb` "parent sees a Home link as the first nav item leading to the children list" | met |
| Parent on the children list sees Home marked | "Home is marked as the current page on the children list" | met |
| Parent on a child's page, edit page or history sees Home marked | "Home stays marked on a child's page, edit page and history" | met |
| Parent on settings, admin or preferences sees Home not marked | "Home is not marked on settings, the admin overview or preferences" | met |
| Child clicks Home, lands on the dashboard, Home marked | "child sees a Home link as the first nav item leading to the dashboard", "child sees Home marked as the current page on the dashboard" | met |
| Dutch nav shows "Home", "Voorkeuren", "Uitloggen" | "the Dutch nav shows appkit's wording" | met |
| Parent awards a sticker, child sees it | `test/system/realtime_sticker_test.rb` "child dashboard updates live when a parent gives a sticker" | met per the coordinator's system test run on 168aeda |
| Tests, system tests, linters and scans green | Verification commands | met |

Every round 1 finding is closed by a commit with the named subject. No existing test was weakened, skipped or deleted. The commits since round 1 each carry one change.
