# Plan: Inline RBS instead of YARD (round 2: summaries, descriptions, rbs_rails)

From `intent.md` (2026-10-16, revised after delivery). Status: accepted.

## Context

This is a personal Rails 8.1.4 app on Ruby 4.0.6, managed by `rv`. Branch `inline-rbs` already delivers the first version of the intent, in commits `4d5153c..50589d4`:

- `Steepfile` (`target :app`, `signature "sig"`, `check "app", "lib", inline: true`), `rbs_collection.yaml`, `rbs_collection.lock.yaml` and `/.gem_rbs_collection/` in `.gitignore`.
- A `# @rbs` signature on each of the 119 `def` nodes in `app/` and `lib/`. `lib/` holds only an empty `lib/tasks/`.
- Hand-written stubs: `sig/models/*.rbs` (6 files, 136 lines) and `sig/stubs/{active_record,appkit,namespaces,rails,routes}.rbs`.
- A `steep` job in `.github/workflows/ci.yml`, and the `steep check` line in `AGENTS.md` (`CLAUDE.md` is a tracked symlink to it).
- `Current#account` removed on Etienne's decision (2026-10-16, recorded in commit `48ae61b`), and the grouped `include` lines split. `steep check` exits 0, and review rounds 1 to 4 in `review.md` closed with no open finding.

After delivery Etienne revised `intent.md`. This plan covers only the new work:

1. A one-line summary comment above every class and module in `app/` and `lib/`.
2. A one-line description above every method signature in `app/` and `lib/`.
3. `rbs_rails` as a development gem, whose generated RBS replaces the hand-written `sig/models/*.rbs`.
4. From the PR #180 review, passed on by the coordinator: an audit of each `sig/stubs/*.rbs` file against the RBS collection, keeping only real gaps with a header comment that names the gap.

Facts measured on 2026-10-16 in this worktree (`50589d4`):

- Steep 2.1.0 is installed globally (`steep --version`).
- 50 `class`/`module` nodes exist in `app/` and `lib/`, and none has a summary comment. The intent counts 44; the difference is the namespace reopenings (`module Parent` opens in 10 files, `module ApplicationCable` in 2, `module Authorization` in 2). This plan covers all 50 nodes, which satisfies "every class and module" under either count.
- 114 of the 119 `def` nodes have no comment line other than `# @rbs`. The other 5 have only a "why" or `TODO` comment, which is not a description: `StickerCard#positive_count` and `#create_new_card_if_just_completed` (`TODO`), `ApplicationController#post_authenticating_url` and `#redirect_signed_in_user_to_root` (Appkit notes), `ApplicationHelper#transfer_qr_code_path` (QR note). All 119 need a description.
- The YARD tag grep in `## Proof` prints nothing, over every tracked `.rb` file.

A probe on 2026-10-16, in a throwaway copy of this tree under the session scratchpad (never in this worktree), proved the `rbs_rails` path:

