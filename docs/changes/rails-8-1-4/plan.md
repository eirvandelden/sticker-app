# Plan

Run `bundle update rails --conservative` (never plain `bundle update`).

Loosen the `~> 8.1` Gemfile constraint only if it blocks resolving 8.1.4.

Run test suite, rubocop on touched files, `bundle exec bundler-audit check --update`, `bin/brakeman` if available.

Confirm boot with `bin/rails runner 'puts Rails.version'` prints 8.1.4.

Remove the `json < 3` pin and its comment from the Gemfile, run `bundle update json --conservative`, then run the tests, rubocop and bundler-audit on json 3.x.
