# Plan: Update appkit and mvpa.css to their latest versions

From `intent.md` (2026-10-20). Status: accepted.

## Context

The app pins appkit at `e7abc8c` (2026-08-19) and resolves mvpa.css at `4c9c4ae` (2026-09-21). The latest commits on 2026-10-20 are appkit `d82b9c7601410e4daa42927cacaf646377090825` and mvpa.css `2be440b1225bb15870a2ec86ced19c4ecc7f7085`.

`e7abc8c` sits on the appkit side branch `ai/review-workspace-changes`. It is not an ancestor of appkit `main`. The tree diff from `e7abc8c` to `d82b9c7` is therefore the full change set, and it includes appkit `839e8cb` ("drop the home_path local, nav links straight to root") and `02fa603` ("namespace nav translations under appkit").

The appkit CHANGELOG "Upgrading" note has four items. The mvpa.css CHANGELOG has two "Upgrading" notes since `4c9c4ae`: 2026-10-13 (button hierarchy, action rows, dialogs) and 2026-10-19 (pull-down menu, stacking tables, `main` as a size container, flashes outside `main`, title bar as a wrapping row).

## Design decisions

- **okcomputer moves too.** appkit `9391c4b` (2026-10-07) sets `okcomputer ~> 1.20`. The lock holds `okcomputer 1.19.2`. A trial `bundle lock --update appkit mvpa-css --conservative` in a scratch copy changes exactly appkit, mvpa-css and okcomputer (1.19.2 to 1.20.0). No appkit commit on `main` after 2026-10-07 resolves without it. This contradicts the acceptance criterion "no other gem changes". The plan takes the okcomputer bump as a forced transitive change, not a new gem, and flags it for Etienne (see `## Open decision`).
- **mvpa-css gets a `ref:` in the Gemfile.** The acceptance criterion says the Gemfile names the latest mvpa-css commit. Today the Gemfile line has no `ref:`. The mvpa.css CHANGELOG also tells hosts to pin a SHA. The line becomes `gem "mvpa-css", github: "eirvandelden/mvpa.css", ref: "2be440b1225bb15870a2ec86ced19c4ecc7f7085"`. No gem is added or removed.
- **Use the SHAs above.** If `git ls-remote` shows a newer `HEAD` for either gem at implementation time, take it only when its CHANGELOG adds no new "Upgrading" item. Otherwise stay on the SHAs above and report the newer commit.
- **Keep the app's own Home link (override the appkit nav partial).** appkit `main` renders Home as `link_to t("appkit.navigation.home"), root_path` and ignores the `home_path` local. Here `root_path` is the sign-in page, so Home would point at `/` and lose `aria-current`, and the logout label would lose "🐿️". That breaks `test/controllers/navigation_test.rb` and `admin_flow_test.rb` "admin layout nav has no stale link back to the sign-in page". The intent requires that the app keeps all current behaviour. So the app adds `app/views/appkit/shared/_nav.html.erb`. It takes appkit's current partial and puts back the `home_path` local and the app's keys `navigation.home`, `navigation.preferences` and `common.logout`. The app already overrides `appkit/sessions/new` and `appkit/preferences/edit` the same way. Rejected: adopt `root_path` and rewrite the tests. That changes behaviour that the intent keeps.
- **Confirm with a Stimulus `dialog` controller, not Invoker Commands.** The mvpa.css demo opens a dialog with `command="show-modal" commandfor=…`. `allow_browser versions: :modern` admits Safari 17.2+, Chrome 120+ and Firefox 121+. Invoker Commands need Safari 26.2+, Chrome 135+ and Firefox 144+. A parent on an older admitted browser could not delete a user. A 5-line `dialog_controller.js` calls `showModal()`, and the app already uses Stimulus. This adds no dependency.
- **Only the admin user delete gets a dialog.** It is the only place with a confirm (`data: { turbo_confirm: … }`). "Turn off" on an allowance has no confirm today. It stays a direct `DELETE` `button_to` with `class: "button-danger"`, so it stays red.
- **Form footers.** Every app-owned form wraps its submit (and its Cancel, if any) in a `<footer>` that is the last child of the form. The order is Cancel, then Save. A Cancel link gets `role: "button", class: "button-secondary"` so it shows as a plain button, as mvpa.css's `Cancel` does.
- **Preferences gets an action row; sign-in does not.** `app/views/appkit/preferences/edit.html.erb` is an app-owned form under `app/views`, so its submit moves into a `<footer>` like every other form. Its `data: { turbo: false }` stays. `app/views/appkit/sessions/new.html.erb` keeps its bare submit: it renders in appkit's login layout, and `appkit/login.css` sizes `body[data-appkit-login] article button` for a single full-row button.
- **Override the login layout to move its flashes.** appkit's `layouts/login.html.erb` renders `appkit/shared/flashes` inside `<main>`. mvpa.css 2026-10-19 item 9 says flashes must be a direct child of `<body>`, or they scroll with the content on Safari before 18.4. The app adds `app/views/layouts/login.html.erb`: appkit `d82b9c7`'s layout with the flashes render moved above `<main>`. Fixing appkit itself is a follow-up for appkit; once appkit ships it, the override can go.
- **The 2026-10-19 mvpa items.** Flashes already render as a direct child of `<body>` in the parent and child layouts; the login layout is handled above. The title-bar rules target `main > header nav`. Every app page wraps its `<header>` in a `<div>` or `<section>`, so those rules (and the header-link change of 2026-10-13) do not reach any app page; restructuring the page shells would be new layout work, not an upgrade step. The app CSS has no `flex-direction`/`flex-wrap` rule for `main > header nav` and no `overflow-x` table wrapper. Confetti appends to `document.body`, so `main` as a size container does not trap it. The pull-down menu and stacking tables are opt-in features. The intent excludes new features, so neither is adopted. The two admin tables get a visual check at phone width only.
- **Regenerate `db/schema.rb` from the migrations.** The committed file lists columns alphabetically. A scratch database built by `db:create db:migrate` dumps them in migration order. The two files differ only in line order (checked with `diff <(sort …) <(sort …)`). A second `db:schema:dump` against that database changes nothing. Every later `db:migrate` on a developer database dumps the same order, so the noise stops. Do not use `db:schema:load` for this: the consent guard refuses it (playbook rule 9).