- `gem "rbs_rails", require: false` in `group :development`, installed with `bi`, adds only `rbs_rails (0.13.1)` to `Gemfile.lock`. Its dependencies `parser`, `prism` and `rbs (>= 1)` are already locked.
- `bin/rails rbs_rails:generate_rbs_for_models`, through a `lib/tasks/rbs.rake` written in house style (below), passes `bin/rubocop` and generates 11 files, 4,818 lines, under `sig/rbs_rails/app/models/`. They cover the 7 app models that have a table, plus `ActiveStorage::{Attachment,Blob,VariantRecord}` and `Appkit::PushSubscription`. It skips `Transfer` (no table) and `ApplicationRecord` (abstract). A second run changes no file, and the gem's CLI `bundle exec rbs_rails models` writes the same output.
- The generated `Allowance` types fix the four errors that the review found in the hand-written `sig/models/allowance.rbs`: `child_profile_id=: (::Integer) -> ::Integer` exists, `next_due_on` and `next_due_on=` both use `::Date`, `kind=` and `frequency=` take `(::Integer | ::String | ::Symbol)`, and `allowance_periods` returns `::AllowancePeriod::ActiveRecord_Associations_CollectionProxy`.
- It needs a migrated development database (`check_db_migrations` is on by default). The worktree has only `storage/test.sqlite3`; `bin/rails db:prepare` creates `storage/development.sqlite3`, which `.gitignore` already ignores.
- With `sig/models/` deleted, `steep check` reported 11 errors. The fixes listed under Design decisions cleared all 11. `steep check` then printed `No type error detected.`
- Stub audit: each part of `sig/stubs/` was removed on its own, and `steep check` was run each time. Error counts without each part:

  | Stub part | Errors without it | Verdict |
  | --- | --- | --- |
  | `active_record.rbs` (`_ModelQueries`, `ApplicationRecord` readers) | 0 | Duplicate of generated and collection types: delete. |
  | `rails.rbs`: `ApplicationRecord#id`, `#created_at`, `#updated_at` | 0 | Duplicate of the generated readers: delete. |
  | `rails.rbs`: `Rails::Application::Configuration#git_revision`, `#app_version` | 2 | Gap: app-specific config keys. Keep. |
  | `rails.rbs`: `ApplicationCable::Connection#current_user=` | 1 | Gap: made at runtime by `identified_by`. Keep. |
  | `rails.rbs`: `Current.user`, `.user=`, `#user` | 19 | Gap: made at runtime by `attribute`. Keep. |
  | `rails.rbs`: `User::Role#administrator?` | 1 | Gap: the generated `User#administrator?` is not visible under `module-self: ApplicationRecord`, and `module-self: User` is a circular mix-in error. Keep. |
  | `namespaces.rbs` (`module Admin`, `module Users`) | 4 | Gap: compact `class Admin::X` needs the namespace declared. Keep. |
  | `routes.rbs` | 26 | Gap: the collection has no route helpers. Generated path helpers (`rbs_rails:generate_rbs_for_path_helpers`) still leave 2 errors, because they miss `qr_code_path` and `session_transfer_url` in `ActionView::Base`. Keep. |
  | `appkit.rbs` | 3 | Gap: Appkit ships no RBS and has no collection entry. Keep. |
  | `turbo_rails.rbs` (new) | 5 | Gap: turbo-rails has no collection entry. Keep. |
- The type-error probe still fails Steep with two `Ruby::ArgumentTypeMismatch` diagnostics, but only under a full `steep check`. `steep check <one file>` does not load the inline signatures of the other files and reports `NoMethod` instead, so the Proof uses the full run.
- `bin/rbs collection install --frozen` still passes with the old lockfile. A plain `bin/rbs collection install` adds the `rbs` and `optparse` entries and rewrites the YAML indentation. `steep check` stays clean with the new lockfile.
- `RBS::InlineParser` (rbs 4.2.0) reads a description line, an extra comment line and then `# @rbs () -> Integer` above a `def` as a signed method. It reads a summary line followed by `# @rbs module-self: X` above a module as a `module-self` member. It reports no diagnostic for either.

## Design decisions

