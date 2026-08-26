require "test_helper"

# A cold CI runner takes about twice as long as a warm one, which is long enough
# to outrun Capybara's default and flake the sessions/preferences/realtime tests.
Capybara.default_max_wait_time = 10

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