## Integration points

- appkit engine (`eirvandelden/appkit`): `Appkit::PwaController` now inherits `::ApplicationController`, so `allow_browser versions: :modern`, `set_locale`, `Appkit::Authentication`, `VersionHeaders` and `resolve_layout` all run on `GET /manifest` and `GET /service-worker`. None of them redirects a supported browser there. `allow_browser` answers 406 to a browser below the modern floor, as it already does on every other page; a browser that cannot run the app has no use for its manifest, and appkit's note names this inheritance as intended. The plan keeps that policy. `allow_unauthenticated_access` skips authentication, and `render … layout: false` skips `resolve_layout`. The manifest name now resolves through `Appkit.config.app_display_name`. The app has no top-level `app_name` key, so the configured lambda `-> { I18n.t("app.title") }` wins.
- appkit upgrading items 2 and 4 need no change. `.github/workflows` calls `rails-ci.yml` from `pull_request`. `ApplicationController` already includes `Appkit::Authentication`.
- mvpa.css: the app imports the bundled `mvpa/mvpa.css` in `app/assets/stylesheets/application.css`. That bundle already contains `12_dialog.css`, so no stylesheet link changes.
- Turbo: a `<form method="dialog">` must close the dialog, not submit through Turbo. The `DELETE` `button_to` inside the dialog submits through Turbo and redirects to the user list.

## Files that change