- **Comment block order.** Directly above each `class`, `module` and `def` sits one contiguous comment block, in this order: (1) the one-line summary or description, (2) any existing "why" or `TODO` comment, unchanged, (3) the existing `# @rbs` lines, last, directly above the `def`. For a module with `# @rbs module-self:`, the summary goes above that line. Never put a blank line inside the block; the inline parser attaches only a contiguous block.
- **Wording.** Short, direct, present tense, one line under 120 characters, ending with a full stop. Classes and modules: "Represents a child's sticker card toward a reward." Methods: a verb phrase such as "Returns the newest sticker card, creating one if none exists." Never use patterns such as "Domain model for X", "This method ...", or restate the signature ("Takes an Integer and returns a Date"). Describe what the method does in domain terms; read the method body and `AGENTS.md` before writing each line. Controller actions describe the action ("Awards a positive sticker to the child's active card."). Callbacks name their trigger ("Copies the profile's sticker goal onto a new card."). Namespace reopenings get the same line in every file, for example `# Groups the controllers that parents use.` above each `module Parent`.
- **Descriptions on every method, private ones included.** The dotfiles' `ruby-style` default is a summary per class, a signature per method, and other comments only for a non-obvious why. Etienne asked explicitly on 2026-10-16 for a one-line description above each method, and `intent.md` records it, so this plan keeps the descriptions. That request overrides the default for this repository.
- **No other comment changes.** Existing "why" and `TODO` comments, including the comment inside `ChildProfile#rewardable_sticker_card`, stay word for word. No `@param`, `@return` or other YARD tag.
- **`rbs_rails` replaces the hand-written model stubs.** Add `gem "rbs_rails", require: false` to the existing `group :development`, with a one-line comment in the Gemfile's style. Generate with `bundle exec rbs_rails models` into the default `sig/rbs_rails/`. Commit the generated files, because the CI `steep` job has no database to generate them from. Regenerate through a rake task, so the command is the usual `bin/rails` one after a migration. Write `lib/tasks/rbs.rake` by hand rather than with `bin/rails g rbs_rails:install`, whose template uses single quotes:

  ```ruby
  # Adds the rbs_rails tasks, which generate RBS for the Active Record models into sig/rbs_rails.
  begin
    require "rbs_rails/rake_task"

    RbsRails::RakeTask.new
  rescue LoadError
    # rbs_rails is a development gem, so production has no such tasks.
  end
  ```

  The `rescue LoadError` keeps `bin/rails -T` working where the development group is not installed. Do not add `.rbs_rails.rb` or `config/rbs_rails.rb`: the defaults work, and `config/` is out of scope. Do not generate path helpers; the stub audit shows they do not replace `sig/stubs/routes.rbs`.
- **Hand-written stubs after the switch.** Follow the stub audit table in Context. Delete `sig/models/*.rbs` (all 6) and `sig/stubs/active_record.rbs`. Remove the `ApplicationRecord` block from `sig/stubs/rails.rbs`. `_ModelQueries` returned `untyped` from `all`, `where`, `order` and `includes`, which masked the collection's relation types; deleting it lets them through. Keep the other parts of `rails.rbs`, and `appkit.rbs`, `namespaces.rbs` and `routes.rbs`, with their declarations unchanged. Give every file in `sig/stubs/` a header: RBS `#` comment lines at the top that name the gap it fills, for example `# Appkit ships no RBS, and the RBS collection has no entry for it.` In `rails.rbs`, put a one-line comment above each block naming its gap (config keys, `identified_by`, `CurrentAttributes`, the concern's own enum). Add two files, each with such a header:
  - `sig/stubs/turbo_rails.rbs`: `module Turbo::Broadcastable` with `broadcast_replace_to` and `broadcast_append_to`, both `(*untyped, **untyped) -> void`, included into `ActiveRecord::Base`. The RBS collection has no turbo-rails entry. These two methods were in `sig/models/child_profile.rbs` and `sig/models/sticker.rbs` before.
  - `sig/stubs/rbs_rails_overrides.rbs`: gaps in the generated and collection types, declared in the class body so that they override an included module and never duplicate it: `ActiveStorage::Attached::One#blob: () -> ActiveStorage::Blob`, `User#attachment_changes: () -> Hash[String, untyped]`, and `StickerCard#completed_at=: (ActiveSupport::TimeWithZone | Time | nil) -> (ActiveSupport::TimeWithZone | Time | nil)`. The last one exists because the generated setter accepts only `TimeWithZone`, while `Time.current` is typed `Time | TimeWithZone`; the setter accepts both at runtime. Overriding the type keeps `app/models/sticker_card.rb` code unchanged.
