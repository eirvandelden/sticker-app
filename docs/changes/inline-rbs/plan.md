# Plan: Inline RBS instead of YARD

From `intent.md` (2026-10-16). Status: accepted.

## Context

This is a personal Rails 8.1.4 app on Ruby 4.0.6, managed by `rv`. It has about 1,000 lines of Ruby in `app/` and nothing but an empty `lib/tasks/` in `lib/`. It has 120 `def` nodes in `app/` and `lib/`, and none of them has a signature. The comment-anchored YARD grep in `## Proof`, run over every tracked `.rb` file, finds nothing on 2026-10-16, so no YARD tag needs removal today. `rbs` 4.2.0 is already in `Gemfile.lock` (a dependency of `rdoc`), with a tracked binstub at `bin/rbs`. Steep is not in the Gemfile, and on 2026-10-16 it was also not installed globally on this machine (`steep: command not found`).

## Design decisions

- **Annotation form: `# @rbs`, never `#:`.** `rubocop-eirvandelden` keeps RuboCop's default `Layout/LeadingCommentSpace` (`AllowRBSInlineAnnotation: false`). A probe file run through `bin/rubocop` on 2026-10-16 flagged both a leading `#: (Integer) -> String` and a trailing `def three(value) #: String` as offences, and `rubocop -a` would rewrite them to `# :`, which silently breaks the annotation. `# @rbs (Integer) -> String`, `# @rbs value: Integer` and `# @rbs return: String` pass RuboCop and every enabled `YARD/*` cop. The playbook forbids linter config edits and disable comments, and `rubocop-eirvandelden` is out of scope, so `# @rbs` is the only form.
- **Method type style.** Use the one-line form `# @rbs (Integer day, after: Date) -> Date?` directly above the `def` when it fits in 120 characters. Use the doc-style form (`# @rbs day: Integer`, then `# @rbs return: Date?`) when it does not. Parsing with `RBS::InlineParser` from rbs 4.2.0 confirmed both forms, keyword arguments, `def self.` methods, `# @rbs @ivar: Type` and `# @rbs module-self: ApplicationController`.
- **Every method gets an explicit signature**, also methods with no parameters (`# @rbs () -> void`), controller actions and callbacks. Controller actions and `before_action` callbacks return `void`. Signatures are as precise as the code allows; `untyped` is allowed only where the value really is dynamic (for example `params` values, `Current.user` passed through Appkit).
- **Rails dynamic methods go in hand-written stubs under `sig/`.** No `rbs_rails` (it would be a Gemfile change). Stubs declare only what `steep check` reports as missing, and nothing more:
  - `sig/models/<model>.rbs`: column readers and writers (types from `db/schema.rb`), association readers and writers, enum predicates and scopes, `saved_change_to_*?`, named scopes. Singular associations are typed precisely (`def sticker_card: () -> StickerCard`, `def sticker_card=: (StickerCard?) -> StickerCard?`). Collection associations may return `untyped` when the gem_rbs_collection `CollectionProxy` types make a precise type impractical.
  - `sig/stubs/appkit.rbs`: empty or minimal declarations of `Appkit::Authentication`, `Appkit::SessionBehavior`, `Appkit::Transferable`, `Appkit::Authenticatable`, `Appkit::UserTheming` and `Appkit::QrCodeLink`, with only the methods app code calls (for example `signed_in?`, `transfer_id`, `QrCodeLink#signed`). Appkit itself stays untouched.
  - `sig/stubs/routes.rbs`: one interface `_AppRoutes` with the route helpers app code calls (`root_path`, `parent_children_path`, `edit_parent_child_path`, `child_dashboard_path`, `admin_user_path`, `admin_users_path`, `user_profile_path`, `qr_code_path`, `session_transfer_url`), included into `ActionController::Base` and `ActionView::Base`.
  - `sig/stubs/<gem>.rbs` for any other gap the collection leaves in Rails 8.1 or turbo-rails (for example `ActionController::Parameters#expect`, `allow_browser`, `broadcast_replace_to`, `broadcast_append_to`, `identified_by`). One file per gem.
  - A stub file never re-declares a method that an inline annotation in `app/` declares; that is a `DuplicatedMethodDefinition` error.
