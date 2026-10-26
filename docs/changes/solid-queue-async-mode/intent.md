# Intent: Run Solid Queue in async mode inside Puma

Author: Etienne van Delden. Status: accepted. Type: chore. Delivery: autonomous. Codex review: no.

## Problem

The app uses 410 MB in production on CT104 (3 cores, 12 GB, about 12 apps, 2 to 5 users per app). The Solid Queue Puma plugin forks a supervisor, a dispatcher, a scheduler and a worker, each a separate Ruby process. Measured in Fizzy, the supervisor, dispatcher and scheduler hold about 160 MB of private memory. Throughput does not matter at this user count.

## Proposed outcome

Production runs one Ruby process: Puma, with Solid Queue's dispatcher, scheduler and worker as threads inside it. Jobs and recurring tasks keep working as today.

## Affected users and systems

- The production app on CT104 (one Puma process, one queue database).
- Etienne, who deploys; this change does not deploy.

## Constraints

- Solid Queue 1.7.0 (Gemfile.lock) supports async mode since 1.3.0.
- Only `solid_queue_mode :async` after `plugin :solid_queue` in `config/puma.rb` switches the mode inside Puma; `SOLID_QUEUE_SUPERVISOR_MODE` has no effect there.
- Async mode ignores `processes` in `config/queue.yml`.
- The threads share one Active Record pool per database.
- The Solid Queue README recommends fork mode; Etienne chose async on purpose, for memory.
- Never run kamal commands. Never read or print secrets.
- No permissions beyond the repository are needed: no gems, no migrations, no deploy files.

## In scope

- `config/puma.rb`: add `solid_queue_mode :async` on the line after `plugin :solid_queue`.
- `config/database.yml`: the production queue database pool becomes `RAILS_MAX_THREADS` (default 5) plus 6. It covers 3 worker threads, the dispatcher, the scheduler and the supervisor heartbeat, plus the Puma threads that enqueue jobs.
- Local verification, with the evidence recorded.

## Out of scope

- `config/deploy.yml`, including the `SOLID_QUEUE_IN_PUMA` variable.
- Pools of the primary, cache and cable databases.
- `config/queue.yml` (`processes` stays; async ignores it).
- Deploying, and the untracked `yarn.lock` and modified `db/schema.rb` in the main checkout.

## Acceptance criteria

- With `SOLID_QUEUE_IN_PUMA=true` and production-like settings, `ps` shows one Ruby process for Puma and no solid-queue-supervisor, -dispatcher, -scheduler or -worker process.
- An enqueued job runs to completion.
- The scheduler loads every task in `config/recurring.yml`, including `Appkit::SessionExpiryJob` and `AllowancePeriodGrantingJob`.
- `/up` returns 200.
- The queue pool in production resolves to at least 11 with default settings.
- The full test suite and every linter are green.

## Decisions

- Queue pool as a formula in `database.yml` (`RAILS_MAX_THREADS` + 6), not a fixed number — it follows `RAILS_MAX_THREADS` and needs no env var; deploy.yml stays untouched.
- Autonomous delivery, no Codex review — chosen at the intent interview; Codex round costs extra tokens.

## Open questions

None.