- **The nil card in two controllers.** `Parent::StickersController#create` and `Parent::PenaltiesController#create` call `card.stickers` on `child.sticker_cards.order(created_at: :desc).first`. The generated type is `StickerCard | nil`, so Steep reports `Ruby::NoMethod`. Every code fix changes what happens when a child has no card (today a `NoMethodError` and a 500), and the intent forbids behaviour changes. This plan therefore adds the behaviour-free Steep annotation `# @type var card: untyped` on the line above each `card =` assignment. It is a type annotation, not a `# steep:ignore`. The alternative, `card = child.active_sticker_card`, is typed `StickerCard` and matches the domain, but creates a card on that path instead of failing. It goes in the report as a `Decision needed:` line; this plan does not take it.
- **Fallback.** If `rbs_rails` fails in this worktree in a way the probe did not show (generation error, or a Steep diagnostic that needs a behaviour change), revert the Gemfile change, keep the hand-written `sig/models/*.rbs`, add a header comment to each (`# Hand-written: rbs_rails <reason>.`), and report the reason. This is the intent's own fallback.
- **RBS collection lockfile.** Refresh it with `bin/rbs collection install` (bundled rbs 4.2.0) after the Gemfile change, so it matches `Gemfile.lock`, and commit it on its own. The YAML indentation change in that diff is the tool's output; do not hand-edit it.
- **Regeneration recipe.** Add one line to the `AGENTS.md` Commands block: `bin/rails rbs_rails:generate_rbs_for_models  # regenerate sig/rbs_rails after a migration`. Without it, nobody knows how the 4,818 committed lines are made. Edit `AGENTS.md`, never the `CLAUDE.md` symlink.
- **No CI change.** The existing `steep` job reads the committed `sig/rbs_rails/`. A CI check that the generated files are fresh is not in the intent; it is listed as deferred in the report.
- **Checks are commands, not committed files.** The summary and description checks below run from the repository root, as the existing unsigned-method check does. The intent lists no new script in scope.

## Integration points

- `rbs_rails` 0.13.1 (new development gem, approved in `intent.md`); its CLI boots the app in development and reads the schema from `storage/development.sqlite3`.
- Steep 2.1.0, global install locally and `gem install` in the existing CI `steep` job. Never in the Gemfile.
- `ruby/gem_rbs_collection` through `rbs_collection.yaml`; the generated model RBS uses its `ActiveRecord::Base::ClassMethods` and `ActiveRecord::Relation::Methods` types.
- `eirvandelden/appkit`: unchanged. Its `Appkit::PushSubscription` model gets generated RBS, and `sig/stubs/appkit.rbs` stays.
- `rubocop-eirvandelden`: unchanged. Plain `#` comment lines pass it.

## Files that change

- `Gemfile`, `Gemfile.lock`: add `rbs_rails` to `group :development` (the only gem change).
- `rbs_collection.lock.yaml`: refreshed by `bin/rbs collection install`.
- `sig/rbs_rails/app/models/**/*.rbs` (new, generated, 11 files).
- `lib/tasks/rbs.rake` (new): the rbs_rails rake tasks.
- `sig/models/*.rbs` (6 files) and `sig/stubs/active_record.rbs`: deleted.
- `sig/stubs/rails.rbs`: `ApplicationRecord` block removed, gap comments added.
- `sig/stubs/appkit.rbs`, `sig/stubs/namespaces.rbs`, `sig/stubs/routes.rbs`: header comment only.
- `sig/stubs/turbo_rails.rbs`, `sig/stubs/rbs_rails_overrides.rbs` (new), as described above.
- `app/controllers/parent/stickers_controller.rb`, `app/controllers/parent/penalties_controller.rb`: one `# @type var card: untyped` line each.
- Every `.rb` file in `app/` (37 files): summary comments above each `class`/`module` and a description above each `def`. Comment lines only.
- `AGENTS.md`: the regeneration line.

## Order of work