- **Concerns and helpers declare their host with `module-self`.** Controller concerns use `# @rbs module-self: ApplicationController`; `ApplicationHelper` uses `# @rbs module-self: ActionView::Base`; `User::Role` uses `# @rbs module-self: User`. Instance variables that a concern reads (for example `@user`) get `# @rbs @user: User` in the module body.
- **Constants stay unannotated.** A constant annotation needs the trailing `#:` form, which RuboCop rejects, and a `sig/` re-declaration is a duplicate. Non-literal constants (`EMOJI_POOL`, `AVATAR_CONTENT_TYPES`, `MAX_AVATAR_SIZE`, the `NibudAdvice` tables) are therefore `untyped`, which Steep accepts.
- **Diagnostics stay at Steep's default level.** The Steepfile does not call `configure_code_diagnostics`. No `# steep:ignore` comment is allowed; it counts as a linter disable comment under the playbook. Every reported diagnostic is fixed with a signature, a stub, the include split below, or the `Current#account` decision below.
- **One code edit that Steep needs, without behaviour change:**
  - `include A, B` gives the diagnostic `MixinMultipleArguments` ("Only single module arguments are supported"). Split each grouped `include` into one `include` per module, in **reverse** order, because `include A, B` puts `A` before `B` in the ancestor chain and `include A` then `include B` would put `B` first. This applies to `app/models/user.rb` (two lines) and `app/controllers/application_controller.rb` (one line). `Style/MixinGrouping` is disabled in `rubocop-eirvandelden`, so both styles pass RuboCop.
- **One open decision: `Current#account`.** It calls `Account.first`, but no `Account` constant exists in the app or in Appkit, and nothing calls the method. Steep reports it as `UnknownConstant`. Every way to clear that diagnostic changes something the intent did not agree: removing the method changes a public method from raising `NameError` to raising `NoMethodError`, and a stub `class Account` in `sig/` declares a type that does not exist. This plan does not choose. Etienne decides; the recommendation is to remove the method, because it cannot work today. Until he decides, step 4 waits and `steep check` cannot exit 0.
- **Class summary comments.** Keep every existing class or method comment as it is (for example the `ChildProfile#rewardable_sticker_card` ordering note and the `ApplicationController` Appkit notes). Do not add new class summaries; the intent asks for signatures, not new prose.
- **Steep version.** CI installs `gem install steep --no-document --version "~> 2.0"`, the series that reads RBS 4 inline annotations through `check ..., inline: true`. Before writing the Steepfile, confirm with the installed Steep (`steep --version`, and its README or `steep help`) that `check "app", "lib", inline: true` is the right syntax, and that its `rbs` dependency accepts the 4.x lockfile. Adjust the constraint to the installed major version if it differs.
- **RBS collection.** Generate `rbs_collection.yaml` with `bin/rbs collection init` (bundled rbs 4.2.0); it only writes the config. Keep `path: .gem_rbs_collection`. `bin/rbs collection install` then reads `Gemfile.lock`, resolves the gem signatures and writes `rbs_collection.lock.yaml`. Record in the step 1 commit message which gems resolved to a gem_rbs_collection entry and which Rails version each entry targets. Commit `rbs_collection.lock.yaml`. CI installs it with `bin/rbs collection install --frozen` (the `--frozen` flag exists in rbs 4.2.0).
- **Unsigned-method check.** The criterion "every method has an inline RBS signature" is checked with `RBS::InlineParser` from the bundled rbs gem, so only a real method-type annotation counts (an `@rbs @ivar:` or `module-self` line above a `def` does not). The script lists every Prism `def` in `app/` and `lib/` that has no parsed method type, plus every inline-parser diagnostic (malformed or unused annotations, grouped mixins). Run it from the repository root. It must print `0 unsigned or invalid` and exit 0. It is a check command, not a committed file, because the intent does not list a new script in scope.

  ```sh
  bundle exec ruby -e 'require "rbs"; walk = ->(ds) { ds.flat_map { |d| d.respond_to?(:members) ? walk.(d.members) : [d] } }; m = Dir["{app,lib}/**/*.rb"].sort.flat_map { |f| s = File.read(f); pr = Prism.parse(s); r = RBS::InlineParser.parse(RBS::Buffer.new(name: f, content: s), pr); signed = walk.(r.declarations).grep(RBS::AST::Ruby::Members::DefMember).reject { |d| d.method_type.type_annotations.nil? }.map { |d| d.location.start_line }; r.diagnostics.map { |d| "#{f}: #{d.message}" } + pr.value.breadth_first_search_all { |n| n.is_a?(Prism::DefNode) }.reject { |n| signed.include?(n.location.start_line) }.map { |n| "#{f}:#{n.location.start_line} #{n.name}" } }; puts m; warn "#{m.size} unsigned or invalid"; exit(m.empty? ? 0 : 1)'
  ```

  On 2026-10-16 it reported `123 unsigned or invalid`: 120 unsigned `def`s and 3 `Mixing multiple modules with one call is not supported` diagnostics. A probe file confirmed that it flags a `def` with only an `@rbs @ivar:` line above it, and an unannotated `def`.