- `Gemfile`: appkit `ref:` to `d82b9c7…`; add `ref: "2be440b…"` to the mvpa-css line.
- `Gemfile.lock`: appkit, mvpa-css and okcomputer only. Run `bundle lock --update appkit mvpa-css --conservative`, then `bi`.
- `db/schema.rb`: regenerated from migrations; column order only.
- `app/views/appkit/shared/_nav.html.erb` (new): app override of appkit's nav partial with the `home_path` local and the app's translation keys.
- `app/views/layouts/parent.html.erb`: update the comment above the nav render, because the app now owns the Home link. The push `<button type="button">` stays as it is; mvpa.css now renders it plain.
- `app/views/layouts/login.html.erb` (new): app override of appkit's login layout with `render "appkit/shared/flashes"` moved out of `<main>` to a direct child of `<body>`, just before `<main>`.
- `app/views/appkit/preferences/edit.html.erb`: wrap `form.submit` in a `<footer>`, last child of the form.
- `app/views/admin/users/index.html.erb`: replace `button_to … turbo_confirm` with a `Delete…` opener (`type="button"`, `class="button-danger"`, `data-action="dialog#open"`) and a `<dialog>`. The dialog holds a heading with the existing `.confirm_delete` text and a `<footer>`. The footer holds `<form method="dialog"><button>Cancel</button></form>` and then `button_to t(".delete"), admin_user_path(user), method: :delete`. Wrap the opener and the dialog in one element with `data-controller="dialog"`, and give the `<dialog>` `data-dialog-target="dialog"`. Keep `unless user == Current.user` around that wrapper. Label the dialog with `aria-labelledby` on a `dom_id(user, :confirm_delete)` heading id.
- `app/javascript/controllers/dialog_controller.js` (new): `static targets = [ "dialog" ]`; `open()` calls `this.dialogTarget.showModal()`. `eagerLoadControllersFrom` registers it.
- `app/views/layouts/login.html.erb`: `test/integration/flash_test.rb` `test "sign-in page renders flashes outside main"` asserting `body > section[data-mvpa-flashes]` and no `main section[data-mvpa-flashes]` after a failed sign-in.
- `app/views/appkit/preferences/edit.html.erb`: `test/integration/preferences_test.rb` `test "preferences form ends in an action row"`.
- `app/views/admin/users/_form.html.erb`: `<nav>` becomes `<footer>`, order Cancel link (`role: "button", class: "button-secondary"`), then submit.
- `app/views/users/profiles/edit.html.erb`: the same change.
- `app/views/parent/children/edit.html.erb`: the four `<nav>` submit wrappers inside forms (name, avatar, profile, allowance update, allowance create) become `<footer>`, last child of their form. The page-level back `<nav>` at the end stays a `<nav>`.
- `app/views/parent/children/_child_card.html.erb`: wrap the goal form's submit in a `<footer>`.
- `config/locales/en.yml`, `nl.yml`, `it.yml`: add `admin.users.index.delete_ellipsis` (en "Delete…", nl "Verwijderen…", it "Elimina…") and `admin.users.index.cancel` (en "Cancel", nl "Annuleren", it "Annulla"). Match the wording of the existing `delete` key in each file. Then run `bundle exec i18n-tasks normalize`.
- Tests listed under `## Proof`.

## Order of work

1. Write the acceptance tests for the admin user delete: the integration test in `test/integration/admin/users_test.rb` and the system test `test/system/admin_user_deletion_test.rb`. Run them and watch them fail (no `<dialog>`, no `Delete…` opener).
2. Write the PWA tests in `test/integration/pwa_test.rb` (see `## Proof`). Run them against the old gem and watch the `Cache-Control` and revision assertions fail (appkit `e7abc8c` sends `no-cache` and names `Appkit::VERSION`).
3. Bump the gems. Edit the two `Gemfile` lines. Run `bundle lock --update appkit mvpa-css --conservative`, then `bi`. Run `git diff Gemfile.lock` and confirm only appkit, mvpa-css and okcomputer move. If anything else moves, stop and report.
4. Run `bin/rails test`. Expect `navigation_test.rb` and `admin_flow_test.rb` "no stale link" to fail on the new appkit nav. Add `app/views/appkit/shared/_nav.html.erb`. Update the comment in `parent.html.erb`. Run those tests and step 2's tests green.
5. Write the login-layout flash test (see `## Proof`), watch it fail, add `app/views/layouts/login.html.erb`, run it green.
6. Add `dialog_controller.js`, the locale keys and the dialog markup in `admin/users/index.html.erb`. Run step 1's tests green.
7. Write the action-row tests (one per page, see `## Proof`). Watch them fail. Convert the form footers in `_form`, `profiles/edit`, `children/edit`, `_child_card` and `appkit/preferences/edit`. Run them green.
8. Write the parent dashboard and allowance tests (see `## Proof`). They describe behaviour that must hold, so they may pass at once. Run them.
9. Regenerate `db/schema.rb`. Run `DATABASE_URL=sqlite3:<scratch>/schema.sqlite3 bin/rails db:create db:migrate`, which dumps into `db/schema.rb`. Copy it: `cp db/schema.rb <scratch>/first_dump.rb`. Then run `DATABASE_URL=sqlite3:<scratch>/schema.sqlite3 bin/rails db:schema:dump` and `cmp db/schema.rb <scratch>/first_dump.rb`. Confirm with `diff <(git show origin/main:db/schema.rb | sort) <(sort db/schema.rb)` that only order changed. Commit it alone.
10. Run the full checks: `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bin/importmap audit`, `bin/erb_lint --lint-all --allow-no-files`, `npx @herb-tools/linter`, `bundle exec ruby ./bin/check_i18n_normalized`, `bundle exec bundle-audit check --update`.
11. Check by eye with `bin/dev` at 1400px and at 375px width. Signed out: sign-in page with a failed sign-in (flash at the viewport corner). As admin: user list (table width under `main` as a container, `Delete…` red, dialog centred, Cancel filled, Delete red), user edit (action row). As parent: dashboard ("Give sticker" green, "Give penalty" red, push button plain), child edit (action rows, "Turn off" red). As child: dashboard. Record what was seen in the change folder's review evidence.

