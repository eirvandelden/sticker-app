# Verification: solid-queue-async-mode

Run on 2026-10-29 with `RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 SOLID_QUEUE_IN_PUMA=true PORT=3999`, solid_queue 1.7.0, Puma 8.0.2.

## Plugin source (step 1)

`lib/puma/plugin/solid_queue.rb` defines `solid_queue_mode` and calls `start_solid_queue(mode: :async, standalone: false)`. The plan matches 1.7.0.

## Queue pool

Without `RAILS_MAX_THREADS`: `{"primary" => 5, "cache" => 5, "queue" => 11, "cable" => 5}`.

With `RAILS_MAX_THREADS=10`: `{"primary" => 10, "cache" => 10, "queue" => 16, "cable" => 10}`.

## One process

- `ps -o pid,command -p $PUMA_PID`: one line, `puma 8.0.2 (tcp://0.0.0.0:3999) [solid-queue-async-mode]`.
- `pgrep -P $PUMA_PID`: `no child processes`.
- The log shows `Started Supervisor(async)`, `Dispatcher`, `Worker` and `Scheduler`, all with the Puma pid.
- `SolidQueue::Process.distinct.pluck(:pid) == [$PUMA_PID]` prints `true`.
- `SolidQueue::Process.order(:kind).pluck(:kind)` prints `["Dispatcher", "Scheduler", "Supervisor(async)", "Worker"]`. The plan expected `"Supervisor"`; 1.7.0 names the kind `Supervisor(async)`.
- The plan's `ps -axo command | grep -c '[s]olid-queue-'` is machine-wide. It printed 3 because another project's fork-mode Puma (pid 46220) was running. Its `solid-queue-fork-supervisor` and `solid-queue-dispatcher` processes have parents other than this Puma. No process of this server matches.

## Job

The plan's one-liner polls `find_by` inside `rails runner`, whose query cache returns a stale row, so it printed `nil` three times even though the log showed `Performed AllowancePeriodGrantingJob`. With `SolidQueue::Job.uncached { ... }` it prints `2026-10-29 13:10:42.941127000 UTC +00:00`.

## Recurring tasks

`SolidQueue::RecurringTask.order(:key).pluck(:key, :class_name)` prints `[["allowance_period_granting", "AllowancePeriodGrantingJob"], ["appkit_session_expiry", "Appkit::SessionExpiryJob"], ["clear_solid_queue_finished_jobs", nil]]`. The task `clear_solid_queue_finished_jobs` uses a `command`, so its class is `nil`.

## /up

`curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3999/up` prints `200`.

## Development boot

`env -u SOLID_QUEUE_IN_PUMA bin/rails server -p 3998` prints `* Listening on http://127.0.0.1:3998`.

## Shutdown

`kill -INT` gives `Gracefully stopping, waiting for requests to finish`, `Goodbye!`, `Exiting`. The throwaway `storage/production*.sqlite3*` files were deleted.