## Integration points

- Steep, installed globally (local) and with `gem install` in the CI job. Never in the Gemfile.
- `ruby/gem_rbs_collection` through `rbs_collection.yaml`, for Rails and other gem signatures.
- `eirvandelden/appkit`: its modules are referenced from app code but ship no RBS, so they get stubs here. The shared `rails-ci.yml` reusable workflow stays as it is; the Steep job is a separate job in this repo's `ci.yml`.
- `rubocop-eirvandelden` and its `rubocop-yard` cops: unchanged; the `# @rbs` form already passes them.

## Files that change

- `Steepfile` (new), with no diagnostics override:

  ```ruby
  target :app do
    signature "sig"
    check "app", "lib", inline: true
  end
  ```
- `rbs_collection.yaml` (new) and `rbs_collection.lock.yaml` (new): generated by `bin/rbs collection init` and `bin/rbs collection install`.
- `.gitignore`: add `/.gem_rbs_collection/`.
- `sig/models/*.rbs`, `sig/stubs/*.rbs` (new): stubs for Rails dynamic methods and Appkit, as described above, only as far as `steep check` needs.
- `app/models/*.rb`, `app/models/user/role.rb`, `app/models/concerns/authorization.rb`: `# @rbs` signatures on every method. `app/models/user.rb` also gets its grouped `include` lines split in reverse order. `app/models/current.rb` loses `Current#account` only if Etienne decides so (see Design decisions).
- `app/controllers/**/*.rb`, `app/controllers/concerns/*.rb`: `# @rbs` signatures on every action, callback and helper method; `module-self` on concerns. `app/controllers/application_controller.rb` also gets its grouped `include` split in reverse order.
- `app/jobs/*.rb`, `app/channels/application_cable/*.rb`, `app/helpers/application_helper.rb`: `# @rbs` signatures on every method.
- `.github/workflows/ci.yml`: a new `steep` job (approved in `intent.md`), same shape as the existing `i18n` job:

  ```yaml
  steep:
    name: steep
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7.0.1
      - uses: spinel-coop/setup-rv@main
        with:
          ruby-version: current
          install-gems: true
      - run: gem install steep --no-document --version "~> 2.0"
      - run: bin/rbs collection install --frozen
      - run: steep check
  ```

  If `gem install` does not put `steep` on `PATH` under `setup-rv`, fix the step (for example call it through `gem exec` or the gem bin path) rather than adding Steep to the Gemfile.
- `AGENTS.md`: add `steep check  # type check (inline RBS, also run in CI)` to the Commands block. `CLAUDE.md` is a tracked symlink to `AGENTS.md`; edit `AGENTS.md`, never the symlink.

## Order of work

