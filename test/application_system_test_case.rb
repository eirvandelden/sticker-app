require "test_helper"

# Capybara's 2-second default has repeatedly been too short under CI load,
# flaking the sessions/preferences/realtime system tests.
Capybara.default_max_wait_time = 5

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
