# Sticker App

## What this is

A behaviour-tracking and pocket-money app for a family. Parents award emoji stickers for positive behaviour and penalties for negative behaviour toward a configurable goal; children watch their progress in real time. A separate, less-developed allowance feature tracks weekly pocket money (zakgeld) and monthly clothing money (kleedgeld) per child, with Dutch NIBUD guideline amounts suggested by age.

## Domain

- `User` has a role: `admin`, `parent`, or `child`. A `child` user gets a `ChildProfile` automatically (`User#provision_child_profile`).
- `ChildProfile` belongs to a `User`, has many `StickerCard`s and `Allowance`s, and carries the `sticker_goal` and penalty `goal` a new card is stamped with.
- `StickerCard` belongs to a `ChildProfile` and has many `Sticker`s. `required_stickers` is `sticker_goal + negative_count` — each penalty raises the target rather than subtracting from progress. A card is `completed?` once `positive_count >= required_stickers`, and `rewardable?` once completed but not yet `reward_given`. Completing a card creates the next one automatically (`ChildProfile#active_sticker_card` is always the most recent card).
- `Sticker` belongs to a `StickerCard`, is `positive` or `negative` (`enum :kind`), and gets a random emoji from `Sticker::EMOJI_POOL` when positive. Creating one checks for card completion and broadcasts over ActionCable.
- `Allowance` belongs to a `ChildProfile`, one per `kind` (`zakgeld`/`kleedgeld`) with a `frequency` (`weekly`/`monthly`) and a `due_day`. `grant_due_period!` creates an `AllowancePeriod` when due and advances `next_due_on`. `NibudAdvice` suggests an amount from the child's age; nothing enforces that suggestion.
- `AllowancePeriod` belongs to an `Allowance` and is marked `given` once paid (`Parent::AllowancePaymentsController#create`).
- `Transfer` is an empty stub model (see its own TODO comments) — not wired to anything yet.

## Commands

```sh
bin/setup                 # install deps, prepare db, start server (--skip-server to skip that)
bin/dev                   # run the server at http://localhost:3000
bin/rails test            # unit/integration tests
bin/rails test:system     # system tests (Capybara + Selenium)
bin/rubocop               # lint
bin/brakeman              # security scan
bin/importmap audit       # JS dependency audit
bin/erb_lint --lint-all --allow-no-files   # ERB lint (also run in CI)
npx @herb-tools/herb-lint                  # HTML/ERB structure lint (also run in CI, as `npx @herb-tools/linter`)
bundle exec ruby ./bin/check_i18n_normalized  # i18n key normalization check (CI)
```

`config/master.key` / `RAILS_MASTER_KEY` is needed for credentials and production; get it out-of-band. Ruby version is pinned in `.ruby-version` (`rv` manages it). No Postgres or Redis — SQLite plus the Solid trifecta (`solid_cache`/`solid_queue`/`solid_cable`).

## Gotchas

- The README only documents the sticker feature. The allowance/pocket-money models above (`Allowance`, `AllowancePeriod`, `NibudAdvice`, `Transfer`) exist in the code and have routes and a controller, but are not mentioned there and are visibly unfinished (`Transfer` is an empty stub, `Allowance#kind=`/`#frequency=` silently swallow invalid enum values). Don't assume the README's feature list is complete.
- Penalties don't subtract sticker progress — they raise `required_stickers`. Read `StickerCard#required_stickers`/`#completed?` before changing goal or progress logic.
- `ChildProfile#active_sticker_card` and `StickerCard#check_and_create_next_card_if_completed` rely on `created_at` ordering, deliberately not `completed_at` (see the comment on `rewardable_sticker_card`) — don't reorder by `completed_at`.
- Routes are mounted under an external `Appkit::Engine` (`eirvandelden/appkit`) at `/`, which also supplies authentication (`Appkit::Authenticatable`), theming, and the CI workflow (`eirvandelden/appkit/.github/workflows/rails-ci.yml`). Session/profile/preferences behavior mostly lives in that gem, not this app.