0. Run `steep --version`. If Steep is missing, stop and report it; installing a global gem needs Etienne's permission (playbook rule 8). Record the version and confirm the `check ..., inline: true` syntax for it.
1. Walking skeleton: write `Steepfile`, run `bin/rbs collection init`, then `bin/rbs collection install`, add `/.gem_rbs_collection/` to `.gitignore`. Run `steep check` and watch it fail with many diagnostics (red). Record the diagnostic count. Commit: Steepfile, collection files and `.gitignore`.
2. Add the first precise signature and stub needed by the type-error probe: `# @rbs card_id: Integer` and `# @rbs return: void` on `ChildProfile#broadcast_completion_flag`, and `sticker_card` / `sticker_card=` in `sig/models/sticker.rbs`. Run the two probes in Proof and watch both fail `steep check` with `Ruby::ArgumentTypeMismatch`. Delete the probe file.
3. Split the grouped `include` lines in `app/models/user.rb` and `app/controllers/application_controller.rb`, in reverse order. Before and after, run `bin/rails runner 'p User.ancestors.first(8); p ApplicationController.ancestors.first(6)'` and confirm the output is identical. Run `bin/rails test test/models/user_test.rb` and the controller tests. Commit on its own.
4. `Current#account`: apply Etienne's decision. If he chose removal, remove the method, run `bin/rails test`, and commit on its own. If he chose a `class Account` stub, add it to `sig/stubs/account.rbs` and commit on its own. If no decision exists yet, do not guess: finish steps 5 to 8, then stop and report that `steep check` has one open `UnknownConstant`.
5. Models: annotate every method in `app/models/` and add `sig/models/*.rbs` stubs until `steep check app/models` reports no diagnostics. Commit per model or per small group of models.
6. Controllers and concerns: annotate every method, add `module-self`, add `sig/stubs/routes.rbs` and the Rails/Appkit stubs they need, until `steep check app/controllers` is clean. Commit per namespace (`admin`, `parent`, `child`, `users`, root and concerns).
7. Jobs, channels and helpers: annotate every method and stub what remains, until `steep check` (whole target) exits 0. Commit.
8. Run the unsigned-method check; it must print `0 unsigned or invalid`. Run the YARD tag grep in Proof; it must print nothing.
9. Add the `steep` job to `.github/workflows/ci.yml`. Commit.
10. Add the `steep check` line to `AGENTS.md`. Commit.
11. Run the full gate: `steep check`, `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bin/erb_lint --lint-all --allow-no-files`. Push and confirm the CI `steep` job passes on the pull request.

## Out of scope

- Any Gemfile or `Gemfile.lock` change, `rbs_rails`, `rbs-inline`, or Steep in the bundle.
- `rubocop-yard`, `rubocop-eirvandelden` and any RuboCop config edit (including `AllowRBSInlineAnnotation`).
- Signatures in `test/`, `config/`, `db/`, views, and the Appkit gem.
- Refactors beyond the include split above: the shadowed `app/models/concerns/authorization.rb` (Zeitwerk loads the controller concern of the same name first), the second `enum :role` in `User::Role`, the `Transfer` stub and the unfinished allowance code stay as they are.
- Steep diagnostic level changes, `# steep:ignore`, and a committed type-error fixture.

## Risks

- **Stub volume.** gem_rbs_collection has Rails signatures for older minor versions; Rails 8.1 and turbo-rails APIs may be missing, which can produce many `NoMethod` diagnostics. Mitigation: stubs per gem in `sig/stubs/`, typed `untyped` where precision is impractical. If the stubs grow past roughly 300 lines, stop and report, because the change is then larger than the intent expected.
- **Include order.** A wrong split order changes method resolution between Appkit modules and `User::Role` / `Authorization`. Mitigation: the ancestor comparison in step 3, and the full test suite.
- **Shadowed concern.** Steep reads both `app/models/concerns/authorization.rb` and `app/controllers/concerns/authorization.rb` as one `module Authorization`. The method names do not overlap, so this merges cleanly; only `module-self` must suit both files (`ApplicationController`).
- **Duplicate declarations.** A stub that re-declares an inline-annotated method fails Steep. Mitigation: stubs hold only generated Rails methods.
- **Global Steep drift.** Local and CI Steep versions may differ within `~> 2.0`. Accepted: the constraint pins the major version, and the Gemfile stays untouched by intent.
- **CI `PATH`.** `setup-rv` may not expose gem executables installed with `gem install`. Mitigation: verify on the first CI run and adjust the step only.
- **Open `Current#account` decision.** Without it, `steep check` cannot exit 0 and the CI job cannot pass.
- Rejected: `rbs_rails` (Gemfile change); the `#:` form (RuboCop offence and destructive autocorrect); a Minitest test that shells out to Steep (CI test jobs have no Steep, so `bin/rails test` would break).