1. Walking skeleton: run the summary check and the description check from `## Proof`. Watch them fail with `50 without summary` and `118 without description` (measured 2026-10-16). The check counts 118, not 119, because the "why" comment above `ApplicationHelper#transfer_qr_code_path` is one full sentence. That method still gets a description line above its "why" comment. A sample file in the scratchpad confirmed that the check passes a description followed by a `TODO` and `# @rbs`, passes a summary followed by `# @rbs module-self:`, and fails a bare `#`. Run the unsigned-method check and watch it pass with `0 unsigned or invalid`.
2. Add `rbs_rails` to the Gemfile and run `bi`. Confirm that `git diff Gemfile.lock` adds only the `rbs_rails` entries. Add `lib/tasks/rbs.rake`, run `bin/rails -T rbs_rails` (three tasks) and `bin/rubocop lib/tasks/rbs.rake`. Run `bundle exec bundle-audit check --update`. Commit (`chore: add rbs_rails for model signatures`).
3. Run `bin/rails db:prepare` (development), then `bin/rails rbs_rails:generate_rbs_for_models`. Confirm the four `Allowance` types listed in Context in `sig/rbs_rails/app/models/allowance.rbs`. Delete `sig/models/`, `sig/stubs/active_record.rbs` and the `ApplicationRecord` block in `sig/stubs/rails.rbs`. Run `steep check` and confirm it reports the same 11 diagnostics as the probe (5 broadcast, 2 nil card, 2 `blob`, 1 `attachment_changes`, 1 `completed_at=`). If it reports others, fix each one with a stub only, or apply the fallback.
4. Add `sig/stubs/turbo_rails.rbs`, `sig/stubs/rbs_rails_overrides.rbs`, the header and gap comments in `sig/stubs/`, and the two `# @type var card: untyped` lines. Run `steep check` until it exits 0. Run the type-error probe from `## Proof`. Run `bin/rails test test/models test/controllers/parent`. Commit generated files, deletions and stubs together (`chore: generate model RBS with rbs_rails`), because any split leaves `steep check` red.
5. Run `bin/rbs collection install`, then `steep check` and `bin/rbs collection install --frozen`. Commit `rbs_collection.lock.yaml` on its own.
6. Models: add summaries and descriptions to every file in `app/models/` (including `concerns/` and `user/`). Run the comment-block check on `app/models`, `steep check` and `bin/rubocop app/models`. Commit (`docs: describe models`).
7. Controllers and concerns: the same for `app/controllers/` (check scope `app/controllers`), one commit per namespace (`admin`, `parent`, `child`, `users`, root controller and concerns).
8. Channels, jobs and helpers: the same for `app/channels/`, `app/jobs/` and `app/helpers/`. Commit. The comment-block check with its default `app lib` now prints `0 without summary` and `0 without description`.
9. Add the regeneration line to `AGENTS.md`. Commit.
10. Full gate: every `## Proof` check, then `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bundle exec bundle-audit check --update`, `bin/erb_lint --lint-all --allow-no-files`. Re-read the full diff against `50589d4`: every hunk in `app/` must be comment lines only (`git diff 50589d4 -- app | grep -E '^[+-][^+-]' | grep -vE '^[+-][[:space:]]*#'` prints nothing except the two `# @type` lines, which the second `grep` already removes). `lib/tasks/rbs.rake` is the one new code file outside `app/`; step 2 verifies it with `bin/rails -T rbs_rails` and `bin/rubocop`. Push, and confirm the CI `steep` job passes on the pull request.

## Out of scope

- Any other Gemfile change, Steep in the bundle, `rbs-inline`, rbs_rails configuration files, and generated path helpers.
- `rubocop-yard`, `rubocop-eirvandelden`, any RuboCop config edit, `# steep:ignore`, and Steep diagnostic level changes.
- Comments or signatures in `test/`, `config/`, `db/`, views and the Appkit gem.
- A CI freshness check for `sig/rbs_rails/`, and any other `.github/` edit.
- Behaviour changes: the nil-card code change (see Design decisions), the `Transfer` stub, the unfinished allowance code, the shadowed `app/models/concerns/authorization.rb`, and the second `enum :role` in `User::Role`.

## Risks

- **Stale generated RBS.** A future migration leaves `sig/rbs_rails/` out of date, and Steep then checks against old columns. Mitigation: the rake task and the `AGENTS.md` regeneration line. A CI freshness check is deferred.
- **Overrides hide real types.** `rbs_rails_overrides.rbs` widens three types. Each is a known gap in generated or collection RBS, and each override is narrower than the `untyped` it replaces in the old hand stubs.
- **`# @type var card: untyped`** removes checking from two local variables. Accepted until Etienne decides on `active_sticker_card`.
- **Probe drift.** The probe ran in a copy; the worktree may still differ (another dev database state, another collection checkout). Mitigation: step 3 compares the diagnostics against the probe before any fix, and the fallback exists.
- **Description quality.** A mechanical check proves a line exists, not that it is true. Mitigation: each line is written after reading the method body, and step 10 re-reads the diff.
- **Comment block attachment.** A blank line between the description and `# @rbs` would detach nothing in Ruby but could split the RBS comment block. Mitigation: the unsigned-method check catches a detached signature.
- Rejected: committing no generated RBS and generating it in CI (the CI job would need a database and a Rails boot, and the intent did not approve that `.github/` change); `config/rbs_rails.rb` (in `config/`, out of scope); the `Time.current` to `Time.zone.now` code edit (a code change where a type override suffices); `.first!` or `active_sticker_card` in the controllers (behaviour changes).

