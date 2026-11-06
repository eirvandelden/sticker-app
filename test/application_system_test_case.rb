require "test_helper"

# A cold CI runner takes about twice as long as a warm one, which is long enough
# to outrun Capybara's default and flake the sessions/preferences/realtime tests.
Capybara.default_max_wait_time = 10

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  teardown { clear_phone_emulation }

  # Resizes the browser to a phone through the DevTools protocol.
  def emulate_phone(width:, height:)
    @phone_emulated_in = Capybara.session_name
    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride",
                                    width: width, height: height, deviceScaleFactor: 3, mobile: true)
  end

  # Puts the browser back to its normal size.
  def clear_phone_emulation
    return unless @phone_emulated_in

    Capybara.using_session(@phone_emulated_in) do
      page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
    end
    @phone_emulated_in = nil
  end
end
