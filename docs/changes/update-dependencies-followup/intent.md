# Intent: Finish updating dependencies to their latest versions

Author: Etienne van Delden de la Haije. Status: accepted (2026-10-17). Type: chore. Delivery: autonomous.

## Problem

The `update-dependencies` change (branch `update-dependencies`, no pull request yet) is meant to bring every dependency to its latest version. Its review round 1 (2026-10-13) found new gem releases and an appkit pin 38 commits behind appkit `main`. On 2026-10-16 that branch updated the gems again (only marcel stays behind, held by Rails), pinned appkit at `d837929`, and set herb's framework. Dependencies keep moving: on 2026-10-17 appkit `main` is at `e47907f`, 7 commits past that pin, so the app misses appkit's latest changes. The app's shadowed nav and login views copy appkit markup, so a re-pin alone leaves them out of date. The production Docker image on Ruby 4.0.7 was never built successfully, and CI never ran on these changes.

Problem facts refreshed on 2026-10-17 after acceptance; scope and acceptance criteria are unchanged.

## Proposed outcome

On top of `update-dependencies`, every dependency is again at the newest version its constraints allow. appkit is pinned at the newest commit on its `main`. The app's shadowed nav and login views carry appkit `main`'s markup and wording, with the app's own Home target and current-page rule kept. herb lint reports nothing at any level. The production image builds locally, and CI is green on the pull request.

## Affected users and systems

- Parents and children: they see appkit `main`'s current nav and login page.
- Developers: local Ruby and Node may move to a newer patch or LTS, if one exists.
- CI: runs on this branch's pull request, which targets `main` (see the amendment under Constraints).
- Production image: its Ruby base image follows `.ruby-version`.
- appkit: no change.

## Constraints

- This branch stacks on `update-dependencies`, because the nav shadow view only exists there. It rebases onto `update-dependencies` before any code change, and its pull request targets `update-dependencies`. `update-dependencies` merges to `main` first. If `update-dependencies` changes later, this branch rebases onto it again (rule 20). Decided 2026-10-17, replacing the earlier wait-for-merge constraint. Amended 2026-10-20: `update-dependencies` merged into `main` as PR #181, so this branch rebases onto `origin/main` and its pull request targets `main` (rule 20).
- Approved now (rule 11): a full `bundle update`, and npm packages at their latest versions.
- Approved now (rules 8 and 13): if a newer Ruby 4.0.x or Node LTS exists, change `.ruby-version`, the Dockerfile `ARG RUBY_VERSION` and `node-version` in `.github/workflows/ci.yml` to it.
- Approved now: a local `docker build` of the production image, to verify it. No image push, no deploy.
- Approved now: `framework: actionview` in `.herb.yml`. This is an explicit exception to §7a's ban on linter config edits.
- `.ruby-version` and the Dockerfile `ARG RUBY_VERSION` stay in sync.
- The herb gem and the `@herb-tools/linter` npm package stay on the same minor version.
- When an update breaks the app or a lint, the app gets fixed in this branch. No dependency is held back for that reason.
- No change in appkit. The app keeps its own shadowed views.

## In scope

- Rebasing this branch onto `update-dependencies`.
- Pushing `update-dependencies` to `origin`, so this branch's pull request can target it.
- All gems in `Gemfile.lock`, direct and transitive, at the newest version their constraints allow.
- mvpa-css, rubocop-eirvandelden and exception_notification-campfire-once at the newest commit on their `main`.
- npm packages in `package.json` and its lockfile at their latest versions. `main` replaced `yarn.lock` with `package-lock.json` (2026-10-20), so the lockfile is `package-lock.json`.
- appkit's pin in the Gemfile at the newest commit on appkit `main`.
- The shadowed `app/views/appkit/shared/_nav.html.erb` and `app/views/appkit/sessions/new.html.erb` re-copied from appkit `main`, keeping the app's Home target and its `nav_section_tab` current-page rule.
- Any other shadowed appkit view that appkit `main` changed, re-copied the same way.
- `framework: actionview` in `.herb.yml`.
- A newer Ruby 4.0.x or Node LTS, where one exists.
- App changes that the updates force: new lint offences, new appkit behaviour, test fixes for changed behaviour.
- A local build of the production image.

## Out of scope

- Opening, reviewing or merging the `update-dependencies` pull request. Etienne does that separately.
- The two missing `assert_response :success` lines in `test/controllers/navigation_test.rb` (review round 1 nit).
- A manual `bin/dev` check of nav, theme and mvpa-css styling.
- Any change in appkit.
- Loosening any Gemfile version constraint.
- Transitive gems held back by another gem's own constraint (for example marcel 2.x, held back by Rails).
- Open Dependabot pull requests: Dependabot closes them itself once newer versions merge.
- New features beyond what the updated dependencies require.
- Deploying.

## Acceptance criteria

- `bundle outdated` lists only gems held back by another gem's constraint (today: only marcel, held back by Rails).
- `npm outdated` lists nothing (was `yarn outdated` before `main` moved to npm).
- The Gemfile pins appkit at the newest commit on appkit `main`.
- The app's nav and login page show appkit `main`'s markup and wording; the only difference in the nav is the Home target and its current-page rule.
- A parent clicks Home and lands on the children list, with Home marked as the current page.
- A parent on a child's page, edit page or history sees Home marked; on settings, admin or preferences, Home is not marked.
- A child clicks Home and lands on their dashboard, with Home marked as the current page.
- A parent awards a sticker to a child, and the child sees it on their sticker card.
- herb lint reports no offences, including info-level ones.
- `ruby -v` in the worktree reports the version in `.ruby-version`, and the Dockerfile builds on that same version.
- The production image builds locally, and `ruby -v` inside it reports that version.
- Tests, system tests, rubocop, erb_lint, herb lint, the i18n normalization check, brakeman, bundler-audit and importmap audit are all green.
- CI is green on this branch's pull request.

## Open questions

None.
