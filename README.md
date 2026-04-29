# Sticker App

## About

Sticker App is a behaviour-tracking app for parents and children. Parents award emoji stickers for positive behaviour and penalties for negative behaviour against a configurable goal; children see their progress toward completing a "sticker card" in real time. When a card is filled, the parent marks it as rewarded (a virtual gift) and a fresh card starts automatically. It supports multiple children, optional notes per sticker, multilingual UI (en/nl/it), and live updates via ActionCable.

## What it does

**Roles**: Three roles — Admin, Parent, and Child. The parent dashboard lists all children and their active card progress. The child dashboard shows only their own active sticker card.

**Sticker cards**: Each child has a configurable goal (e.g. 10 stickers). Parents award positive stickers (random from an emoji pool — ⭐ 🌈 🐿️ 💎 🦄 🚀 — or manually chosen) with an optional note. Penalties (negative stickers) do not count toward the goal but raise the target: two penalties on a 10-card means 12 positives are needed to complete it.

**Completion & reward loop**: When the adjusted goal is met the card auto-completes and broadcasts a completion notification. The parent sees a "Mark Rewarded" button; on confirm a new card starts automatically. Full sticker history is viewable per child.

**Real-time**: ActionCable broadcasts new stickers and card completions so the child's view updates without a page refresh.

**Localisation & theming**: UI is available in English, Dutch (nl), and Italian (it). Users can choose light/dark mode and a colour theme (White, Selenized Light, Black, Selenized Dark) from their preferences.

**Intended use**: Family behaviour-tracking, habit-building, and reward systems.

## Requirements

- Ruby 4.0.3 (see `.ruby-version`)
- Rails ~> 8.1.2
- SQLite (no Postgres or Redis required)

## Local setup

```sh
bin/setup        # runs bundle install and db:prepare
bin/dev          # starts the server at http://localhost:3000
```

`config/master.key` must be obtained out-of-band (1Password or shared secure storage). Without it Rails cannot decrypt `config/credentials.yml.enc` and will not boot.

## Tests

```sh
bin/rails test
bin/rails test:system
```

## Linting / security

```sh
bin/rubocop
bin/brakeman
bin/importmap audit
```

These mirror the checks run in `.github/workflows/ci.yml`.

## Deployment

The app is deployed with [Kamal](https://kamal-deploy.org/).

1. Edit `config/deploy.yml` — set image name, server IP, domain, and registry user.
2. Add `KAMAL_REGISTRY_PASSWORD` to `.kamal/secrets`.
3. Set `RAILS_MASTER_KEY` (from the shared `master.key`) in the Kamal env block.
4. Uncomment `config.hosts` in `config/environments/production.rb` and pin it to your domain.
5. First deploy: `kamal setup && kamal deploy`
6. Subsequent deploys: `kamal deploy`
7. Health check: `curl https://<domain>/up`

## Storage note

SQLite database files live in `/rails/storage/` inside the container, mounted as a Docker volume per `config/deploy.yml`. Back this volume up regularly.
