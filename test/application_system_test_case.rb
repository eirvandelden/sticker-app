require "test_helper"

# CI runners are slower than a local machine, and the login page forces a full
# page reload (see Appkit::SessionsController#render_rejection) instead of a
# same-request Turbo render, adding a second round trip before the rejection
# message appears. Capybara's 2-second default has repeatedly been too short
# for that under CI load, flaking sessions/preferences/realtime system tests.
Capybara.default_max_wait_time = 5

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
