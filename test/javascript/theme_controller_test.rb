require "test_helper"

class ThemeControllerTest < ActiveSupport::TestCase
  test "theme controller uses plain methods and cleans up live listener" do
    source = Rails.root.join("app/javascript/controllers/theme_controller.js").read

    assert_no_match(/^\s+#\w/, source)
    assert_match(/addEventListener\("change", this\.applySystemThemeChange\)/, source)
    assert_match(/removeEventListener\("change", this\.applySystemThemeChange\)/, source)
  end
end