Each step is its own commit: PWA tests with gem bump; nav override; login layout; dialog; action rows; dashboard/allowance tests; schema.

## Risks

- **okcomputer 1.20.0** is a dependency change beyond the two named gems. It backs `/up`-style health checks only if the app mounts it; the app uses `rails/health#show`. Low runtime risk, but it breaks the letter of an acceptance criterion.
- **Turbo and `method="dialog"`.** If Turbo intercepts the Cancel form, Cancel would make a request instead of closing the dialog. The system test clicks Cancel and asserts the dialog closes with no navigation.
- **Upstream nav drift.** The override freezes appkit's nav partial in the app. A later appkit nav change will not reach this app until someone updates the override. Rejected alternative: change appkit to accept `home_path` again. That is an appkit change, out of scope here; it is a follow-up for appkit.
- **Logout button colour.** The logout `button_to` in the sidebar is a `DELETE` form, so mvpa.css keeps it red, as before. Step 10 checks it.
- **Buttons are 2px larger** (new 1px border). `child_cards.css` sets `min-height: 2.75rem` on all buttons; step 10 checks the dashboard footer row.
- **Schema regeneration.** It changes line order only. `bin/rails test` reloads the test database from the new file. Rejected: sort the dump by hand. The intent forbids hand edits.
- **SHAs move.** A newer gem commit with new upgrading notes would widen the scope; the plan stops and reports in that case.

## Out of scope

- Pull-down menus and stacking tables (opt-in mvpa.css features).
- A confirm dialog for "Turn off" on an allowance, or moving "Turn off" into the allowance form's action row.
- A footer on the sign-in form.
- Restructuring page shells so headers sit directly under `main`.
- Changing appkit itself (the `home_path` nav local, flashes in its login layout).
- Any other gem, the allowance and `Transfer` work, migrations, deploy files and `.github/workflows/`.
- Removing the app's redundant `min-height: 2.75rem` button rule in `child_cards.css`.

## Proof

- `db/schema.rb` equals a fresh dump, and a second dump changes nothing → check: step 9 commands; `cmp db/schema.rb <scratch>/first_dump.rb` exits 0 after the second `db:schema:dump`.
- The Gemfile and lock name the latest appkit and mvpa-css commits, and no other gem changes → check: `git diff origin/main -- Gemfile Gemfile.lock` shows only appkit, mvpa-css (both SHAs) and okcomputer (pending the open decision).
- A parent sees the push-enable button as a plain button and "Give sticker" and "Give penalty" as before → `test/integration/parent_ui_test.rb` `test "parent dashboard shows a plain push button and the green sticker and red penalty buttons"`.
- Deleting a user still works and keeps a red delete button → `test/system/admin_user_deletion_test.rb` `test "admin deletes a user through the confirmation dialog"` and `test "cancel closes the confirmation dialog and keeps the user"`; `test/integration/admin/users_test.rb` `test "user list offers a red Delete… opener and a dialog with a DELETE form"`.
- Turning off an allowance still works and keeps a red delete button → `test/integration/parent/allowance_form_test.rb` `test "turn off is a red DELETE button that removes the allowance"`.
- The manifest and service worker still load for a signed-in and a signed-out visitor → `test/integration/pwa_test.rb` `test "manifest and service worker load for a signed-out visitor"` and `test "manifest and service worker load for a signed-in parent and child"`.
- A child watching a card still sees a new sticker appear in real time → `test/system/realtime_sticker_test.rb` `test "child dashboard updates live when a parent gives a sticker"` (existing, unchanged).
- All checks pass → check: the step 10 command list, each exiting 0.

Behaviour kept from before the bump (regression guards, existing tests, unchanged):
- `test/controllers/navigation_test.rb`: all Home-link tests.
- `test/integration/admin_flow_test.rb`: `test "admin layout nav has no stale link back to the sign-in page"`.
- `test/integration/admin/users_test.rb`: `test "admin cannot delete themselves"`.