## Proof

This change adds no runtime behaviour, so no new Minitest test exists to write first. The type checker and the existing suites are the proof. The walking skeleton is step 1: `steep check` runs and fails before any signature exists.

- Running `steep check` in the repo exits 0 → check: `steep check; echo $?` prints `0`.
- A method called with the wrong argument type makes `steep check` fail → check: write `app/models/steep_probe.rb` containing `class SteepProbe` with one method `# @rbs () -> void` / `def run` whose body is `Sticker.new.sticker_card = User.new` and `ChildProfile.new.broadcast_completion_flag(card_id: "one")`; run `steep check app/models/steep_probe.rb`; it must exit non-zero with two `Ruby::ArgumentTypeMismatch` diagnostics. Delete the file; never commit it.
- No `@param`, `@return` or other YARD tag remains in `app/` or `lib/` (and, per the intent's outcome, in the whole repo) → check: `git grep -nE '^[[:space:]]*#.*@(param|return|raise|yield|yieldparam|yieldreturn|option|example|api|see|note|todo|deprecated|since|private|abstract|overload|attr[a-z_]*)\b' -- '*.rb' ':!vendor'` prints nothing and exits 1. The pattern only matches inside comments, so e-mail addresses such as `newchild@example.com` in tests do not match, and `# @rbs return:` does not match because it has no `@return`.
- Every method in `app/` and `lib/` has an inline RBS signature → check: the unsigned-method script in Design decisions prints `0 unsigned or invalid` and exits 0.
- A pull request runs the Steep job in CI, and it passes → check: `gh pr checks` shows `steep` as pass on the pull request.
- `bin/rails test`, `bin/rubocop` and `bin/brakeman` stay green → check: each exits 0; `bin/rails test:system` and `bin/erb_lint --lint-all --allow-no-files` also stay green.

Per changed file, the unit tests expected:
- `app/models/user.rb` (include split): existing `test/models/user_test.rb` and the Appkit authentication integration tests stay green; the ancestor comparison in step 3 is identical.
- `app/controllers/application_controller.rb` (include split): existing controller and integration tests stay green; the ancestor comparison is identical.
- `app/models/current.rb` (only if Etienne decides on removal): `bin/rails test` stays green; `grep -rn 'Current.account\|\.account\b' app test` prints nothing.
- Every other changed Ruby file gains comments only; the existing suite covers it.

Test setup: none new. The probe file is temporary and lives only for step 2 and the Proof check.

---
Domain skills applied: rails-architecture, ruby-style, rails-testing, dependencies.

## Critique

### Round 1 (codex exec -p terra)

- Removing `Current#account` is a behaviour change (`NameError` becomes `NoMethodError`), conflicts with the intent's "no runtime behaviour changes", and the plan named a Decision needed line that did not exist → fixed (the plan no longer calls the removal non-behavioural and no longer chooses; it states both options and a recommendation, gates step 4 on Etienne's decision, and the report carries the Decision needed line)
- The Steepfile description omitted the required `target` block → fixed (Files that change now gives the full `target :app do ... end` Steepfile)
- The unsigned-method script accepted any `# @rbs` line, including `@rbs @ivar:` and `module-self`, so it did not prove a method type exists → fixed (replaced with an `RBS::InlineParser` check that counts only parsed method-type annotations and also reports parser diagnostics; verified with a probe file on 2026-10-16)
- The YARD grep matched test e-mail addresses such as `newchild@example.com` as `@example`, and discovery and proof used different scopes → fixed (one comment-anchored `git grep` over all tracked `.rb` files, used for both the Context claim and the Proof line; it prints nothing today)
- `rbs collection init` does not read `Gemfile.lock`; `rbs collection install` does → fixed (wording corrected, and step 1 records the resolved gem signature entries)

## Decisions (Etienne, 2026-10-16)

- Steep 2.1.0 is installed globally. Run `steep check` from the worktree.
- Remove `Current#account` (it calls the missing `Account` constant and has no caller). Do not stub `Account` in `sig/`. Commit the removal on its own.