## Proof

The change adds no runtime behaviour, so no new Minitest test exists. The type checker, the check commands below and the existing suites are the proof. Step 1 runs the two new checks and watches them fail.

- Running `steep check` in the repo exits 0 → check: `steep check && echo STEEP-OK` prints `No type error detected.` and then `STEEP-OK`.
- A method called with the wrong argument type makes `steep check` fail → check: write `app/models/steep_probe.rb` with `class SteepProbe`, one method `# @rbs () -> void` / `def run` whose body is `Sticker.new.sticker_card = User.new` and `ChildProfile.new.broadcast_completion_flag(card_id: "one")`. Run the full `steep check` (not a single file). It must exit non-zero with exactly two `Ruby::ArgumentTypeMismatch` diagnostics, both in `steep_probe.rb`. Delete the file; never commit it.
- No `@param`, `@return` or other YARD tag remains in `app/` or `lib/` → check: `git grep -nE '^[[:space:]]*#[[:space:]]*@!?[a-z]' -- '*.rb' ':!vendor' | grep -vE '#[[:space:]]*@(rbs|type)\b'` prints nothing (exit status 1). It flags any comment line that starts with an `@` tag or `@!` directive, so every YARD tag (`@param`, `@author`, `@!method`, ...) fails it, and only the RBS `@rbs` and Steep `@type` annotations pass. E-mail addresses in strings do not match, because the line must start with `#`.
- Every method in `app/` and `lib/` has an inline RBS signature → check: the unsigned-method check prints `0 unsigned or invalid` and exits 0:

  ```sh
  bundle exec ruby -e 'require "rbs"; walk = ->(ds) { ds.flat_map { |d| d.respond_to?(:members) ? walk.(d.members) : [d] } }; m = Dir["{app,lib}/**/*.rb"].sort.flat_map { |f| s = File.read(f); pr = Prism.parse(s); r = RBS::InlineParser.parse(RBS::Buffer.new(name: f, content: s), pr); signed = walk.(r.declarations).grep(RBS::AST::Ruby::Members::DefMember).reject { |d| d.method_type.type_annotations.nil? }.map { |d| d.location.start_line }; r.diagnostics.map { |d| "#{f}: #{d.message}" } + pr.value.breadth_first_search_all { |n| n.is_a?(Prism::DefNode) }.reject { |n| signed.include?(n.location.start_line) }.map { |n| "#{f}:#{n.location.start_line} #{n.name}" } }; puts m; warn "#{m.size} unsigned or invalid"; exit(m.empty? ? 0 : 1)'
  ```

- Every method in `app/` and `lib/` has a one-line description above its signature, and every class and module has a one-line summary → check: the comment-block check prints `0 without summary` and `0 without description` and exits 0. For each `def`, `class` and `module` node it reads the contiguous comment block directly above the node. The first line of that block must be one prose sentence: `# `, a capital letter, at least one more word, and a final full stop, and not a `TODO`, `NOTE` or fix-me marker. A bare `#`, an `@` tag and a multi-line "why" comment's opening line (which does not end in a full stop) all fail it. For a `def`, the last line of the block must start with `# @rbs`. It takes directories as arguments (default `app lib`), so steps 6 to 8 run it on one directory, for example `bundle exec ruby - app/models <<'RUBY'` with the same body.

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

- A pull request runs the Steep job in CI, and it passes → check: `gh pr checks` shows `steep` as pass on the pull request.
- `bin/rails test`, `bin/rubocop` and `bin/brakeman` stay green → check: each exits 0. `bin/rails test:system`, `bin/erb_lint --lint-all --allow-no-files` and `bundle exec bundle-audit check --update` also stay green.

