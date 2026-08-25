require "test_helper"

# Capybara's 2-second default, and the 5 seconds that replaced it, have both been
# too short under CI load: a cold run that takes twice as long as a warm one still
# flakes the sessions/preferences/realtime system tests.
Capybara.default_max_wait_time = 10

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
