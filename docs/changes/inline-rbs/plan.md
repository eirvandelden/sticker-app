# Plan: Inline RBS instead of YARD (round 3: no tracked signature files)

From `intent.md` (2026-10-16, revised 2026-10-17). Status: accepted.

## Context

This is a personal Rails 8.1.4 app on Ruby 4.0.6, managed by `rv`. Branch `inline-rbs` (pull request #180) already delivers rounds 1 and 2 of the intent, up to commit `f27e40b`:

- `Steepfile` (`target :app`, `signature "sig"`, `check "app", "lib", inline: true`), `rbs_collection.yaml`, `rbs_collection.lock.yaml`, `/.gem_rbs_collection/` in `.gitignore`.
- An inline `# @rbs` signature, a one-line description on every method, and a one-line summary on every class and module in `app/` and `lib/`.
- `rbs_rails` 0.13.1 in `group :development`, and `lib/tasks/rbs.rake`, which defines `rbs_rails:all`, `rbs_rails:generate_rbs_for_models` and `rbs_rails:generate_rbs_for_path_helpers`.
- 17 tracked files under `sig/`: 11 generated model files in `sig/rbs_rails/app/models/`, and 6 hand-written gap stubs in `sig/stubs/` (`appkit`, `namespaces`, `rails`, `rbs_rails_overrides`, `routes`, `turbo_rails`).
- A `steep` job in `.github/workflows/ci.yml` that runs `steep check` on the tracked `sig/`.

On 2026-10-17 Etienne revised `intent.md`: no file under `sig/` is tracked, the model RBS is generated at check time by a rake task, and each hand-written gap stub is expressed inline, removed by another means, or reported. This plan covers only that change.

Facts measured on 2026-10-17, in throwaway copies under the session scratchpad (never in this worktree):

- RBS 4.2.0 inline syntax has no `# @rbs!` block. `docs/inline.md` of the gem lists `# @rbs` method types, `#:` on attributes and constants, `# @rbs @ivar:`, `# @rbs module-self:` and `# @rbs skip`, and nothing that declares a method without a `def` or that declares a foreign class.
- A fresh `git clone` of this branch, with `sig/rbs_rails/` untracked and deleted and no `config/master.key`, runs `bin/rails db:prepare rbs_rails:all` without error. It regenerates the 11 model files byte-identical to the tracked ones (`diff -r` prints nothing), plus `sig/rbs_rails/path_helpers.rbs`.
- The generated `path_helpers.rbs` declares `interface ::_RbsRailsPathHelpers` with every route helper, `qr_code_path` and `session_transfer_url` (Appkit engine routes) included, and includes it into `ActionController::Base` only, not `ActionView::Base`.
- Each stub was removed and `steep check` rerun. The gaps and the inline means that cleared them:

  | Gap (stub) | Errors without it | Inline means | Result |
  | --- | --- | --- | --- |
  | `routes.rbs` | 26 | Generated `path_helpers.rbs`, plus a second `# @rbs module-self: _RbsRailsPathHelpers` on `ApplicationHelper` | 0 errors |
  | `namespaces.rbs` (`Admin`, `Users`) | 4 | Nest the 4 compact `class Admin::X` / `class Users::X` controllers inside `module Admin` / `module Users`, as `module Parent` already is | 0 errors |
  | `rails.rbs`: `User::Role#administrator?` | 1 | `# @type self: User` as the first line of `User::Role#can_administer?` | 0 errors |
  | `rbs_rails_overrides.rbs`: `StickerCard#completed_at=` | 1 | `Time.zone.now` in place of `Time.current` in `StickerCard#mark_completion_time` | 0 errors |
  | `appkit.rbs` | 3 fatal `RBS::UnknownTypeName`, then call sites | None. `# @rbs skip` above an `include Appkit::X` line removes that include from the RBS, but `transfer_id`, `signed_in?` and `Appkit::QrCodeLink` stay undeclared | Gap |
  | `turbo_rails.rbs` | 5 | None | Gap |
  | `rails.rbs`: `Current.user`, `.user=`, `#user` | 19 | None: `attribute` makes them at runtime | Gap |
  | `rails.rbs`: `ApplicationCable::Connection#current_user=` | 1 | None: `identified_by` makes it at runtime | Gap |
  | `rails.rbs`: `Rails::Application::Configuration#git_revision`, `#app_version` | 2 | None: set in `config/initializers/version.rb` | Gap |
  | `rbs_rails_overrides.rbs`: `ActiveStorage::Attached::One#blob`, `User#attachment_changes` | 3 | None: the collection types them wrongly or not at all | Gap |

- With the four inline means applied, `routes.rbs` and `namespaces.rbs` deleted and the two blocks removed, the fresh clone ran `bin/rails db:prepare rbs_rails:all`, `bin/rbs collection install --frozen` and `steep check`, which printed `No type error detected.` In that copy `bin/rubocop` on the 7 changed files reported no offenses, and `bin/rails test test/integration/admin test/integration/users test/models` ran 115 tests, 0 failures.
- `RBS::Prototype::Runtime` (`rbs prototype runtime`) is deprecated in rbs 4.2 (it prints a warning naming ruby/rbs#2841) and wrote an empty file for the Appkit, Turbo and `Current` constants. It is no way to generate the remaining gaps.

## Design decisions

- **One generation command.** `bin/rbs collection install --frozen && bin/rails db:prepare rbs_rails:all` is the documented command line. The collection install is there because `.gem_rbs_collection/` is ignored, so a fresh clone has no library types without it. `rbs_rails:all` already exists through `lib/tasks/rbs.rake` and generates both the model RBS and the path helpers. `db:prepare` comes first because generation boots the app in development and needs a migrated `storage/development.sqlite3`; on a fresh clone that database does not exist. No wrapper task: two existing tasks on one command line need no new code.
- **Who calls it.** The intent names local runs, "the tests setup" and the CI `steep` job. Local: the `AGENTS.md` Commands block documents the command above `steep check`. Tests setup: `bin/setup`, which developers run before the test suite, gets a `== Generating type signatures ==` section with `bin/rbs collection install --frozen` and `bin/rails rbs_rails:all`, placed after the `--reset` line so that a reset database is the one it reads; `test/` is out of scope, so `test_helper.rb` does not. CI: the `steep` job already runs `bin/rbs collection install --frozen`, and gets `bin/rails db:prepare rbs_rails:all` before `steep check`.
- **`.gitignore`.** Add `/sig/` in the block under `/.gem_rbs_collection/`. `git rm -r --cached sig/rbs_rails` untracks the generated files and keeps them on disk.
- **Inline means for four gaps**, from the table in Context:
  - `ApplicationHelper` gets a second line, `# @rbs module-self: _RbsRailsPathHelpers`, under its existing `module-self: ActionView::Base`. At runtime every helper module is mixed into a view that has the route helpers, so the constraint is true. It refers to an interface that exists only after generation, which is fine: `steep check` without generation already fails on the missing model types.
  - `app/controllers/admin/{base,dashboard,users}_controller.rb` and `app/controllers/users/profiles_controller.rb` change from compact `class Admin::X` to nested `module Admin` / `class X`, matching the `module Parent` files. Each new `module` line gets the same summary in every file of its namespace: `# Groups the controllers that administrators use.` and `# Groups the controllers for a user's own profile.`. The class summary and the body move in by two spaces, unchanged otherwise. `class UsersController < Admin::BaseController` keeps its explicit superclass. Constant lookup gains the `Admin` and `Users` lexical scopes; neither namespace defines a constant that shadows a top-level one (`app/controllers/admin/` and `app/controllers/users/` hold only these four controllers).
  - `User::Role#can_administer?` gets `# @type self: User` as the first line of its body. It is a Steep annotation, the same kind the `included do` block of that file already uses.
  - `StickerCard#mark_completion_time` uses `Time.zone.now` in place of `Time.current`. `Time.current` is `Time.zone ? Time.zone.now : Time.now`, and Rails always sets `Time.zone` from `config.time_zone` (default UTC), so the value is the same. The collection types `Time.zone.now` as `ActiveSupport::TimeWithZone`, which the generated setter accepts.
- **The remaining gaps are a decision for Etienne.** Appkit, turbo-rails, `Current` attributes, `identified_by`, the two config keys and the two ActiveStorage methods have no inline RBS syntax. The intent says such a gap goes back to Etienne as one concrete question. This plan does all the work that does not depend on his answer, keeps the four remaining stub files tracked until he answers, and lists the steps for each answer under `## Blocked on Etienne's answer`. It does not pick an option.
- **`lib/tasks/rbs.rake` header.** The first line now says the tasks generate RBS for the models and the route helpers into `sig/rbs_rails`, because `rbs_rails:all` now also produces `path_helpers.rbs`. No code change in that file.
- **Comments in the nested controllers.** The existing summary and description lines stay word for word. The comment-block check from round 2 must still print `0 without summary` and `0 without description`.

## Integration points

- `rbs_rails` 0.13.1 (already in `group :development`): its rake tasks boot the app in development and read the schema of `storage/development.sqlite3`.
- The CI `steep` job: `spinel-coop/setup-rv` with `install-gems: true` installs every Gemfile group, so `rbs_rails` is present there. The job's first green run on the pull request proves it.
- Steep 2.1.0, global install locally and `gem install` in CI, unchanged.
- `eirvandelden/appkit`: unchanged here. Its engine routes reach the generated `path_helpers.rbs`.
- Rails routing: unchanged; nesting the controllers keeps the constant names `Admin::BaseController`, `Admin::DashboardController`, `Admin::UsersController` and `Users::ProfilesController`.

## Files that change

- `.gitignore`: `/sig/`.
- `sig/rbs_rails/app/models/**/*.rbs` (11 files): untracked, kept on disk.
- `sig/stubs/routes.rbs`, `sig/stubs/namespaces.rbs`: deleted.
- `sig/stubs/rails.rbs`: the `User::Role` block removed.
- `sig/stubs/rbs_rails_overrides.rbs`: the `StickerCard#completed_at=` block and its comment removed.
- `app/helpers/application_helper.rb`: the second `module-self` line.
- `app/controllers/admin/base_controller.rb`, `app/controllers/admin/dashboard_controller.rb`, `app/controllers/admin/users_controller.rb`, `app/controllers/users/profiles_controller.rb`: nested modules.
- `app/models/user/role.rb`: the `# @type self: User` line.
- `app/models/sticker_card.rb`: `Time.zone.now`.
- `lib/tasks/rbs.rake`: header comment.
- `bin/setup`: a generation section that installs the RBS collection and runs `rbs_rails:all`.
- `.github/workflows/ci.yml`: one step in the `steep` job (approved in `intent.md`).
- `AGENTS.md`: the generation line replaces the round 2 regeneration line: `bin/rbs collection install --frozen && bin/rails db:prepare rbs_rails:all  # generate sig/ (untracked); rerun after a migration or a route change`, placed directly above `steep check`. Edit `AGENTS.md`, never the `CLAUDE.md` symlink. Both are tracked although `.gitignore` lists them.

## Order of work

1. Walking skeleton: run the `sig/` tracking check from `## Proof` and watch it fail, printing the 17 tracked files.
2. Add `/sig/` to `.gitignore` and run `git rm -r --cached sig/rbs_rails`. Run `bin/rails rbs_rails:all`, then `steep check` (exit 0, since `routes.rbs` still declares the helpers; if Steep reports a duplicate between `_AppRoutes` and `_RbsRailsPathHelpers`, move step 3's first commit ahead of this step). Commit (`chore: stop tracking the generated model RBS`).
3. Inline the four gaps, one commit each, running `steep check` and the narrowest tests after each:
   - `ApplicationHelper` module-self, delete `sig/stubs/routes.rbs` (`chore: type route helpers from the generated path helpers`). Tests: `bin/rails test test/helpers test/integration/users`.
   - Nest the four controllers, delete `sig/stubs/namespaces.rbs` (`refactor: nest the Admin and Users controllers`). Tests: `bin/rails test test/integration/admin test/integration/users test/controllers`. Run `bin/rubocop` on the four files.
   - `# @type self: User` in `User::Role`, remove the block from `sig/stubs/rails.rbs` (`chore: type User::Role#can_administer? inline`). Tests: `bin/rails test test/models`.
   - `Time.zone.now` in `StickerCard`, remove the block from `sig/stubs/rbs_rails_overrides.rbs` (`chore: type the card completion time without an override`). Tests: `bin/rails test test/models/sticker_card_test.rb`.
4. Wire the generation: the `bin/setup` line, the CI step, the `lib/tasks/rbs.rake` header and the `AGENTS.md` line. Run `bin/setup --skip-server` once to prove the line works. Commit (`chore: generate the model RBS before steep check`).
5. Run the fresh-clone check from `## Proof`.
6. Full gate: every `## Proof` check except the `sig/` tracking check, then `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bundle exec bundle-audit check --update`, `bin/erb_lint --lint-all --allow-no-files`. Re-read the full diff against `f27e40b`: every hunk in `app/` is a comment line, the four nestings (indentation, `module`, `end` and the two summary lines), or the one `Time.zone.now` line. Push, and confirm the CI `steep` job passes on pull request #180.
7. Stop. Report that the four remaining stub files wait for Etienne's answer, with the `Decision needed:` line below. Do not start `## Blocked on Etienne's answer` without that answer.

## Blocked on Etienne's answer

Decision needed: RBS 4.2 has no inline syntax for the last gaps (Appkit modules and methods, turbo-rails broadcasts, `Current` attributes, `identified_by :current_user`, the `git_revision` and `app_version` config keys, `ActiveStorage::Attached::One#blob` and `User#attachment_changes`); which option do you want?

- **A. Keep the four stub files tracked as the one exception** (recommended): `.gitignore` gets `/sig/*` and `!/sig/stubs/`, and the acceptance criterion `git ls-files sig prints nothing` becomes "prints only `sig/stubs/`". About 60 lines stay tracked, each with a comment naming its gap. Type checking at every call site stays as it is today. Follow-ups outside this change can shrink it: Appkit types into the appkit gem's own `sig/`, turbo-rails and ActiveStorage into `ruby/gem_rbs_collection`.
- **B. Remove the files and mark the call sites inline.** `# @rbs skip` above the five `include Appkit::X` lines (verified to clear the unknown-type errors), then a Steep annotation or a `#: untyped` assertion at about 33 call sites (19 of them `Current.user`). The acceptance criterion holds as written. Those call sites lose type checking, and every new call site needs the same marker.
- **C. Move the Appkit types into the appkit gem first** (a separate pull request in `eirvandelden/appkit`, which `intent.md` puts out of scope), then A or B for the rest.

Steps after the answer: for A, edit `.gitignore` and the acceptance check, add one sentence to `AGENTS.md`, commit. For B, one commit per gap file, each deleting the file and adding the markers, `steep check` and the narrowest tests green after each. For C, wait for the appkit release, bump it with `bundle update appkit` (a dependency change that needs its own approval), delete `sig/stubs/appkit.rbs`, then A or B.

## Out of scope

- Any Gemfile change, Steep in the bundle, `rbs-inline`, an rbs_rails config file, a wrapper rake task.
- `# steep:ignore`, Steep diagnostic level changes, any RuboCop config edit.
- `test/`, `config/` (including `config/initializers/version.rb`), `db/`, views and the Appkit gem.
- Other refactors: the nil card in `Parent::StickersController#create` and `Parent::PenaltiesController#create` keeps its `# @type var card: untyped`; the `Transfer` stub, the unfinished allowance code, the shadowed `app/models/concerns/authorization.rb`.
- A CI check that generated RBS is fresh: generation now runs in CI, so it is always fresh there.

## Risks

- **CI cannot boot development.** The fresh clone without `config/master.key` generated the RBS locally, but CI may lack a native dependency or set `BUNDLE_WITHOUT`. Mitigation: the first CI run on the pull request is the proof; if it fails, read the log and fix the job step only.
- **Local `steep check` without generation fails.** A developer who skips `bin/setup` gets unknown-type errors. Mitigation: the `AGENTS.md` line sits directly above `steep check`, and `bin/setup` generates.
- **Stale local RBS after a migration or a route change.** `rbs_rails:all` generates both the model and the route-helper RBS, so the developer reruns the documented command after either; the `AGENTS.md` line says so. CI always regenerates.
- **Nesting changes constant lookup.** A bare constant inside `module Admin` resolves `Admin::X` before `::X`. Mitigation: no `Admin::` or `Users::` constant exists beyond the four controllers, and the integration tests for both namespaces run in step 3.
- **`Time.zone.now` versus `Time.current`.** They differ only when `Time.zone` is nil, which Rails never leaves it. Rejected alternative: keeping the override file block.
- **A module-self on a generated interface** ties `ApplicationHelper` to rbs_rails output. Rejected alternative: keeping `routes.rbs`, a hand-written list that already drifted once.
- Rejected: `rbs prototype runtime` at check time (deprecated, empty output); a homemade generator in the rake task that reflects on `Current` and Appkit (new code that needs its own tests, and its output is `untyped` anyway); hand-written stubs emitted by the rake task (a tracked stub in disguise); `.rb` files of fake class reopenings for Steep only (dead Ruby code, and a tracked stub in disguise).

## Proof

The change adds no runtime behaviour, so no new Minitest test exists. The type checker, the commands below and the existing suites are the proof.

- `git ls-files sig` prints nothing, and `sig/` is in `.gitignore` → check: `test -z "$(git ls-files sig)" && git check-ignore -q sig/rbs_rails/app/models/user.rbs && echo SIG-OK`. Fails in step 1 with 17 files, prints the 4 remaining stub files after step 6, and passes only after the blocked step (or, under option A, its revised form).
- On a fresh clone, one documented command generates the model RBS, and `steep check` then exits 0 → check: `d=$(mktemp -d) && git clone -q --branch inline-rbs "$PWD" "$d/app" && cd "$d/app" && bin/rbs collection install --frozen && bin/rails db:prepare rbs_rails:all && steep check && echo FRESH-OK`, run after step 4's commit.
- The CI `steep` job does the same → check: `gh pr checks 180` shows `steep` as pass, and `gh run view <run-id> --job <steep-job-id> --log` shows the `bin/rails db:prepare rbs_rails:all` step ran before `steep check`.
- Running `steep check` in the repo exits 0 → check: `steep check && echo STEEP-OK` prints `No type error detected.` and then `STEEP-OK`.
- A method called with the wrong argument type makes `steep check` fail → check: write `app/models/steep_probe.rb` with `class SteepProbe`, one method `# @rbs () -> void` / `def run` whose body is `Sticker.new.sticker_card = User.new` and `ChildProfile.new.broadcast_completion_flag(card_id: "one")`. Run the full `steep check`. It must exit non-zero with exactly two `Ruby::ArgumentTypeMismatch` diagnostics, both in `steep_probe.rb`. Run it as `trap 'rm -f app/models/steep_probe.rb' EXIT` in a subshell, so the file goes even when Steep fails; never commit it.
- No YARD tag remains in `app/` or `lib/` → check: `git grep -nE '^[[:space:]]*#[[:space:]]*@!?[a-z]' -- '*.rb' ':!vendor' | grep -vE '#[[:space:]]*@(rbs|type)\b'` prints nothing.
- Every method in `app/` and `lib/` has an inline RBS signature → check: the unsigned-method check prints `0 unsigned or invalid` and exits 0:

  ```sh
  bundle exec ruby -e 'require "rbs"; walk = ->(ds) { ds.flat_map { |d| d.respond_to?(:members) ? walk.(d.members) : [d] } }; m = Dir["{app,lib}/**/*.rb"].sort.flat_map { |f| s = File.read(f); pr = Prism.parse(s); r = RBS::InlineParser.parse(RBS::Buffer.new(name: f, content: s), pr); signed = walk.(r.declarations).grep(RBS::AST::Ruby::Members::DefMember).reject { |d| d.method_type.type_annotations.nil? }.map { |d| d.location.start_line }; r.diagnostics.map { |d| "#{f}: #{d.message}" } + pr.value.breadth_first_search_all { |n| n.is_a?(Prism::DefNode) }.reject { |n| signed.include?(n.location.start_line) }.map { |n| "#{f}:#{n.location.start_line} #{n.name}" } }; puts m; warn "#{m.size} unsigned or invalid"; exit(m.empty? ? 0 : 1)'
  ```

- Every method has a one-line description above its signature, and every class and module a one-line summary → check: the comment-block check prints `0 without summary` and `0 without description` and exits 0. For each `def`, `class` and `module` node it reads the contiguous comment block directly above the node; the first line must be one prose sentence (`# `, a capital, two or more words, a final full stop, not a `TODO`, `NOTE` or fix-me marker), and for a `def` the last line must start with `# @rbs`. The new `module Admin` and `module Users` lines are nodes it checks.

  ```sh
  bundle exec ruby - app lib <<'RUBY'
  require "prism"
  signature = /\A\s*#\s*@rbs\b/
  sentence = /\A\s*# [A-Z]\S*( \S+)+\.\s*\z/
  note = /\A\s*#\s*(TODO|NOTE|FIX[A-Z]*)\b/
  missing = Hash.new { |hash, key| hash[key] = [] }
  ARGV.flat_map { |dir| Dir["#{dir}/**/*.rb"] }.sort.each do |file|
    lines = File.readlines(file)
    Prism.parse(lines.join).value.breadth_first_search_all { |node| node.is_a?(Prism::DefNode) || node.is_a?(Prism::ClassNode) || node.is_a?(Prism::ModuleNode) }.each do |node|
      index = node.location.start_line - 2
      block = []
      while index >= 0 && lines[index] =~ /\A\s*#/
        block.unshift(lines[index])
        index -= 1
      end
      first = block.first
      prose = first && first =~ sentence && first !~ note
      kind = node.is_a?(Prism::DefNode) ? "description" : "summary"
      prose &&= block.last =~ signature if node.is_a?(Prism::DefNode)
      missing[kind] << "#{file}:#{node.location.start_line}" unless prose
    end
  end
  missing.each_value { |list| puts list }
  puts "#{missing["summary"].size} without summary"
  puts "#{missing["description"].size} without description"
  exit(missing.values.all?(&:empty?) ? 0 : 1)
  RUBY
  ```
- `bin/rails test`, `bin/rubocop` and `bin/brakeman` stay green → check: each exits 0, and so do `bin/rails test:system`, `bin/erb_lint --lint-all --allow-no-files` and `bundle exec bundle-audit check --update`.

Per changed file, the unit tests expected:

- `app/controllers/admin/*_controller.rb`, `app/controllers/users/profiles_controller.rb`: the existing `test/integration/admin/*` and `test/integration/users/*` tests stay green.
- `app/models/sticker_card.rb`: the existing `test/models/sticker_card_test.rb` stays green.
- `app/models/user/role.rb`, `app/helpers/application_helper.rb`: comment lines only; the existing suite covers them.
- `bin/setup`: running `bin/setup --skip-server` exits 0 and leaves `sig/rbs_rails/path_helpers.rbs` and `.gem_rbs_collection/` on disk.

Test setup: none new. The development database comes from `bin/rails db:prepare`.

---
Domain skills applied: rails-architecture, ruby-style, rails-testing.

## Critique

### Round 1 (codex exec -p terra)

- The plan leaves four tracked `sig/stubs/*.rbs` files, so the `git ls-files sig` criterion still fails after step 6; resolve the decision before implementation → dismissed: `intent.md` says a gap that cannot be covered without a tracked file goes back to Etienne as one concrete question, and auto mode forbids guessing it. The plan states that question once, with options, and every step before it holds under each option.
- Generation alone cannot make a fresh clone type-check, because `.gem_rbs_collection/` is ignored and neither `bin/setup` nor the documented command installs it → fixed (the documented command line and `bin/setup` now run `bin/rbs collection install --frozen` first, and the fresh-clone check runs the documented line in that order)
- The `bin/setup` line after `db:prepare` runs before the `--reset` branch, so a reset run generates from the database before its reset → fixed (the generation section now comes after the `--reset` line)
- The docs mention regeneration only after migrations, but `rbs_rails:all` also generates route helpers → fixed (the `AGENTS.md` line and the Risks entry say to rerun after a migration or a route change)
- `gh pr checks 180` cannot show that the job log contains the generation step → fixed (the CI check now reads the steep job log with `gh run view --log`)
- The two structural checks are only referenced through an older commit, and the probe file cleanup is not failure-safe → fixed (both checks are copied into `## Proof` verbatim, and the probe runs under a `trap` that deletes the file on exit)

## Decisions (Etienne, 2026-10-17)

- Gap stubs: option B. Delete `appkit.rbs`, `turbo_rails.rbs`, `rails.rbs` and `rbs_rails_overrides.rbs`. No signature file stays in git, and `git ls-files sig` must print nothing.
- Cover each gap inline: `# @rbs skip` on the Appkit includes (verified in the probe), and `#: untyped` or `# @type var`/`# @type self` markers at each remaining call site. Keep every marker behaviour-free, and keep the list of marked sites in the implement report.
- Do not push. The `review-report-fresh` hook needs Etienne's `/review` first. Commit locally and report. Include the unpushed CI commit `f27e40b` in that review.
- The CI `steep` job runs the one documented generation command before `steep check`, and keeps the `GEM_PATH` line from `f27e40b`.

## Decisions (Etienne, 2026-10-18)

- Merge of PR #180 waits until the appkit gem ships its own `sig/`. Use `ship --no-merge` only.
- The RBS collection files use the `.yml` extension: `rbs_collection.yml` and `rbs_collection.lock.yml`. Every `rbs collection` call passes `--collection=rbs_collection.yml`, and the `Steepfile` sets `collection_config "rbs_collection.yml"`.