Per changed file, the unit tests expected:

- `app/controllers/parent/stickers_controller.rb`, `app/controllers/parent/penalties_controller.rb` (one `# @type` comment each): the existing controller tests in `test/controllers/parent/` stay green.
- Every other changed Ruby file gains comment lines only; the existing suite covers it, and the comment-only diff check in step 10 proves no code line changed.
- `Gemfile` (`rbs_rails`, `require: false`): `bin/rails test` stays green, because the app never loads the gem.

Test setup: none new. The development database comes from `bin/rails db:prepare`. The probe file lives only for the Proof check.

---
Domain skills applied: ruby-style, rails-architecture, rails-testing, dependencies.

## Critique

### Round 1 (codex exec -p terra)

- The `Current#account` removal breaks "no behaviour change", and the step 10 diff base `50589d4` hides it → dismissed: Etienne decided the removal on 2026-10-16, recorded in commit `48ae61b`, and it shipped in the first delivery; this plan only covers the work after `50589d4`, so that base is deliberate. The Context section now names the decision and its commit.
- `steep check; echo $?` succeeds even when Steep fails, because `echo` runs last → fixed (the check is now `steep check && echo STEEP-OK`)
- The YARD grep allowlist misses tags such as `@author`, `@group`, `@macro` and `@!method` → fixed (the grep now flags every comment line that starts with an `@` tag or `@!` directive, except `@rbs` and `@type`; it prints nothing over all tracked `.rb` files today)
- The comment-block check accepts a bare `#` or any non-annotation line as prose → fixed (the first line must be one sentence: `# `, a capital, two or more words and a final full stop, and not a TODO, NOTE or fix-me marker; rerun on 2026-10-16 it reports 50 and 118; two of the three "why" comments now count as missing, and the third is one full sentence, so step 1 names that method explicitly)
- The per-directory checks in steps 6 to 8 cannot run, because the script hard-codes `{app,lib}` → fixed (the script takes directories as arguments, default `app lib`, and steps 6 to 8 name the directory)

### Round 2 (coordinator, from the PR #180 review)

- Replace `sig/models/*.rbs` with `rbs_rails` output, regenerated by a rake task, and keep the fallback → fixed (Design decisions add a house-style `lib/tasks/rbs.rake`, verified with `bin/rails -T` and `bin/rubocop` in the probe; the regeneration line uses `bin/rails rbs_rails:generate_rbs_for_models`; the fallback stays)
- Check each `sig/stubs` file against the RBS collection and keep only real gaps, with a header that names the gap → fixed (Context adds a stub audit table measured in the probe: `active_record.rbs` and the `ApplicationRecord` block of `rails.rbs` are deleted as duplicates, every other part is a measured gap, and every stub file gets a header naming its gap; generated path helpers were tried and do not replace `routes.rbs`)
- Fix the `Allowance` type errors (`child_profile_id` writer, `next_due_on` nullability, `kind=` and `frequency=` as `untyped`, `allowance_periods` as `untyped`) → fixed (the generated types correct all four, listed in Context, and step 3 confirms them before the old stubs go)
- Keep the one-line method descriptions, because Etienne asked for them → fixed (the plan already required them; Design decisions now state that his 2026-10-16 request overrides the `ruby-style` default for this repository)

### Round 3 (codex exec -p terra)

- The comment-only diff check covers `lib`, but the new `lib/tasks/rbs.rake` is code, so the check would print its lines → fixed (step 10 limits the check to `app` and names the rake file's own verification in step 2)
- The comment-block check accepts `# @type` as a method block's last line, though it claims to require `# @rbs` → fixed (the last-line regex is now `@rbs` only; the unused `annotation` regex is gone)

## Decisions (coordinator, 2026-10-16)

- Keep `# @type var card: untyped` in `Parent::StickersController#create` and `Parent::PenaltiesController#create`. The intent excludes behaviour changes, and `child.active_sticker_card` would create a card where the code raises today.
- Do not push. The `review-report-fresh` hook needs Etienne's `/review` first. Commit locally and report.