Per changed file, the tests expected:
- `app/views/admin/users/index.html.erb`: the opener and the dialog share one `[data-controller=dialog]` element; the dialog is `dialog[data-dialog-target=dialog]`; the opener is `button[type=button].button-danger[data-action="dialog#open"]`; the dialog footer holds a `form[method=dialog]` and then a form with `input[name=_method][value=delete]`; no opener or dialog in the current admin's own row; no `data-turbo-confirm` left.
- `app/javascript/controllers/dialog_controller.js`: no JS unit-test runner exists in the app; the system tests above prove `open()`.
- `app/views/appkit/shared/_nav.html.erb`: covered by the navigation regression guards; plus `test/controllers/navigation_test.rb` `test "logout keeps the app's own label"` asserting `I18n.t("common.logout")`.
- `app/views/layouts/login.html.erb`: `test/integration/flash_test.rb` `test "sign-in page renders flashes outside main"` asserting `body > section[data-mvpa-flashes]` and no `main section[data-mvpa-flashes]` after a failed sign-in.
- `app/views/appkit/preferences/edit.html.erb`: `test/integration/preferences_test.rb` `test "preferences form ends in an action row"`.
- `app/views/admin/users/_form.html.erb`: `test/integration/admin/users_test.rb` `test "user form ends in an action row with Cancel before Save"` (new and edit pages).
- `app/views/users/profiles/edit.html.erb`: `test/integration/users/profiles_avatar_test.rb` `test "profile form ends in an action row with Cancel before Save"`.
- `app/views/parent/children/edit.html.erb`: `test/integration/parent/child_profiles_test.rb` `test "every settings form ends in an action row"` asserting `form > footer:last-child` holds the submit, for each form on the page.
- `app/views/parent/children/_child_card.html.erb`: `test/integration/parent/sticker_card_goals_test.rb` `test "goal form ends in an action row"`.
- `test/integration/pwa_test.rb` also asserts `Cache-Control` contains `max-age=0`, `private` and `must-revalidate` on both endpoints, and that the service worker body contains `appkit-#{Appkit.revision}`.

Test setup: existing fixtures `users(:admin)`, `users(:parent)`, `users(:user)` (the child user of `child_profiles(:one)`), `child_profiles(:one)`, and the allowance fixtures. Integration tests sign in with `sign_in_as` from `test/test_helper.rb`. The admin system test signs in through the sign-in form, as `test/system/realtime_sticker_test.rb`'s `sign_in_parent` does, with headless Chrome from `ApplicationSystemTestCase`. No boundary is faked.

## Open decision

- okcomputer 1.19.2 to 1.20.0 is forced by appkit `d82b9c7`. Accept it as a transitive change, or keep appkit below `9391c4b` (not the latest).

---
Domain skills applied: rails-ui, rails-testing, dependencies, rails-architecture, hwc-stimulus-fundamentals.

## Critique

### Round 1 (codex exec -p terra)

- The plan accepts an unresolved okcomputer update that contradicts the intent's constraint and acceptance criterion 2 → dismissed: the intent is Etienne's to amend, not the plan's; the plan records the forced change and raises it as an open decision for the coordinator.
- The dialog markup never adds `data-controller="dialog"` or `data-dialog-target="dialog"`, so the controller never connects → fixed (Files that change and Proof now put both on a shared wrapper and the dialog)
- The signed-out login layout renders flashes inside `<main>`, against mvpa.css 2026-10-19 item 9 → fixed (new `app/views/layouts/login.html.erb` override, step 5 and a flash test)
- The preferences override is an app-owned form whose submit sits outside a footer → fixed (preferences submit moves into a `<footer>`; sign-in stays bare for `appkit/login.css`)
- The PWA tests come after the gem bump, so they never run red → fixed (PWA tests are now step 2, before the bump)
- `git diff --exit-code db/schema.rb` compares against Git, not the first dump → fixed (step 9 copies the first dump and compares with `cmp`)
- The title-bar claim misses that `main > header nav` never matches app pages, whose headers sit inside a `div` or `section` → fixed (Design decisions now state the selector does not reach app pages and restructuring is out of scope)
- `allow_browser versions: :modern` now runs on the PWA endpoints → dismissed: the whole app already refuses browsers below the modern floor, a browser that cannot run the app has no use for its manifest, and appkit's note names this inheritance as intended; the plan now says so.
